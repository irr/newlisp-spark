#
# USAGE:
#
# make <option>
#
# to see a list of all options, enter 'make help'
#
# for 'make install' you have to login as 'root' else do 'make install_home'
#
# to make the distribution archive:  'make dist'
#
# to clean up (delete .o *~ core etc.):  'make clean'
#
# for customization options, like install location, 64-bit nerwlisp,
# newLISP as a library etc., see the file doc/INSTALL.txt
#
# Regular expressions are on all platforms Perl Compatible Regular Expresssions PCRE
# see http://www.pcre.org. PCRE can be localized to other languages than English
# by generating different character tables, see documentation at www.pcre.org
# and file LOCALIZATION for details
#

VERSION = 10.8
INT_VERSION = 10800

default: makefile_build
	make -f makefile_build

makefile_build:
	./configure

all: default

help:
	@echo "\nDo one of the following:"
	@echo "  make                 # auto-select one of the predefined makefiles and build newLISP"
	@echo "  make help            # display this help"
	@echo "  make install         # install newlisp and modules in /usr/local (need to be root)"
	@echo "  make uninstall       # uninstall newlisp from /usr/local (need to be root)"
	@echo "  make install_home    # install newlisp in ~/.local/bin and modules in ~/.local/share/newlisp"
	@echo "  make uninstall_home  # uninstall newlisp and modules from ~/.local"
	@echo
	@echo "  make clean           # remove all *.o and .tar files etc. USE BETWEEN FLAVORS!"
	@echo "  make check           # run qa-dot, qa-net, qa-xml etc. test scripts"
	@echo "  make test            # same as 'make check' but less output"
	@echo "  make check-comma     # run the qa-comma suite for decimal-comma locales (needs de_DE.UTF-8)"
	@echo "  make test-comma      # same as 'make check-comma' but less output"
	@echo "  make testall         # run an extended test suite with less output"
	@echo "  make version         # replace version number in several files after changing in Makefile"
	@echo "  make bench           # run qa-bench performance comparison against reference calibration"
	@echo "  make dist            # make a source distribution .tgz package "
	@echo
	@echo "Note! not all makefiles are listed in this help, specifically 64-bit versions."
	@echo " "
	@echo "make files distinguish beteween os support and compilation with or without"
	@echo "    lib readline support, 64bit v 32bit support, utf-8 support, extended function import interface
	@echo " "
	@echo "For other customization options (exe dir, install dir,  etc) see the file doc/INSTALL"

# this cleans the tree for a rebuild using the same configuration as before
clean:
	-rm -f *~ *.bak *.o *.map *.core core *.tgz *.txt TEST
	-rm -rf obj
	-rm -f doc/*.bak util/*.bak examples/*.bak modules/*.bak src/*.bak pcre/*.bak
	-chmod 644 src/* pcre/* Makefile makefiles/*
	-chmod 755 configure configure-alt examples/*
	-chmod 644 doc/* modules/*.lsp examples/*.lsp examples/*.html
	-chmod 755 doc/index.cgi
	-rm -f makefile_build makefile_install config.h test-* newlisp

# run test scripts

check:
	./newlisp qa/qa-dot
	./newlisp qa/qa-specific-tests/qa-dictionary
	./newlisp qa/qa-specific-tests/qa-xml
	./newlisp qa/qa-specific-tests/qa-json
	./newlisp qa/qa-specific-tests/qa-setsig
	./newlisp qa/qa-specific-tests/qa-net
	./newlisp qa/qa-specific-tests/qa-curl
	./newlisp qa/qa-specific-tests/qa-cilk
	./newlisp qa/qa-specific-tests/qa-ref
	./newlisp qa/qa-specific-tests/qa-message
	./newlisp qa/qa-specific-tests/qa-bigint 10000
	./newlisp qa/qa-specific-tests/qa-vm-mem
	./newlisp qa/qa-specific-tests/qa-vm-edges
	./newlisp qa/qa-specific-tests/qa-bench

# old naming for check
test:
	make check | grep '>>>'

# decimal-comma locale suite (needs the de_DE.UTF-8 locale installed)
check-comma:
	./newlisp qa/qa-comma

test-comma:
	make check-comma | grep '>>>'

checkall:
	./newlisp qa/qa-dot ; echo qa-dot
	./newlisp qa/qa-specific-tests/qa-dictionary
	./newlisp qa/qa-specific-tests/qa-xml
	./newlisp qa/qa-specific-tests/qa-json
	./newlisp qa/qa-specific-tests/qa-setsig
	./newlisp qa/qa-specific-tests/qa-net
	./newlisp qa/qa-specific-tests/qa-net6
	./newlisp qa/qa-specific-tests/qa-curl
	./newlisp qa/qa-specific-tests/qa-cilk
	./newlisp qa/qa-specific-tests/qa-ref
	./newlisp qa/qa-specific-tests/qa-message
	./newlisp qa/qa-specific-tests/qa-blockmemory
	./newlisp qa/qa-specific-tests/qa-exception
	./newlisp qa/qa-specific-tests/qa-float
	./newlisp qa/qa-specific-tests/qa-foop
	./newlisp qa/qa-specific-tests/qa-local-domain
	./newlisp qa/qa-specific-tests/qa-inplace
	./newlisp qa/qa-specific-tests/qa-pipefork
	./newlisp qa/qa-specific-tests/qa-libffi
	./newlisp qa/qa-specific-tests/qa-bigint 10000
	./newlisp qa/qa-specific-tests/qa-longnum
	./newlisp qa/qa-specific-tests/qa-factorfibo 60
	./newlisp qa/qa-specific-tests/qa-vm-mem
	./newlisp qa/qa-specific-tests/qa-vm-edges
	./newlisp qa/qa-specific-tests/qa-bench

testall:
	make checkall | grep '>>>'

# benchmark
bench:
	./newlisp qa/qa-specific-tests/qa-bench

# install

# makefile_install normally is created by the configure script
# but when using 'make -f makefiles/xxx.mk' the file hasn't been
# created and is created with this dependency

makefile_install: makefiles/install.mk
	cp makefiles/install.mk makefile_install

install: makefile_install
	-make -f makefile_install install

install_lib: makefile_install
	-make -f makefile_install install_lib

uninstall: makefile_install
	-make -f makefile_install uninstall

install_home: makefile_install
	-make -f makefile_install install_home

uninstall_home: makefile_install
	-make -f makefile_install uninstall_home

# This makes the main newlisp-x.x.x.tgz source distribuition package
dist: clean
	-mkdir newlisp-$(VERSION)
	-mkdir newlisp-$(VERSION)/modules
	-mkdir newlisp-$(VERSION)/examples
	-mkdir newlisp-$(VERSION)/doc
	-mkdir newlisp-$(VERSION)/util
	-mkdir newlisp-$(VERSION)/makefiles
	-mkdir newlisp-$(VERSION)/src
	-mkdir newlisp-$(VERSION)/pcre
	-mkdir newlisp-$(VERSION)/qa
	-mkdir newlisp-$(VERSION)/qa/qa-specific-tests
	cp README newlisp-$(VERSION)
	cp index.cgi newlisp-$(VERSION)
	cp Makefile configure* newlisp-$(VERSION)
	cp qa/qa-dot qa/qa-comma newlisp-$(VERSION)/qa
	cp modules/* newlisp-$(VERSION)/modules
	cp makefiles/* newlisp-$(VERSION)/makefiles
	cp src/* newlisp-$(VERSION)/src
	cp pcre/* newlisp-$(VERSION)/pcre
	cp examples/* newlisp-$(VERSION)/examples
	cp doc/* newlisp-$(VERSION)/doc
	cp util/* newlisp-$(VERSION)/util
	cp qa/qa-specific-tests/* newlisp-$(VERSION)/qa/qa-specific-tests
	tar czvf newlisp-$(VERSION).tgz newlisp-$(VERSION)/*
	rm -rf newlisp-$(VERSION)
	mv newlisp-$(VERSION).tgz ..

# this changes to the current version number in several files
#
# before doing a 'make version' the VERSION variable at the beginning
# of this file has to be changed to the new number
#
version:
	sed -i.bak -E 's/int version = .+;/int version = $(INT_VERSION);/' src/newlisp.c
	sed -i.bak -E 's/newLISP Spark v\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?[a-z0-9]*/newLISP Spark v.$(VERSION)/g' src/newlisp.c
	sed -i.bak -E 's/newLISP\/[0-9]+(\.[0-9]+)?(\.[0-9]+)?/newLISP\/$(VERSION)/' src/nl-web.c
	sed -i.bak -E 's/newLISP v.+ Manual/newLISP v.$(VERSION) Manual/' doc/newlisp_manual.html
	sed -i.bak -E 's/Reference v.+<\/h2>/Reference v.$(VERSION)<\/h2>/' doc/newlisp_manual.html
	sed -i.bak -E 's/VERSION=.+/VERSION=$(VERSION)/' configure-alt
	sed -i.bak -E 's/VERSION=.+/VERSION=$(VERSION)/' makefiles/install.mk

# Prepare the manual file for PDF conversion, by replaceing all <span class="function"></span>
# with <font color="#DD0000"></font> in the syntax statements and replacing &rarr; (one line
# arrow with &rArr; (double line arrow). This is necessary when using OpenOffcice PDF conversion
#
preparepdf:
	util/preparepdf doc/newlisp_manual.html doc/newlisp_manual_preparepdf.html

# end of file
