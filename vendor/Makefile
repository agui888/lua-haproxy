.PHONY: all clean cleanall

HAPROXY_VERSION     = 1.6.5
HAPROXY             = haproxy-$(HAPROXY_VERSION)
HAPROXY_URL         = http://www.haproxy.org/download/$(basename $(HAPROXY_VERSION))
HAPROXY_BUILD_FLAGS = USE_LUA=1 LUA_LIB=$(PWD)/lib LUA_INC=$(PWD)/include

LUA_VERSION = 5.3.3
LUA         = lua-$(LUA_VERSION)
LUA_URL     = https://www.lua.org/ftp

LUAROCKS_VERSION = 2.3.0
LUAROCKS         = luarocks-$(LUAROCKS_VERSION)
LUAROCKS_URL     = https://keplerproject.github.io/luarocks/releases

LUA_AMALG_VERSION = 100d5e2c0203b76cc4969fd758cdf19d23fd4993
LUA_AMALG         = lua-amalg-$(LUA_AMALG_VERSION)
LUA_AMALG_URL     = https://github.com/siffiejoe/lua-amalg/archive/$(LUA_AMALG_VERSION).tar.gz

UNAME := $(shell uname -s)
PWD	  := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
WGET   = wget -nc
MKDIR  = mkdir -p

ifeq ($(UNAME),Linux)
	LUA_PLATFORM   = linux
	HAPROXY_TARGET = linux2628
endif
ifeq ($(UNAME),Darwin)
	LUA_PLATFORM         = macosx
	HAPROXY_TARGET       = osx
	# On OS X, libcrypt is built into unistd.
	HAPROXY_BUILD_FLAGS += USE_LIBCRYPT=
	# OS X uses BSD ld. --export-dynamic corresponds to -export_dynamic.
	HAPROXY_BUILD_FLAGS += LUA_LD_FLAGS="-Wl,-export_dynamic -L$(PWD)/lib"
endif

all: sbin/haproxy bin/luarocks bin/amalg.lua

bin/amalg.lua: src/$(LUA_AMALG)
	cd src/$(LUA_AMALG) && $(PWD)/bin/luarocks install amalg-scm-0.rockspec

bin/lua: src/$(LUA)
	$(MAKE) -C $< $(LUA_PLATFORM)
	$(MAKE) -C $< install INSTALL_TOP=$(PWD)

bin/luarocks: src/$(LUAROCKS)
	cd src/$(LUAROCKS) && ./configure --prefix=$(PWD) --with-lua=$(PWD) --force-config
	$(MAKE) -C $< build
	$(MAKE) -C $< install

clean:
	-$(MAKE) -C src/$(HAPROXY) clean
	-$(MAKE) -C src/$(LUA) clean
	-$(MAKE) -C src/$(LUAROCKS) clean
	$(RM) -r bin etc doc include lib man sbin share

cleanall: clean
	$(RM) -r src

sbin/haproxy: src/$(HAPROXY) bin/lua
	$(MAKE) -C $< TARGET=$(HAPROXY_TARGET) $(HAPROXY_BUILD_FLAGS)
	$(MAKE) -C $< install PREFIX= DESTDIR=$(PWD)

src:
	$(MKDIR) src

src/$(LUA_AMALG): %: %.tar.gz
	tar -xzf $< -C src

src/$(LUA_AMALG).tar.gz: src
	$(WGET) -P $< -O $@ $(LUA_AMALG_URL)
	grep $@ SHA256SUMS | sha256sum -c

src/$(HAPROXY): %: %.tar.gz
	tar -xzf $< -C src

src/$(HAPROXY).tar.gz: src
	$(WGET) -P $< $(HAPROXY_URL)/$@
	grep $@ SHA256SUMS | sha256sum -c

src/$(LUA): %: %.tar.gz
	tar -xzf $< -C src

src/$(LUA).tar.gz: src
	$(WGET) -P $< $(LUA_URL)/$(notdir $@)
	grep $@ SHA256SUMS | sha256sum -c

src/$(LUAROCKS): %: %.tar.gz
	tar -xzf $< -C src

src/$(LUAROCKS).tar.gz: src
	$(WGET) -P $< $(LUAROCKS_URL)/$(notdir $@)
	grep $@ SHA256SUMS | sha256sum -c
