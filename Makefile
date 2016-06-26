.PHONY: all check clean depend dist doc install uninstall test

PROJECT  = lua-haproxy
PACKAGE  = haproxy
VERSION := $(shell git describe --always --dirty)
RELEASE  = $(PROJECT)-api-$(VERSION)
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
	cd build && $(AMALG) -s main.lua -a -c -x | sed 's|$(PWD)||g' > $(RELEASE).lua
	cd build && ln -sf $(RELEASE).lua $(PROJECT)-api-latest.lua

check:
	luacheck lua/

clean:
	$(RM) $(ROCK)
	$(RM) -r build
	$(RM) -r dist

depend:
	$(LUAROCKS) install dkjson
	$(LUAROCKS) install luafilesystem
	$(LUAROCKS) install penlight
	$(LUAROCKS) install router

dist: all $(ROCK)
	mkdir -p dist
	tar -czf dist/$(BUILD).tar.gz -C build $(RELEASE).lua
	mv $(ROCK) dist/$(ROCK)

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
