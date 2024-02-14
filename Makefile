# dwm - dynamic window manager
# See LICENSE file for copyright and license details.

include config.mk

SRC = drw.c dwm.c util.c
OBJ = ${SRC:.c=.o}

all: options dwm

options:
	@echo dwm build options:
	@echo "CFLAGS   = ${CFLAGS}"
	@echo "LDFLAGS  = ${LDFLAGS}"
	@echo "CC       = ${CC}"

.c.o:
	${CC} -c ${CFLAGS} $<

${OBJ}: config.h config.mk

config.h: .patches
	cp config.def.h $@

dwm: ${OBJ}
	${CC} -o $@ ${OBJ} ${LDFLAGS}

clean:
	rm -f dwm ${OBJ} dwm-${VERSION}.tar.gz config.h .patches
	rm -f	dwm.c.orig config.def.h.orig dwm.c.rej
	rm -rf dwm_$(VERSION)_amd64.deb build/usr
	git co dwm.c dwm.1 config.def.h

dist: clean
	mkdir -p dwm-${VERSION}
	cp -R LICENSE Makefile README config.def.h config.mk\
		dwm.1 drw.h util.h ${SRC} dwm.png transient.c dwm-${VERSION}
	tar -cf dwm-${VERSION}.tar dwm-${VERSION}
	gzip dwm-${VERSION}.tar
	rm -rf dwm-${VERSION}

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f dwm ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/dwm
	mkdir -p ${DESTDIR}${MANPREFIX}/man1
	sed "s/VERSION/${VERSION}/g" < dwm.1 > ${DESTDIR}${MANPREFIX}/man1/dwm.1
	chmod 644 ${DESTDIR}${MANPREFIX}/man1/dwm.1

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/dwm\
		${DESTDIR}${MANPREFIX}/man1/dwm.1

.patches:
	patch -p1 < patches/dwm-blanktags-6.3.diff
	patch -p1 < patches/dwm-fullscreen-6.3.diff
	patch -p1 < patches/dwm-config-6.3.diff
	patch -p1 < patches/dwm-alwayscenter-20200625-f04cac6.diff
	touch .patches

dwm_$(VERSION)_amd64.deb:
	mkdir -p build/usr/bin
	cp dwm build/usr/bin
	sed -i '/^Version: /s,.*,Version: $(VERSION),' build/DEBIAN/control
	dpkg-deb -b --root-owner-group build dwm_$(VERSION)_amd64.deb

deb: all dwm_$(VERSION)_amd64.deb

.PHONY: all options clean dist install uninstall
