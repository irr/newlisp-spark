# makefile for newLISP v.10.x.x on Openwrt LINUX without readline support
# contributed by dexter (see newLISP Forum)
# upx is used to compress
# no readline support, add -DSUPPORT_UTF8 to CFLAGS for UTF8 support
#

OBJS = obj/newlisp.o obj/nl-symbol.o obj/nl-math.o obj/nl-list.o obj/nl-liststr.o obj/nl-string.o obj/nl-filesys.o \
	obj/nl-sock.o obj/nl-import.o obj/nl-xml-json.o obj/nl-web.o obj/nl-matrix.o obj/nl-debug.o obj/pcre.o obj/nl-vm.o

CFLAGS = -Wall -Wl,--gc-sections  -ffunction-sections -fdata-sections  -c -Os  -fno-threadsafe-statics  -DLINUX -I$(TARGET_DIR)/usr/include/ -Ipcre
LDFLAGS = -L$(TARGET_DIR)/usr/lib/  -W1,--gc-sections -lm -ldl
CC = mips-openwrt-linux-gcc
LD = mips-openwrt-linux-ld


default: $(OBJS)
	$(CC) $(OBJS)  -o newlisp $(LDFLAGS)   #for openwrt
	$(STRIP) newlisp
	upx --best -o newlisp_s newlisp
	rm newlisp
	mv newlisp_s newlisp

obj:
	mkdir -p obj

obj/%.o: %.c | obj
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJS): primes.h protos.h makefiles/linux_openwrt.mk


VPATH = src pcre
