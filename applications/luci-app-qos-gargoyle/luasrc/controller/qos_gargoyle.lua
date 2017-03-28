--[[
luci for Gargoyle QoS
]]--

module("luci.controller.qos_gargoyle", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/qos_gargoyle") then
		return
	end

	entry({"admin", "network", "qos_gargoyle"},
		alias("admin", "network", "qos_gargoyle", "global"),
		_("Gargoyle QoS"), 60)

	entry({"admin", "network", "qos_gargoyle", "global"},
		arcombine(cbi("qos_gargoyle/global")),
		_("General Settings"), 20)

	entry({"admin", "network", "qos_gargoyle", "upload"},
		arcombine(cbi("qos_gargoyle/upload")),
		_("Upload Settings"),30)

	entry({"admin", "network", "qos_gargoyle", "download"},
		arcombine(cbi("qos_gargoyle/download")),
		_("Download Settings"), 40)
end
