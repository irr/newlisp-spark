# makefile for newLISP v.10.x.x on LINUX with readline support
#
# Note, that readline support may require different libraries on different OSs
# 

OBJS = obj/newlisp.o obj/nl-symbol.o obj/nl-math.o obj/nl-list.o obj/nl-liststr.o obj/nl-string.o obj/nl-filesys.o \
	obj/nl-sock.o obj/nl-import.o obj/nl-xml-json.o obj/nl-web.o obj/nl-matrix.o obj/nl-debug.o obj/pcre.o obj/nl-vm.o

#CFLAGS = -m32 -Wall -Wno-strict-aliasing -Wno-long-long -c -O3 -g -DLINUX
CFLAGS = -m32 -Wall -Wno-strict-aliasing -Wno-long-long -c -O3 -g -DREADLINE -DLINUX  -Ipcre

CC = gcc


default: $(OBJS)
	$(CC) $(OBJS) -m32 -g -lm -ldl -lreadline -o newlisp # for UBUNTU Debian
#	$(CC) $(OBJS) -m32 -g -lm -ldl -lreadline -lncurses -o newlisp # other Linux Dist
#	$(CC) $(OBJS) -m32 -g -lm -ldl -o newlisp # without readline support
	strip newlisp

obj:
	mkdir -p obj

obj/%.o: %.c | obj
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJS): primes.h protos.h newlisp.h nl-vm.h makefiles/linux.mk


VPATH = src pcre
