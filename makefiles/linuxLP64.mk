# makefile for newLISP 64bit v.10.x.x on 64 bit LINUX tested on Intel Core Duo 2
#
# Note, that readline support may require different libraries on different OSs
#

OBJS = obj/newlisp.o obj/nl-symbol.o obj/nl-math.o obj/nl-list.o obj/nl-liststr.o obj/nl-string.o obj/nl-filesys.o \
	obj/nl-sock.o obj/nl-import.o obj/nl-xml-json.o obj/nl-web.o obj/nl-matrix.o obj/nl-debug.o obj/pcre.o obj/nl-vm.o

CFLAGS = -fPIC -m64 -Wall -Wno-uninitialized -Wno-strict-aliasing -Wno-long-long -c -O3 -g -DREADLINE -DNEWLISP64 -DLINUX -Ipcre

CC = gcc

default: $(OBJS)
	$(CC) $(OBJS) -m64 -g -lm -ldl -lreadline -o newlisp # for UBUNTU Debian
#	$(CC) $(OBJS) -m64 -g -lm -ldl -lreadline -ltermcap -o newlisp # slackware
#	$(CC) $(OBJS) -m64 -g -lm -ldl -lreadline -lncurses -o newlisp # other Linux Dist
#	$(CC) $(OBJS) -m64 -g -lm -ldl -o newlisp # without readline support
	strip newlisp

obj:
	mkdir -p obj

obj/%.o: %.c | obj
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJS): primes.h protos.h makefiles/linuxLP64.mk

VPATH = src pcre
