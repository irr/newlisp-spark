#

VERSION=10.8

# NOTE when changing PREFIX, then newlisp should only run
# run in an environment, where NEWLISPDIR is predefined,
# else NEWLISPDIR will be defined during newlisp startup
# as /usr/share/newlisp which is hardcoded in newlisp.c
prefix=/usr/local
datadir=$(prefix)/share
bindir=$(prefix)/bin
mandir=$(prefix)/share/man
libdir=$(prefix)/lib

# copies only the newlisp executable to $(bindir)
# which has to be done as 'root' with superuser permissions
# for an install in your home directory use make install_home

install:
	-install -d $(bindir)
	-rm -f $(bindir)/newlisp
	-rm -f $(bindir)/newlisp-$(VERSION)
	-install -m 755 newlisp $(bindir)/newlisp

# installs the newLISP shared library, needed for embedding and
# callback examples; the library is a separate build flavor:
#   make clean && make -f makefiles/linuxLP64_lib.mk
install_lib:
	@test -f newlisp.so || { echo "newlisp.so not found - build it first:"; echo "  make clean && make -f makefiles/linuxLP64_lib.mk"; exit 1; }
	-install -d $(libdir)
	install -m 755 newlisp.so $(libdir)/newlisp.so

uninstall:
	-rm  $(bindir)/newlisp
	-rm  $(bindir)/newlisp-$(VERSION)
	-rm  $(bindir)/newlispdoc
	-rm  $(bindir)/newlisp-edit
	-rm  -rf $(datadir)/newlisp
	-rm  -rf $(datadir)/doc/newlisp
	-rm  $(mandir)/man1/newlisp.1
	-rm  $(mandir)/man1/newlispdoc.1
	-rm  $(libdir)/newlisp.so

# installs newLISP in home directory

install_home:
	-install -d $(HOME)/.local/bin
	-install -m 755 newlisp $(HOME)/.local/bin/newlisp


uninstall_home:
	-rm  -rf $(HOME)/share/newlisp
	-rm  -rf $(HOME)/share/doc/newlisp
	-rm  $(HOME)/share/man/man1/newlisp.1
	-rm  $(HOME)/share/man/man1/newlispdoc.1
	-rm $(HOME)/.local/bin/newlisp
	-rm $(HOME)/bin/newlisp
	-rm $(HOME)/bin/newlispdoc

