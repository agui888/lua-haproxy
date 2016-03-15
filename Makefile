.PHONY: all doc install test

PROJECT  = haproxy.lua
PACKAGE  = haproxy
ROCKSPEC = haproxy-scm-0.rockspec
ROCK     = $(basename $(ROCKSPEC)).all.rock

all: $(ROCK)

clean:
	$(RM) $(ROCK)

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
