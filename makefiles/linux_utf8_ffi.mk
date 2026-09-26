# makefile for newLISP v.10.x.x on LINUX with readline, UTF-8, FFI support
#
# Note, that readline support may require different libraries on different OSs
# 

OBJS = obj/newlisp.o obj/nl-symbol.o obj/nl-math.o obj/nl-list.o obj/nl-liststr.o obj/nl-string.o obj/nl-filesys.o \
	obj/nl-sock.o obj/nl-import.o obj/nl-xml-json.o obj/nl-web.o obj/nl-matrix.o obj/nl-debug.o obj/nl-utf8.o obj/pcre.o obj/nl-vm.o

CFLAGS = -fPIC -m32 -Wall -Wno-strict-aliasing -Wno-long-long -c -O3 -g -DREADLINE -DSUPPORT_UTF8 -DLINUX -DFFI -I/usr/local/lib/libffi-3.0.13/include -Ipcre

CC = gcc

default: $(OBJS)
	$(CC) $(OBJS) -m32 -g -lm -ldl -lreadline -lffi -o newlisp # for UBUNTU Debian
#	$(CC) $(OBJS) -m32 -g -lm -ldl -lreadline -ltermcap -o newlisp # slackware
#	$(CC) $(OBJS) -m32 -g -lm -ldl -lreadline -lncurses -o newlisp # other Linux Dist
#	$(CC) $(OBJS) -m32 -g -lm -ldl -o newlisp # without readline support
	strip newlisp

obj:
	mkdir -p obj

obj/%.o: %.c | obj
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJS): primes.h protos.h newlisp.h nl-vm.h makefiles/linux_utf8_ffi.mk




VPATH = src pcre
