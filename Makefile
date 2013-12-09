.PHONY: clean test install uninstall

dist/build/lib-crc/crc.cmxa:
	obuild configure --enable-tests
	obuild build

clean:
	rm -rf dist

test:
	obuild test --output

install:
	ocamlfind install crc lib/META $(wildcard dist/build/lib-crc/*)

uninstall:
	ocamlfind remove crc
