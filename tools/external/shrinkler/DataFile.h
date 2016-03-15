// Copyright 1999-2015 Aske Simon Christensen. See LICENSE.txt for usage terms.

/*

Operations on raw data files, including loading, crunching and saving.

*/

#pragma once

#include <cstring>
#include <algorithm>
#include <string>
#include <utility>
#include <algorithm>

using std::make_pair;
using std::max;
using std::min;
using std::pair;
using std::string;

#include "AmigaWords.h"
#include "Pack.h"
#include "RangeDecoder.h"

class DataFile {
	vector<unsigned char> data;

	vector<unsigned> compress(PackParams *params, RefEdgeFactory *edge_factory, bool show_progress) {
		vector<unsigned> pack_buffer;
		RangeCoder *range_coder = new RangeCoder(LZEncoder::NUM_CONTEXTS + NUM_RELOC_CONTEXTS, pack_buffer);

		// Print compression status header
		const char *ordinals[] = { "st", "nd", "rd", "th" };
		printf("Original");
		for (int p = 1 ; p <= params->iterations ; p++) {
			printf("  After %d%s pass", p, ordinals[min(p,4)-1]);
		}
		printf("\n");

		// Crunch the data
		range_coder->reset();
		packData(&data[0], data.size(), 0, params, range_coder, edge_factory, show_progress);
		range_coder->finish();
		printf("\n\n");
		fflush(stdout);

		return pack_buffer;		
	}

	void verify(vector<unsigned>& pack_buffer) {
		printf("Verifying... ");
		fflush(stdout);
		RangeDecoder decoder(LZEncoder::NUM_CONTEXTS + NUM_RELOC_CONTEXTS, pack_buffer);
		LZDecoder lzd(&decoder);

		// Verify data
		bool error = false;
		LZVerifier verifier(0, &data[0], data.size(), data.size());
		decoder.reset();
		decoder.setListener(&verifier);
		if (!lzd.decode(verifier)) {
			error = true;
		}

		// Check length
		if (!error && verifier.size() != data.size()) {
			printf("Verify error: data has incorrect length (%d, should have been %d)!\n", verifier.size(), (int) data.size());
			error = true;
		}

		if (error) {
			internal_error();
		}

		printf("OK\n\n");
	}

public:
	void load(const char *filename) {
		FILE *file;
		if ((file = fopen(filename, "rb"))) {
			fseek(file, 0, SEEK_END);
			int length = ftell(file);
			fseek(file, 0, SEEK_SET);
			data.resize(length);
			if (fread(&data[0], 1, data.size(), file) == data.size()) {
				fclose(file);
				return;
			}
		}

		printf("Error while reading file %s\n\n", filename);
		exit(1);
	}

	void save(const char *filename) {
		FILE *file;
		if ((file = fopen(filename, "wb"))) {
			if (fwrite(&data[0], 1, data.size(), file) == data.size()) {
				fclose(file);
				return;
			}
		}

		printf("Error while writing file %s\n\n", filename);
		exit(1);
	}

	int size() {
		return data.size();		
	}

	DataFile* crunch(PackParams *params, RefEdgeFactory *edge_factory, bool show_progress) {
		vector<unsigned> pack_buffer = compress(params, edge_factory, show_progress);
		verify(pack_buffer);

		DataFile *ef = new DataFile;
		ef->data.resize(pack_buffer.size() * 4, 0);

		Longword* dest = (Longword*) (void*) &ef->data[0];
		for (int i = 0 ; i < pack_buffer.size() ; i++) {
			dest[i] = pack_buffer[i];
		}

		return ef;
	}
};
