.PHONY: all doc install test

PROJECT  = haproxy.lua
PACKAGE  = haproxy
ROCKSPEC = haproxy-scm-0.rockspec
MODULES := $(shell script/deps.sh)
TARGET  := dist/$(PROJECT)
ROCK     = $(basename $(ROCKSPEC)).all.rock

ifeq ($(DEBUG),)
DEBUG_FLAGS   =
DEBUG_MODULES =
else
DEBUG_FLAGS   = -d
DEBUG_MODULES = pl.pretty pl.lexer
endif

all: $(TARGET)

$(TARGET):
	mkdir -p dist/
	cd src && amalg.lua -a $(DEBUG_FLAGS) -o ../$@ -s main.lua -- $(MODULES) $(DEBUG_MODULES)

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
