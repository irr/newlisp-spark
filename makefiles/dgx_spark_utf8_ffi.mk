# makefile for newLISP 64bit UTF-8 v.10.x.x on 64 bit LINUX ARM (aarch64)
# for NVIDIA DGX Spark (Grace CPU, Ubuntu)
# and FFI
# Note, that readline support may require different libraries on different OSs
#
# USAGE: make -f makefiles/dgx_spark_utf8_ffi.mk
# TEST:  make -f makefiles/dgx_spark_utf8_ffi.mk test

OBJS = obj/newlisp.o obj/nl-symbol.o obj/nl-math.o obj/nl-list.o obj/nl-liststr.o obj/nl-string.o obj/nl-filesys.o \
	obj/nl-sock.o obj/nl-import.o obj/nl-xml-json.o obj/nl-web.o obj/nl-matrix.o obj/nl-debug.o obj/nl-utf8.o obj/pcre.o obj/nl-vm.o

# aarch64 is 64-bit native, no -m64 flag needed; -mcpu=native tunes for Grace
CFLAGS = -fPIC -mcpu=native -Wall -Wno-uninitialized -Wno-strict-aliasing -Wno-long-long -c -O3 -g -DREADLINE -DSUPPORT_UTF8 -DNEWLISP64 -DLINUX -DFFI -Ipcre

# replace -O3 with -Oz when using clang/llvm
#CC = clang

CC = gcc

default: $(OBJS)
	$(CC) $(OBJS) -g -lm -ldl -lreadline -lffi -o newlisp # for UBUNTU Debian
#	$(CC) $(OBJS) -g -lm -ldl -lreadline -ltermcap -o newlisp # slackware
#	$(CC) $(OBJS) -g -lm -ldl -lreadline -lncurses -o newlisp # other Linux Dist
#	$(CC) $(OBJS) -g -lm -ldl -o newlisp # without readline support
	strip newlisp

obj:
	mkdir -p obj

obj/%.o: %.c | obj
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJS): primes.h protos.h newlisp.h nl-vm.h makefiles/dgx_spark_utf8_ffi.mk

test: default
	./newlisp -n "test-run"

cleandocs:
	../newlispdoc -n -x ${SRCDIR}newlisp_manual.xml

VPATH = src pcre
