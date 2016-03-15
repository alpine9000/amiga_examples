// Copyright 1999-2015 Aske Simon Christensen. See LICENSE.txt for usage terms.

/*

Decoder for the LZ encoder.

*/

#pragma once

#include "Decoder.h"
#include "LZEncoder.h"

class LZReceiver {
public:
	virtual bool receiveLiteral(unsigned char value) = 0;
	virtual bool receiveReference(int offset, int length) = 0;
	virtual ~LZReceiver() {}
};

class LZDecoder {
	Decoder *decoder;

	int decode(int context) const {
		return decoder->decode(LZEncoder::NUM_SINGLE_CONTEXTS + context);
	}

	int decodeNumber(int context_group) const {
		return decoder->decodeNumber(LZEncoder::NUM_SINGLE_CONTEXTS + (context_group << 8));
	}

public:
	LZDecoder(Decoder *decoder) : decoder(decoder) {

	}

	bool decode(LZReceiver& receiver) {
		bool ref = false;
		bool prev_was_ref = false;
		int pos = 0;
		int offset = 0;
		do {
			if (ref) {
				bool repeated = false;
				if (!prev_was_ref) {
					repeated = decode(LZEncoder::CONTEXT_REPEATED);
				}
				if (!repeated) {
					offset = decodeNumber(LZEncoder::CONTEXT_GROUP_OFFSET) - 2;
					if (offset == 0) break;
				}
				int length = decodeNumber(LZEncoder::CONTEXT_GROUP_LENGTH);
				if (!receiver.receiveReference(offset, length)) return false;
				pos += length;
				prev_was_ref = true;
			} else {
				int parity = pos & 1;
				int context = 1;
				for (int i = 7 ; i >= 0 ; i--) {
					int bit = decode((parity << 8) | context);
					context = (context << 1) | bit;
				}
				unsigned char lit = context;
				if (!receiver.receiveLiteral(lit)) return false;
				pos += 1;
				prev_was_ref = false;
			}
			int parity = pos & 1;
			ref = decode(LZEncoder::CONTEXT_KIND + (parity << 8));
		} while (true);
		return true;
	}

};
