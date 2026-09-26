# makefile for newLISP v.10.x.x on LINUX as a shared library - newlisp.so -
#
# Note, that readline support may require different libraries on different OSs
# 

OBJS = obj/newlisp.o obj/nl-symbol.o obj/nl-math.o obj/nl-list.o obj/nl-liststr.o obj/nl-string.o obj/nl-filesys.o \
	obj/nl-sock.o obj/nl-import.o obj/nl-xml-json.o obj/nl-web.o obj/nl-matrix.o obj/nl-debug.o obj/nl-utf8.o obj/pcre.o obj/nl-vm.o obj/unix-lib.o

CFLAGS = -m32 -Wall -Wno-uninitialized -Wno-strict-aliasing -Wno-long-long -c -O3 -DLIBRARY -DSUPPORT_UTF8 -DLINUX -Ipcre

CC = gcc

default: $(OBJS)
	$(CC) $(OBJS) -m32 -lm -ldl -shared -o newlisp.so
	strip newlisp.so

obj:
	mkdir -p obj

obj/%.o: %.c | obj
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJS): primes.h protos.h newlisp.h nl-vm.h makefiles/linux_lib_utf8.mk




VPATH = src pcre
