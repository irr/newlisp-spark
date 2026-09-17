# makefile for newLISP v.10.x.x on LINUX raspberry PI 
#
# Note, that readline support may require different libraries on different OSs
# 
# USAGE: sb2 make -f makefiles/raspberrypi_utf8.mk
# RUNNING and TEST: sb2 make testall
# sb2 is an ARM emulator

OBJS = obj/newlisp.o obj/nl-symbol.o obj/nl-math.o obj/nl-list.o obj/nl-liststr.o obj/nl-string.o obj/nl-filesys.o \
	obj/nl-sock.o obj/nl-import.o obj/nl-xml-json.o obj/nl-web.o obj/nl-matrix.o obj/nl-debug.o obj/nl-utf8.o obj/pcre.o obj/nl-vm.o

CFLAGS = -mcpu=arm1176jzf-s -Wall -pedantic -Wno-strict-aliasing -Wno-long-long -c -O3 -g -DLINUX -DSUPPORT_UTF8 -Ipcre
#CFLAGS = -mcpu=arm1176jzf-s -Wall -pedantic -Wno-strict-aliasing -Wno-long-long -c -O3 -g -DLINUX -DSUPPORT_UTF8  -DREADLINE

CC = gcc


default: $(OBJS)
#	$(CC) $(OBJS) -g -lm -ldl -lreadline -o newlisp #  with readline support
	$(CC) $(OBJS) -g -lm -ldl -o newlisp # without readline support
	strip newlisp

obj:
	mkdir -p obj

obj/%.o: %.c | obj
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJS): primes.h protos.h makefiles/raspberrypi_utf8.mk


VPATH = src pcre
