#! /usr/bin/env python

import sys
import struct

def splice_checksum(block, chksum):
	return block[0:4] + struct.pack('>I', chksum) + block[8:]

def makeit(fn, ofn):
	with open(fn, 'rb') as f: data = f.read()

	data = data + '\0' * (1024 - len(data))
	
	chksum = 0
	for w in xrange(0, 1024, 4):
		chksum += struct.unpack('>I', data[w:w+4])[0]
		if chksum > 0xffffffff:
			chksum = (chksum + 1) & 0xffffffff

	chksum = (~chksum) & 0xffffffff
	
	data2 = splice_checksum(data, chksum)
	
	with open(ofn, 'wb') as f: f.write(data2)

if len(sys.argv) == 3:
	makeit(sys.argv[1], sys.argv[2])
else:
	sys.stderr.write('need two args\n')
