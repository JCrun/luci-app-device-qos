include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-device-qos
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

LUCI_TITLE:=Device Application QoS
LUCI_DESCRIPTION:=Precise bandwidth control for specific applications on specific devices
LUCI_DEPENDS:=+luci-base +tc +kmod-sched +nftables +dnsmasq-full
LUCI_PKGARCH:=all

PKG_MAINTAINER:=Device QoS Team

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/device_qos.lua $(1)/usr/lib/lua/luci/controller/
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/device_qos
	$(INSTALL_DATA) ./luasrc/model/cbi/device_qos/*.lua $(1)/usr/lib/lua/luci/model/cbi/device_qos/
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/device_qos
	$(INSTALL_DATA) ./luasrc/view/device_qos/*.htm $(1)/usr/lib/lua/luci/view/device_qos/
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/device_qos $(1)/etc/config/
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/device-qos $(1)/etc/init.d/
	
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./root/usr/sbin/device-qos $(1)/usr/sbin/
	
	$(INSTALL_DIR) $(1)/usr/libexec/device-qos
	$(INSTALL_BIN) ./root/usr/libexec/device-qos/rules-update $(1)/usr/libexec/device-qos/
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || {
	chmod 755 /etc/init.d/device-qos 2>/dev/null || true
	chmod 755 /usr/sbin/device-qos 2>/dev/null || true
	chmod 755 /usr/libexec/device-qos/rules-update 2>/dev/null || true
	exit 0
}
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || {
	/etc/init.d/device-qos stop || true
	/etc/init.d/device-qos disable || true
}
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
