#
# Copyright (C) 2014-2016 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-shadowsocks
PKG_VERSION:=1.3.6
PKG_RELEASE:=1

PKG_LICENSE:=GPLv3
PKG_MAINTAINER:=Jian Chang <aa65535@live.com>

LUCI_TITLE:=LuCI Support for shadowsocks-libev
LUCI_DEPENDS:=+iptables +ipset
LUCI_PKGARCH:=all

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
