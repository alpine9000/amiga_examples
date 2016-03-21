/*
Lempel-Ziv compressor by Johan "Doynax" Forslöf.

This is based on the 6502 Doynamite format, except with the encoding rearranged to take
somewhat better advantage of the 68k architecture.

Note that the scheme with a split input stream for odd literal bytes requires
a significant safety buffer for forward in-place decompression (about 3% but
dependent on the file to be processed)
*/

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <limits.h>
#include <assert.h>

// Compile-time configuration
#define DEFAULT_LENGTHS     "3/6/8/10:4/7/10/13"
// Decruncher limitations
#define MATCH_LIMIT         0x100
#define LITERAL_LIMIT       0x1FFFF
#define OFFSET_LENGTH_MIN   3
#define OFFSET_LENGTH_MAX   13

// Some definitions for compiler independence
#if __STDC_VERSION__ >= 199901L
#	include <stdbool.h>
#else
#	ifdef _MSC_VER
#		define inline __forceinline
#	elif defined(__GNUC__)
#		define inline __inline
#	else
#		define inline
#	endif
typedef enum { false, true } bool;
#endif

#ifdef _WIN32
	// off64_t used instead of _off64_t in file positioning functions.
	// Yank them altogether for now
#	if defined(__MINGW32__) && defined(__STRICT_ANSI__)
#		define __NO_MINGW_LFS
#	endif
#	include <malloc.h>
#	include <io.h>
#	ifndef alloca
#		define alloca _alloca
#	endif
#else
#	include <sys/stat.h>
#	include <alloca.h>
#endif
#if defined(__STRICT_ANSI__) && (defined(__MINGW32__) || defined(__CYGWIN__))
#	ifndef _fileno
#		define _fileno(p) ((p)->_file)
#	endif
#endif

#	define _fileno(p) ((p)->_file)

#if CHAR_BIT != 8
	// No doubt a 36-bit sign-magnitude machine with signaling integer overflow,
	// non-extending right shifts, decimal floating point and 6 significant
	// characters in external identifiers
#	error
#endif

#undef min

// The main crunching structure
typedef struct {
	signed match_length;
	unsigned match_offset;
	union {
		signed hash_link;
		unsigned cumulative_cost;
	};
} lz_info;

typedef struct {
	unsigned short *ptr;
	unsigned mask;
} lz_bittag_t;

typedef struct {
	unsigned char *src_data;
	unsigned src_begin;
	unsigned src_end;

	lz_info *info;

	unsigned short *dst_wordbuf;
	unsigned short *dst_wordptr;
	unsigned short *dst_wordend;
	unsigned char *dst_litbuf;
	unsigned char *dst_litptr;
	unsigned char *dst_litend;
	lz_bittag_t dst_bitbuf[32];

	signed hash_table[0x100];

	// Some informational counters
	struct {
		unsigned output_size;
		unsigned output_bits;
		unsigned short_freq[4];
		unsigned long_freq[4];
		unsigned literal_bytes;
		unsigned literal_runs;
		unsigned match_bytes;
		unsigned match_count;
		unsigned offset_distance;
	} stats;
} lz_context;

// A bit of global configuration data
typedef struct  {
	unsigned bits;
	unsigned base;
	signed limit;
} offset_length_t;

static offset_length_t cfg_short_offset[4];
static offset_length_t cfg_long_offset[4];
#define cfg_short_limit (cfg_short_offset[3].limit)
#define cfg_long_limit (cfg_long_offset[3].limit)


/******************************************************************************
 * Various utility functions and bithacks
 ******************************************************************************/
#define countof(n) (sizeof(n) / sizeof *(n))

static inline unsigned _log2(unsigned value) {
#	ifdef __GNUC__
	enum { WORD_BITS = sizeof(unsigned) * CHAR_BIT };
	return (WORD_BITS - 1) ^ __builtin_clz(value);
#	else
	signed bits = -1;
	do
		++bits;
	while(value >>= 1);
	return bits;
#	endif
}

static inline unsigned min(unsigned a, unsigned b) {
	return (a < b) ? a : b;
}

#ifdef _MSC_VER
__declspec(noreturn)
#elif defined(__GNUC__)
__attribute__((noreturn))
__attribute__((format(printf, 1, 2)))
#endif
static void
#ifdef _MSC_VER
__cdecl
#endif
fatal(const char *format, ...) {
	va_list args;

	va_start(args, format);
	fputs("error: ", stderr);
	vfprintf(stderr, format, args);
	fputc('\n', stderr);
	va_end(args);

	exit(EXIT_FAILURE);
}



/******************************************************************************
 * Manage the output stream
 ******************************************************************************/
static inline void output_write(lz_context *ctx, const char *name) {
	FILE *file = fopen(name, "wb");
	unsigned length;
	unsigned short *ptr;
	unsigned short swap;
	if(!file)
		fatal("error: cannot create '%s'", name);
	// Write offset to the literal section
	length = (ctx->dst_wordptr - ctx->dst_wordbuf) * 2;
	putc(length >> 24, file);
	putc(length >> 16, file);
	putc(length >> 8, file);
	putc(length >> 0, file);
	// The seed word needs to be stored in the opposite word order
	ptr = ctx->dst_wordbuf;
	swap = ptr[0];
	ptr[0] = ptr[1];
	ptr[1] = swap;
	// Write bit-buffer words in big-endian order
	for(; ptr < ctx->dst_wordptr; ++ptr) {
		putc(*ptr >> 8, file);
		putc(*ptr >> 0, file);
	}
	// Finally close with the literals words
	fwrite(ctx->dst_litbuf, ctx->dst_litptr - ctx->dst_litbuf,
		sizeof *ctx->dst_litbuf, file);
	ctx->stats.output_size = ftell(file);
	fclose(file);
}

static unsigned short *output_word(lz_context *ctx) {
	unsigned short *ptr = ctx->dst_wordptr++;
	if(ptr == ctx->dst_wordend)
		fatal("out of output buffer space");
	return ptr;
}

static inline void output_flush(lz_context *ctx) {
	if(!ctx->dst_bitbuf[16].ptr) {
		size_t i;
		unsigned short *ptr = output_word(ctx);
		*ptr = 0;
		for(i = 0; i < 16; ++i) {
			ctx->dst_bitbuf[i] = ctx->dst_bitbuf[i + 16];
			ctx->dst_bitbuf[i + 16].ptr = ptr;
			ctx->dst_bitbuf[i + 16].mask = 1 << i;
		}
	}
}

static void output_bits_at(lz_context *ctx, unsigned data, unsigned len,
	unsigned offset) {
	lz_bittag_t *bit;
	offset = 32 - offset;
	for(bit = &ctx->dst_bitbuf[offset - len]; bit < &ctx->dst_bitbuf[offset]; ++bit) {
		if(data & 1)
			*bit->ptr |= bit->mask;
		data >>= 1;
	}
	memmove(&ctx->dst_bitbuf[len], ctx->dst_bitbuf,
		(offset - len) * sizeof *ctx->dst_bitbuf);
	memset(ctx->dst_bitbuf, 0, len * sizeof *ctx->dst_bitbuf);
}

static void output_bits(lz_context *ctx, unsigned data, unsigned len) {
	output_bits_at(ctx, data, len, 0);
}

static void output_bit(lz_context *ctx, unsigned data) {
	output_bits(ctx, data, 1);
}

static void output_literal(lz_context *ctx, unsigned value) {
	unsigned char *ptr = ctx->dst_litptr++;
	if(ptr == ctx->dst_litend)
		fatal("out of literal buffer space");
	*ptr = value;
}

static inline unsigned output_bitsize(lz_context *ctx) {
	const lz_bittag_t *bit;

	unsigned total = ctx->dst_wordptr - ctx->dst_wordbuf;
	total <<= 1;
	total += ctx->dst_litptr - ctx->dst_litbuf;

	// Count up the unused remaining bits at the end
	total <<= 3;
	for(bit = &ctx->dst_bitbuf[31]; bit->ptr; --bit)
		--total;

	ctx->stats.output_bits = total;
	return total;
}

static inline unsigned output_init(lz_context *ctx, unsigned bits,
	unsigned literals) {
	unsigned seed;
	unsigned words;

	// Drop the separately stored literals
	signed adjustment = literals * 8;
	bits -= adjustment;
	words = (bits + 15) >> 4;
	// Fudge factor
	words += 2;

	// Allocate the output buffers
	ctx->dst_wordbuf = malloc(words * sizeof *ctx->dst_wordbuf);
	ctx->dst_wordptr = ctx->dst_wordbuf;
	ctx->dst_wordend = &ctx->dst_wordptr[words];

	ctx->dst_litbuf = malloc(literals * sizeof *ctx->dst_litbuf);
	ctx->dst_litptr = ctx->dst_litbuf;
	ctx->dst_litend = &ctx->dst_litend[words];

	// Throw away any left-over bits required to round up the bit-stream length
	// to full 16-bit words. Also append the '1' bit sentinel. This serves to
	// creates a seed word
	output_flush(ctx);
	seed = (0 - bits) & 15;
	seed += 16;
	*ctx->dst_bitbuf[seed].ptr |= ctx->dst_bitbuf[seed].mask;
	memset(ctx->dst_bitbuf, 0, sizeof *ctx->dst_bitbuf * (seed + 1));

	// Return the adjusted size
	return bits + adjustment;
}


/******************************************************************************
 * Read file into memory and allocate per-byte buffers
 ******************************************************************************/
static void read_input(lz_context *ctx, const char *name) {
	FILE *file;
	signed length;

	if(file = fopen(name, "rb"), !file)
		fatal("unable to open '%s'", name);

#	ifdef _WIN32
	length = _filelength(_fileno(file));
#	else
	{
		struct stat stat;
		stat.st_size = 0;
		fstat(_fileno(file), &stat);
		length = stat.st_size;
	}
#	endif

	if(length <= 0)
		fatal("cannot determine length of '%s'", name);

	{
		// Give us a sentinel for the info structure and prevent two-byte
		// hashing from overrunning the buffer
		unsigned count = length + 1;

		ctx->info = malloc(count *
			(sizeof *ctx->info + sizeof *ctx->src_data));
		ctx->src_data = (void *) &ctx->info[count];

		if(!ctx->info)
			fatal("cannot allocate memory buffer");

		if(fread(ctx->src_data, length, 1, file) != 1)
			fatal("cannot read '%s'", name);
	}

	ctx->src_begin = 0;
	ctx->src_end = length;
}


/******************************************************************************
 * Try to figure out what matches would be the most beneficial
 ******************************************************************************/
static inline unsigned costof_run(unsigned run) {
	return _log2(run) * 2 + 1;
}

static inline unsigned costof_literals(unsigned address, unsigned length) {
	unsigned cost = length * 8;
	// Long (8-bit+) runs have a special raw encoding
	if(length >= 256)
		return cost + 17 /* run length */ - 7 /* push back */ + 16 /* raw length */;
	return cost + costof_run(length);
}

static inline unsigned costof_match(const offset_length_t *class, signed offset,
	unsigned length) {
	unsigned cost = 3;

	while(offset > class->limit)
		++class;
	cost += class->bits;

	return cost + costof_run(length - 1);
}

static inline lz_info optimal_parsing_literal(const lz_info *info, unsigned cursor) {
	unsigned cost;
	lz_info result;

	signed length = -info[cursor + 1].match_length;

	if(length > 0)
		cost = info[cursor + ++length].cumulative_cost;
	else {
		cost = info[cursor + 1].cumulative_cost;
		length = 1;
	}

	cost += costof_literals(cursor, length);

	result.match_length = -length;
	result.cumulative_cost = cost;
	return result;
}

static inline lz_info optimal_parsing (
	const lz_info *info,
	unsigned cursor,
	signed match_offset,
	unsigned match_length,
	unsigned match_limit,
	lz_info best_match
) {
	unsigned cost;

	if(match_length == 2) {
		if(match_offset <= cfg_short_limit) {
			cost = costof_match(cfg_short_offset, match_offset, match_length);
			goto try_short_match;
		} else if(++match_length > match_limit)
			return best_match;
	}

	do {
		cost = costof_match(cfg_long_offset, match_offset, match_length);
try_short_match:
		cost += info[cursor + match_length].cumulative_cost;

		if(cost < best_match.cumulative_cost) {
			best_match.match_offset = match_offset;
			best_match.match_length = match_length;
			best_match.cumulative_cost = cost;
		}
	} while(++match_length <= match_limit);

	return best_match;
}



/******************************************************************************
 * Determine the longest match for every position of the file
 ******************************************************************************/
static inline signed *hashof(lz_context *ctx, unsigned a, unsigned b) {
	static const unsigned char random[] = {
		0x17, 0x80, 0x95, 0x4f, 0xc7, 0xd1, 0x15, 0x13,
		0x91, 0x57, 0x0f, 0x47, 0xd0, 0x59, 0xab, 0xf0,
		0xa7, 0xf5, 0x36, 0xc0, 0x24, 0x9c, 0xed, 0xfd,
		0xd4, 0xf3, 0x51, 0xb4, 0x8c, 0x97, 0xa3, 0x58,
		0xcb, 0x61, 0x78, 0xb1, 0x3e, 0x7e, 0xfb, 0x41,
		0x39, 0xa6, 0x8e, 0x10, 0xa1, 0xba, 0x62, 0xcd,
		0x94, 0x02, 0x0d, 0x2b, 0xdb, 0xd7, 0x44, 0x16,
		0x29, 0x4d, 0x68, 0x0a, 0x6b, 0x6c, 0xa2, 0xf8,
		0xc8, 0x9f, 0x25, 0xca, 0xbd, 0x4a, 0xc2, 0x35,
		0x53, 0x1c, 0x40, 0x04, 0x76, 0x43, 0xa9, 0xbc,
		0x46, 0xeb, 0x99, 0xe9, 0xf6, 0x5e, 0x8f, 0x8a,
		0xf1, 0x5d, 0x21, 0x33, 0x0b, 0x82, 0xdf, 0x52,
		0xea, 0x27, 0x22, 0x9a, 0x6f, 0xad, 0xe5, 0x83,
		0x11, 0xbe, 0xa4, 0x85, 0x1d, 0xb3, 0x77, 0xf4,
		0xef, 0xb7, 0xf2, 0x03, 0x64, 0x6d, 0x1b, 0xee,
		0x72, 0x08, 0x66, 0xc6, 0xc1, 0x06, 0x56, 0x81,
		0x55, 0x60, 0x70, 0x8d, 0x23, 0xb2, 0x65, 0x5b,
		0xff, 0x4c, 0xb9, 0x7a, 0xd6, 0xe6, 0x19, 0x9b,
		0xb5, 0x49, 0x7d, 0xd8, 0x45, 0x1a, 0x84, 0x32,
		0xdd, 0xbf, 0x9e, 0x2f, 0xd2, 0xec, 0x92, 0x0e,
		0xe8, 0x7c, 0x7f, 0x00, 0x86, 0xde, 0xb6, 0xcf,
		0x05, 0x69, 0xd5, 0x37, 0xe4, 0x30, 0x3c, 0xe1,
		0x4b, 0xaa, 0x3b, 0x2d, 0xda, 0x5c, 0xcc, 0x67,
		0x20, 0xb0, 0x6a, 0x1f, 0xf9, 0x01, 0xac, 0x2e,
		0x71, 0xf7, 0xfc, 0x3f, 0x42, 0xd3, 0xbb, 0xa8,
		0x38, 0xce, 0x12, 0x96, 0xe2, 0x14, 0x87, 0x4e,
		0x63, 0x07, 0xae, 0xdc, 0xa5, 0xc9, 0x0c, 0x90,
		0xe7, 0xd9, 0x09, 0x2a, 0xc4, 0x3d, 0x5a, 0x34,
		0x8b, 0x88, 0x98, 0x48, 0xfa, 0xc3, 0x26, 0x75,
		0xfe, 0xa0, 0x7b, 0x50, 0x2c, 0x89, 0x18, 0x9d,
		0x3a, 0x73, 0x6e, 0x5f, 0xc5, 0xaf, 0xb8, 0x74,
		0x93, 0xe3, 0x79, 0x28, 0xe0, 0x1e, 0x54, 0x31
	};

	size_t bucket = random[a] ^ b;
	return &ctx->hash_table[bucket];
}

static inline void generate_hash_table(lz_context *ctx) {
	unsigned cursor;

	const unsigned src_end = ctx->src_end;
	const unsigned char *src_data = ctx->src_data;
	lz_info *info = ctx->info;

	for(cursor = 0; cursor < countof(ctx->hash_table); ++cursor)
		ctx->hash_table[cursor] = INT_MIN;

	for(cursor = ctx->src_begin; cursor != src_end; ++cursor) {
		signed *hash_bucket = hashof (
			ctx,
			src_data[cursor + 0],
			src_data[cursor + 1]
		);

		info[cursor].hash_link = *hash_bucket;
		*hash_bucket = cursor;
	}
}

static inline void find_matches(lz_context *ctx) {
	const unsigned src_begin = ctx->src_begin;
	const unsigned src_end = ctx->src_end;
	const unsigned char *src_data = ctx->src_data;
	lz_info *info = ctx->info;

	unsigned offset_limit = cfg_long_limit;
	unsigned cursor = ctx->src_end;

	// Install a sentinel at the end of the array
	info[cursor].match_offset = SHRT_MAX;
	info[cursor].match_length = 0;
	info[cursor].cumulative_cost = 0;

	while(cursor != src_begin) {
		unsigned match_length;
		signed cursor_limit;
		unsigned length_limit;
		signed *hash_bucket;
		signed hash_link;
		lz_info best_match;

		--cursor;

		match_length = 1;
		cursor_limit = cursor - offset_limit;

		length_limit = min(MATCH_LIMIT, src_end - cursor);

		hash_bucket = hashof (
			ctx,
			src_data[cursor + 0],
			src_data[cursor + 1]
		);

		assert((unsigned) *hash_bucket == cursor);
		hash_link = info[cursor].hash_link;
		*hash_bucket = hash_link;

		best_match = optimal_parsing_literal(info, cursor);

		while(hash_link >= cursor_limit) {
			unsigned int match_limit = min(hash_link, length_limit);

			if(match_length < match_limit) {
				unsigned i = match_length + 1;

				if(!memcmp(&src_data[cursor], &src_data[hash_link], i)) {
					for(; i != match_limit; ++i) {
						if(src_data[cursor + i] != src_data[hash_link + i])
							break;
					}

					assert(i <= match_limit);

					best_match = optimal_parsing (
						info,
						cursor,
						cursor - hash_link,
						match_length + 1,
						i,
						best_match
					);

					match_length = i;

					if(match_length == MATCH_LIMIT)
						break;
				}
			}

			hash_link = info[hash_link].hash_link;
		}

		info[cursor] = best_match;
	}
}


/******************************************************************************
 * Write the generated matches and literal runs
 ******************************************************************************/
static inline void encode_literals (
	lz_context *ctx,
	unsigned cursor,
	unsigned length
) {
	unsigned bit;
	const unsigned char *data;

	ctx->stats.literal_bytes += length;
	++ctx->stats.literal_runs;

	output_flush(ctx);

	// Gamma coding with the final data bit juggled around to the end
	if(length < 256) {
		bit = _log2(length);
		if(!bit) {
			output_bit(ctx, 0);
		} else {
			output_bit(ctx, 1);
			while(--bit) {
				output_bit(ctx, 1);
				output_bit(ctx, length >> bit);
			}
			output_bit(ctx, 0);
			output_bit(ctx, length);
		}
	// A special raw mode is used for 8-bit+ literals
	} else {
		// Just bail if it doesn't even fit in 128 kB
		if(length > LITERAL_LIMIT)
			fatal("incompressible file. %u byte literal block generated", length);
		output_bit(ctx, 1);
		// Leave the odd data bits on the stream, they'll be reused later on
		for(bit = 0; bit < 7; ++bit)
			output_bits_at(ctx, 1, 1, bit);
		output_bits_at(ctx, 0, 1, bit);
		// Store a raw 16-bit length for the unrolled copying loop
		*output_word(ctx) = length >> 1;
		// Include the final odd bit as usual
		output_bit(ctx, length);
	}

	// First write the bulk of the literals in 16-bit byte pairs
	data = &ctx->src_data[cursor];
	while(length >= 2) {
		unsigned short *ptr = output_word(ctx);
		*ptr = *data++ << 8;
		*ptr |= *data++ << 0;
		length -= 2;
	}
	// Write the final odd byte on a separate stream
	if(length & 1)
		output_literal(ctx, *data);
}

static inline void encode_match (
	lz_context *ctx,
	signed offset,
	unsigned length
) {
	unsigned offset_prefix;
	const offset_length_t *offset_class;
	signed length_bit;

	++ctx->stats.match_count;
	ctx->stats.match_bytes += length;
	ctx->stats.offset_distance += offset;

	output_flush(ctx);

	// Write offset prefix
	if(length == 2) {
		assert(offset <= cfg_short_limit);
		offset_prefix = 0;
		offset_class = cfg_short_offset;

		while(offset > offset_class->limit) {
			++offset_class;
			++offset_prefix;
		}

		++ctx->stats.short_freq[offset_prefix];
	} else {
		assert(offset <= cfg_long_limit);
		offset_prefix = 0;
		offset_class = cfg_long_offset;

		while(offset > offset_class->limit) {
			++offset_class;
			++offset_prefix;
		}

		++ctx->stats.long_freq[offset_prefix];
	}

	// Include the initial length bit in the prefix code
	length_bit = _log2(--length);
	offset_prefix <<= 1;
	if(length_bit)
		++offset_prefix;
	output_bits(ctx, offset_prefix, 3);

	// Write offset payload
	offset -= offset_class->base;
	output_bits(ctx, offset, offset_class->bits);

	output_flush(ctx);

	// Write out the remaining length bits
	while(length_bit--) {
		output_bit(ctx, !!length_bit);
		output_bit(ctx, length >> length_bit);
	}
}

static inline void write_output(lz_context *ctx, bool show_trace) {
	unsigned cursor;
	unsigned literals;

	bool implicit = true;
	unsigned src_end = ctx->src_end;
	lz_info *info = ctx->info;
	signed length;

	unsigned expected = info[ctx->src_begin].cumulative_cost;

	// Sum up all of the unaligned literal bytes in a pre-pass
	literals = 0;
	for(cursor = ctx->src_begin; cursor < src_end; cursor += length) {
		length = info[cursor].match_length;
		if(length < 0) {
			length = -length;
			literals += length & 1;
		}
	}

	// Allocate and seed the output buffers
	expected = output_init(ctx, expected, literals);

	// Encode all of the matches and literals 
	for(cursor = ctx->src_begin; cursor < src_end; cursor += length) {
		length = info[cursor].match_length;

		if(length > 0) {
			unsigned offset;

			if(!implicit)
				output_bit(ctx, 0);

			offset = info[cursor].match_offset;
			encode_match(ctx, offset, length);

			if(show_trace) {
				printf (
					"$%04x %smatch(-%u/$%04x, %u bytes)\n",
					cursor,
					implicit ? "" : "explicit-",
					offset,
					cursor - offset,
					length
				);
			}

			implicit = false;
		} else {
			length = -length;

			if(!implicit)
				output_bit(ctx, 1);
			encode_literals(ctx, cursor, length);

			if(show_trace) {
				printf (
					"$%04x literal(%u bytes)\n",
					cursor,
					length
				);
			}

			implicit = true;
		}
	}

	if(!implicit)
		output_bit(ctx, 0);

	// The model must match the real length to the bit in order for the bit-stream
	// to be aligned at the end
	(void) output_bitsize(ctx);
	// The sentinel ought to just have been shifted in
	if(ctx->dst_bitbuf[16].ptr || !ctx->dst_bitbuf[17].ptr)
		fatal("improper bit-stream alignment");
}


/******************************************************************************
 * Parse out the set of offset bit lengths from a descriptor string
 ******************************************************************************/
static void prepare_offset_lengths(offset_length_t *table, size_t count) {
	unsigned base;
	unsigned limit = 0;
	unsigned previous = 0;

	do {
		unsigned int bits = table->bits;

		if(bits <= previous)
			fatal("offset lengths must be listed in ascending order");
		previous = bits;
		if(bits < OFFSET_LENGTH_MIN)
			fatal("offset lengths cannot be narrower than %u bits", OFFSET_LENGTH_MIN);
		if(bits > OFFSET_LENGTH_MAX)
			fatal("offset lengths cannot be wider than %u bits", OFFSET_LENGTH_MAX);

		base = limit + 1;
		limit += 1 << bits;
		table->base = base;
		table->limit = limit;
		++table;
	} while(--count);
}

static inline bool parse_offset_lengths(const char *text) {
	if(sscanf(text, "%u/%u/%u/%u:%u/%u/%u/%u",
		&cfg_short_offset[0].bits, &cfg_short_offset[1].bits,
		&cfg_short_offset[2].bits, &cfg_short_offset[3].bits,
		&cfg_long_offset[0].bits, &cfg_long_offset[1].bits,
		&cfg_long_offset[2].bits, &cfg_long_offset[3].bits) != 8) {
		return false;
	}
	prepare_offset_lengths(cfg_short_offset, 4);
	prepare_offset_lengths(cfg_long_offset, 4);
	return true;
}


/******************************************************************************
 * Print some basic statistics about the encoding of the file
 ******************************************************************************/
static inline void print_statistics(const lz_context *ctx, FILE *file) {
	unsigned input_size = ctx->src_end - ctx->src_begin;

	fprintf (
		file,
		"input file:\t"    "%u bytes\n"
		"output file:\t"   "%u bytes, %u bits (%.2f%% ratio)\n"
		"short offsets:\t" "{ %u-%u: %u, %u-%u: %u, %u-%u: %u, %u-%u: %u }\n"
		"long offsets:\t"  "{ %u-%u: %u, %u-%u: %u, %u-%u: %u, %u-%u: %u }\n"
		"%u matches:\t"    "%u bytes, %f avg\n"
		"%u literals:\t"   "%u bytes, %f avg\n"
		"avg offset:\t"    "%f bytes\n",

		input_size,
		ctx->stats.output_size,
		ctx->stats.output_bits,
		100.0 * ctx->stats.output_size / input_size,

		cfg_short_offset[0].base,
		cfg_short_offset[0].limit,
		ctx->stats.short_freq[0],
		cfg_short_offset[1].base,
		cfg_short_offset[1].limit,
		ctx->stats.short_freq[1],
		cfg_short_offset[2].base,
		cfg_short_offset[2].limit,
		ctx->stats.short_freq[2],
		cfg_short_offset[3].base,
		cfg_short_offset[3].limit,
		ctx->stats.short_freq[3],
		cfg_long_offset[0].base,
		cfg_long_offset[0].limit,
		ctx->stats.long_freq[0],
		cfg_long_offset[1].base,
		cfg_long_offset[1].limit,
		ctx->stats.long_freq[1],
		cfg_long_offset[2].base,
		cfg_long_offset[2].limit,
		ctx->stats.long_freq[2],
		cfg_long_offset[3].base,
		cfg_long_offset[3].limit,
		ctx->stats.long_freq[3],

		ctx->stats.match_count,
		ctx->stats.match_bytes,
		(double) ctx->stats.match_bytes / ctx->stats.match_count,

		ctx->stats.literal_runs,
		ctx->stats.literal_bytes,
		(double) ctx->stats.literal_bytes / ctx->stats.literal_runs,

		(double) ctx->stats.offset_distance / ctx->stats.match_count
	);
}


/******************************************************************************
 * The main function
 ******************************************************************************/
int
#ifdef _MSC_VER
__cdecl
#endif
main(int argc, char *argv[]) {
	const char *input_name;
	unsigned name_length;
	unsigned i;

	lz_context ctx;

	// Parse the command line
	const char *program_name = *argv;
	char *output_name = NULL;
	bool show_stats = false;
	bool show_trace = false;
	memset(&ctx, 0, sizeof ctx);
	parse_offset_lengths(DEFAULT_LENGTHS);

	while(++argv, --argc) {
		if(argc >= 2 && !strcmp(*argv, "-o")) {
			output_name = *++argv;
			--argc;
		} else if(argc >= 2 && !strcmp(*argv, "--offset-lengths")) {
			if(!parse_offset_lengths(*++argv))
				break;
			--argc;
		} else if(!strcmp(*argv, "--statistics")) {
			show_stats = true;
		} else if(!strcmp(*argv, "--trace-coding")) {
			show_trace = true;
		} else {
			break;
		}
	}

	if(argc != 1) {
		fprintf (
			stderr,
			"syntax: %s\n"
			"\t[-o output.lz]\n"
			"\t[--offset-lengths s1/s2/s3/s4:l1/l2/l3/l4]\n"
			"\t[--statistics]\n"
			"\t[--trace-coding]\n"
			"\t{input.bin}\n",
			program_name
		);
		return EXIT_FAILURE;
	}

	input_name = *argv;

	// Check extension to figure out whether it's a .PRG file
	name_length = 0;

	for(i = 0; input_name[i]; ++i) {
		switch(input_name[i]) {
		case '/':
		case '\\':
		case ':':
			name_length = 0;
			break;
		case '.':
			name_length = i;
			break;
		}
	}

	if(!name_length)
		name_length = i;

	// If necessary generate output file by substituting the
	// extension for .lz
	if(!output_name) {
		static const char extension[] = ".lz";

		output_name = alloca(name_length + sizeof extension);

		memcpy(output_name, input_name, name_length);
		memcpy(&output_name[name_length], extension, sizeof extension);
	}

	// Do the compression
	read_input(&ctx, input_name);
	generate_hash_table(&ctx);
	find_matches(&ctx);

	write_output(&ctx, show_trace);
	output_write(&ctx, output_name);

	// Display some statistics gathered in the process
	if(show_stats)
		print_statistics(&ctx, stdout);
	return EXIT_SUCCESS;
}
