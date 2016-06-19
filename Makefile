.PHONY: all doc dist install test

PROJECT  = haproxy.lua
PACKAGE  = haproxy
VERSION := $(shell git describe --always --dirty)
RELEASE  = $(PACKAGE)-$(VERSION)
OS      := $(shell uname -s | tr [:upper:] [:lower:])
ARCH    := $(shell uname -m)
BUILD    = $(RELEASE)-$(OS)-$(ARCH)

ROCKSPEC = $(PACKAGE)-scm-0.rockspec
ROCK     = $(basename $(ROCKSPEC)).all.rock

all: $(ROCK)
	mkdir -p build
	cp -r lua/* build
	cd build && lua -lamalg main.lua
	cd build && amalg.lua -o $(RELEASE).lua -s main.lua -a -c -x

clean:
	$(RM) $(ROCK)

dist: all
	mkdir -p dist
	tar -czf dist/$(BUILD).tar.gz -C build $(RELEASE).lua

$(ROCK):
	luarocks make --pack-binary-rock

install:
	luarocks make install

uninstall:
	luarocks remove $(PACKAGE)

doc:
	ldoc .

test:
	busted
