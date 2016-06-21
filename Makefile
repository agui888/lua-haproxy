.PHONY: all doc dist install test

PROJECT  = haproxy.lua
PACKAGE  = haproxy
VERSION := $(shell git describe --always --dirty)
RELEASE  = $(PACKAGE)-$(VERSION)
OS      := $(shell uname -s | tr [:upper:] [:lower:])
ARCH    := $(shell uname -m)
BUILD    = $(RELEASE)-$(OS)-$(ARCH)

ROCKSPEC     = $(PACKAGE)-scm-0.rockspec
ROCK         = $(basename $(ROCKSPEC)).all.rock

PWD	     := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
LUA      := $(PWD)/vendor/bin/lua
LUAROCKS := $(PWD)/vendor/bin/luarocks
AMALG    := $(PWD)/vendor/bin/amalg.lua

export LUA_PATH  := $(shell $(LUAROCKS) path --lr-path);;
export LUA_CPATH := $(shell $(LUAROCKS) path --lr-cpath);;

all:
	mkdir -p build
	cp -r lua/* build
	cd build && $(LUA) -l amalg main.lua
	cd build && $(AMALG) -s main.lua -a -c -x | sed '/amalg: start/,/amalg: end/d' | sed 's|$(PWD)||g' > $(RELEASE).lua
	cd build && ln -sf $(RELEASE).lua haproxy-latest.lua

clean:
	$(RM) $(ROCK)
	$(RM) -r build

depend:
	$(LUAROCKS) install luafilesystem
	$(LUAROCKS) install penlight
	$(LUAROCKS) install router

dist: all
	mkdir -p dist
	tar -czf dist/$(BUILD).tar.gz -C build $(RELEASE).lua

$(ROCK):
	luarocks make --pack-binary-rock

clean:
	$(RM) -r dist/

dist: $(ROCK)
	mkdir -p dist/
	mv $(ROCK) dist/$(ROCK)

install:
	luarocks make install

uninstall:
	luarocks remove $(PACKAGE)

doc:
	ldoc .

test:
	busted
