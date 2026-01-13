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

# call BuildPackage - OpenWrt buildroot signature
