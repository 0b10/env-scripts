BASE = "/etc/profile.d"

VPN_SERVER = "vpn-server.sh"

define install
	cp ${1} ${BASE}/__${1}
	chown root:root ${BASE}/__${1}
	chmod 664 ${1}
endef

define remove
	-rm ${BASE}/__${1}
endef

install-vpn-server:
	$(call install,${VPN_SERVER})

remove-vpn-server:
	$(call remove,${VPN_SERVER})

install-net: install-vpn-server
install: install-net

remove-net: remove-vpn-server
remove: remove-net