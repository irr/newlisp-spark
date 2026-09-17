# makefile for newLISP 64bit v.10.x.x on 64 bit LINUX tested on Intel Dual Core 2 as a shared library
#
# Note, that readline support may require different libraries on different OSs
#

OBJS = obj/newlisp.o obj/nl-symbol.o obj/nl-math.o obj/nl-list.o obj/nl-liststr.o obj/nl-string.o obj/nl-filesys.o \
	obj/nl-sock.o obj/nl-import.o obj/nl-xml-json.o obj/nl-web.o obj/nl-matrix.o obj/nl-debug.o obj/pcre.o obj/nl-vm.o obj/unix-lib.o

CFLAGS = -fPIC -m64 -Wall -Wno-uninitialized -Wno-strict-aliasing -Wno-long-long -c -O3 -g -DLINUX -DNEWLISP64 -DLIBRARY -Ipcre

CC = gcc

default: $(OBJS)
	$(CC) $(OBJS) -m64 -g -lm -ldl -shared -o newlisp.so
	strip newlisp.so

obj:
	mkdir -p obj

obj/%.o: %.c | obj
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJS): primes.h protos.h makefiles/linuxLP64_lib.mk

VPATH = src pcre
