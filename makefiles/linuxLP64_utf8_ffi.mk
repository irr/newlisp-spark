# makefile for newLISP 64bit UTF-8 v.10.x.x on 64 bit LINUX tested on Intel Core Duo 2
# and FFI
# Note, that readline support may require different libraries on different OSs
#

OBJS = obj/newlisp.o obj/nl-symbol.o obj/nl-math.o obj/nl-list.o obj/nl-liststr.o obj/nl-string.o obj/nl-filesys.o \
	obj/nl-sock.o obj/nl-import.o obj/nl-xml-json.o obj/nl-web.o obj/nl-matrix.o obj/nl-debug.o obj/nl-utf8.o obj/pcre.o obj/nl-vm.o

CFLAGS = -fPIC -m64 -Wall -Wno-uninitialized -Wno-strict-aliasing -Wno-long-long -c -O3 -g -DREADLINE -DSUPPORT_UTF8 -DNEWLISP64 -DLINUX -DFFI -I/usr/local/lib/libffi-3.0.13/include  -Ipcre

# replace -O3 with -Oz when using clang/llvm
#CC = clang 

CC = gcc

default: $(OBJS)
	$(CC) $(OBJS) -m64 -g -lm -ldl -lreadline -lffi -o newlisp # for UBUNTU Debian
#	$(CC) $(OBJS) -m64 -g -lm -ldl -lreadline -ltermcap -o newlisp # slackware
#	$(CC) $(OBJS) -m64 -g -lm -ldl -lreadline -lncurses -o newlisp # other Linux Dist
#	$(CC) $(OBJS) -m64 -g -lm -ldl -o newlisp # without readline support
	strip newlisp

obj:
	mkdir -p obj

obj/%.o: %.c | obj
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJS): primes.h protos.h makefiles/linuxLP64_utf8_ffi.mk

VPATH = src pcre
