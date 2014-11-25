all: build

TESTS_FLAG=--enable-tests

NAME=crc
J=4

LIBDIR=_build/lib

setup.data: setup.ml
	ocaml setup.ml -configure $(TESTS_FLAG)

build: setup.data setup.ml
	ocaml setup.ml -build -j $(J)

doc: setup.data setup.ml
	ocaml setup.ml -doc -j $(J)

install: setup.data setup.ml
	ocaml setup.ml -install

uninstall:
	ocamlfind remove $(NAME)

test: setup.ml build
	LD_LIBRARY_PATH=$(LIBDIR):$(LD_LIBRARY_PATH) ./crc_test.byte
#	ocaml setup.ml -test

reinstall: setup.ml
	ocamlfind remove $(NAME) || true
	ocaml setup.ml -reinstall

clean:
	ocamlbuild -clean
	rm -f setup.data setup.log
