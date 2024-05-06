.PHONY: all install

all:

install:
	install -DTm 755 updater.sh  "${DESTDIR}/sbin/wg-ddns"
	install -DTm 755 daemon "${DESTDIR}/etc/init.d/wg-ddns"