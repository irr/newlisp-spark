# makefile for newLISP v.10.x.x on LINUX RedHat CentOS with readline, UTF-8, FFI support
#
# don't use this make file directly. Use ./configure to detect and replace the correct
# libffi version

OBJS = obj/newlisp.o obj/nl-symbol.o obj/nl-math.o obj/nl-list.o obj/nl-liststr.o obj/nl-string.o obj/nl-filesys.o \
	obj/nl-sock.o obj/nl-import.o obj/nl-xml-json.o obj/nl-web.o obj/nl-matrix.o obj/nl-debug.o obj/nl-utf8.o obj/pcre.o obj/nl-vm.o

CFLAGS = -m32 -Wall -Wno-strict-aliasing -Wno-long-long -c -O3 -g -DREADLINE -DSUPPORT_UTF8 -DLINUX -DFFI -ILIBFFI_VERSION -Ipcre

CC = gcc

default: $(OBJS)
	$(CC) $(OBJS) -m32 -g -lm -ldl -lreadline -lffi -o newlisp # for RedHat CentOS 
	strip newlisp

obj:
	mkdir -p obj

obj/%.o: %.c | obj
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJS): primes.h protos.h newlisp.h nl-vm.h makefiles/linux_redhat_utf8_ffi.mk




VPATH = src pcre
