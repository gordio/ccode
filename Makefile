#!/usr/bin/make -f
PROJNAME := ccode
CFILES   := $(wildcard src/*.c)
OBJECTS  := $(CFILES:.c=.o)
PREFIX   := /usr/local

CFLAGS += -I$(shell llvm-config --includedir) -std=gnu99

LDFLAGS += -L$(shell llvm-config --libdir) -lclang

.SUFFIXES: .a .c .h .o
.PHONY: all static clear clean install uninstall types


all: $(OBJECTS)
	@echo "\033[1;32m LINK\033[0m" $(PROJNAME)
	@$(CC) $(LDFLAGS) $(OBJECTS) -o "$(PROJNAME)"


%.o: %.c %.h
	@echo "\033[1m   CC\033[0m" $@ "<-" $<
	@$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c
	@echo "\033[1m   CC\033[0m" $@ "<-" $<
	@$(CC) $(CFLAGS) -c $< -o $@

clear:
	@echo "\033[1;31m   RM\033[0m" $(OBJECTS)
	@rm -f $(OBJECTS)

clean: clear
	@echo "\033[1;31m   RM\033[0m" "$(PROJNAME)"
	@rm -f "$(PROJNAME)"

install:
	install -m 755 "$(PROJNAME)" "$(PREFIX)/bin/"

uninstall:
	rm "$(PREFIX)/bin/$(PROJNAME)"

types: types.vim
types.vim: src/*.[ch]
	@echo -e "\033[1m MAKE\033[0m" types.vim
	@exuberant-ctags --c-kinds=gstu -o- src/*.[ch] |\
		awk 'BEGIN{echo -e("syntax keyword Type\t")}\
			{echo -e("%s ", $$1)}END{print ""}' > $@
