NAME = same
CC=gcc
CFLAGS=-I. -lcurses
# same.h defines its globals in the header itself, which GCC 10 and newer
# refuse to link twice without -fcommon
COMMON=-fcommon
DEPS = src/same.h
OBJECTS = src/same.o src/common.o src/draw.o src/flags.o src/graphics.o src/hst.o src/endgame.o src/save.o src/highlight.o src/board.o src/command.o src/init.o src/scripts.o src/sysdep.o

.PHONY: clean make install uninstall

%.o: %.c $(DEPS)
	$(CC) $(COMMON) -c -o $@ $<

$(NAME): $(OBJECTS)
	$(CC) -o $@ $^ $(CFLAGS)

install:
	cp $(NAME) /usr/bin

uninstall:
	rm /usr/bin/$(NAME)

clean:
	rm -f $(OBJECTS) $(NAME)

