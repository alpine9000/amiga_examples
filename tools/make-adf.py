#! /usr/bin/env python

DISKSIZE = 512 * 11 * 2 * 80

def concat(out, fn):
	f = open(fn, 'rb')
	d = f.read()
	f.close()
	if len(d) % 512 != 0:
		d = d + '\0' * (512-(len(d)%512))
	print('placing %s (%d bytes, %d secs) at pos %d (sector %d)' % (fn, len(d), len(d)/512, out.tell(), out.tell()/512))
	out.write(d)

if __name__ == '__main__':

	import sys

	output = sys.argv[1]
	bootblock = sys.argv[2]
	files = sys.argv[3:]

	out = open(output, 'wb')
	concat(out, bootblock)

	for f in files:
		concat(out,f)

	diff = DISKSIZE - out.tell()

	if diff < 0:
		sys.stderr.write('too big! %d bytes over budget' % (diff))
		sys.exit(1)

	out.write('\0' * diff)
	
	out.close()

