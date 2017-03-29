--[[
luci for Gargoyle QoS
Based on GuoGuo's luci-app-qos-guoguo
Copyright (c) 2017 Xingwang Liao <kuoruan@gmail.com>
]]--

module("luci.controller.qos_gargoyle", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/qos_gargoyle") then
		return
	end

	entry({"admin", "network", "qos_gargoyle"},
		alias("admin", "network", "qos_gargoyle", "global"),
		_("Gargoyle QoS"), 60).dependent = true

	entry({"admin", "network", "qos_gargoyle", "global"},
		cbi("qos_gargoyle/global"),
		_("Global Settings"), 20)

	entry({"admin", "network", "qos_gargoyle", "upload"},
		arcombine(
			cbi("qos_gargoyle/upload"),
			cbi("qos_gargoyle/upload_class"),
			cbi("qos_gargoyle/upload_rule")
		),
		_("Upload Settings"),30).leaf = true

	entry({"admin", "network", "qos_gargoyle", "download"},
		arcombine(
			cbi("qos_gargoyle/download"),
			cbi("qos_gargoyle/download_class"),
			cbi("qos_gargoyle/download_rule")
		),
		_("Download Settings"), 40).leaf = true
end
