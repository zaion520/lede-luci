--[[
luci for Gargoyle QoS
]]--

local wa  = require "luci.tools.webadmin"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()

local m, s, o
local upload_classes = {}

uci:foreach("qos_gargoyle", "upload_class", function(s)
	local class_alias = s.name
	if class_alias then
		upload_classes[#upload_classes + 1] = {name = s[".name"], alias = class_alias}
	end
end)

local function has_ndpi()
	return sys.exec("lsmod | awk '{print $1}' | grep -q 'xt_ndpi'") == 0
end

m = Map("qos_gargoyle", translate("Upload Settings"))

s = m:section(TypedSection, "upload_class", translate("Classification Rules"),
		translate("Each upload service class is specified by three parameters: percent bandwidth at capacity, minimum bandwidth and maximum bandwidth.") .. "<br />" ..
		translate("<em>Percent bandwidth</em> is the percentage of the total available bandwidth that should be allocated to this class when all available bandwidth is being used. If unused bandwidth is available, more can (and will) be allocated. The percentages can be configured to equal more (or less) than 100, but when the settings are applied the percentages will be adjusted proportionally so that they add to 100.").. "<br />" ..
		translate("<em>Minimum bandwidth</em> specifies the minimum service this class will be allocated when the link is at capacity. For certain applications like VoIP or online gaming it is better to specify a minimum service in bps rather than a percentage. QoS will satisfiy the minimum service of all classes first before allocating the remaining service to other waiting classes.") .. "<br />" ..
		translate("<em>Maximum bandwidth</em> specifies an absolute maximum amount of bandwidth this class will be allocated in kbit/s. Even if unused bandwidth is available, this service class will never be permitted to use more than this amount of bandwidth.")
	)
s.addremove = true
s.template  = "cbi/tblsection"


o = s:option(Value, "name", translate("Class Name"))

o = s:option(Value, "percent_bandwidth", translate("Percent bandwidth at capacity"))

o = s:option(Value, "min_bandwidth", translate("Minimum bandwidth"))
o.datatype = "uinteger"

o = s:option(Value, "max_bandwidth", translate("Maximum bandwidth"))
o.datatype = "uinteger"

s = m:section(TypedSection, "upload_rule",translate("Classification Rules"),
	translate("Packets are tested against the rules in the order specified -- rules toward the top have priority. As soon as a packet matches a rule it is classified, and the rest of the rules are ignored. The order of the rules can be altered using the arrow controls.")
)
s.addremove = true
s.sortable  = true
s.anonymous = true
s.template  = "cbi/tblsection"

o = s:option(ListValue, "class", translate("Service Class"))
for _, s in ipairs(upload_classes) do o:value(s.name, s.alias) end

o = s:option(Value, "proto", translate("Application Protocol"))
o:value("tcp", "TCP")
o:value("udp", "UDP")
o:value("icmp", "ICMP")
o:value("gre", "GRE")

sip = s:option(Value, "source", translate("Source IP"))
wa.cbi_add_knownips(sip)
sip.datatype = "ipaddr"

dip = s:option(Value, "destination", translate("Destination IP"))
wa.cbi_add_knownips(dip)
dip.datatype = "ipaddr"

o = s:option(Value, "dstport", translate("Destination Port"))
o.datatype  = "port"
o.maxlength = "5"
o.size      = "5"

o = s:option(Value, "srcport", translate("Source Port"))
o.datatype  = "port"
o.maxlength = "5"
o.size      = "5"

o = s:option(Value, "min_pkt_size", translate("Minimum Packet Length"))
o.datatype = "and(uinteger, min(1))"
o.size     = "10"

o = s:option(Value, "max_pkt_size", translate("Maximum Packet Length"))
o.datatype = "and(uinteger, min(1))"
o.size     = "10"

o = s:option(Value, "connbytes_kb", translate("Connection bytes reach"))
o.datatype = "uinteger"
o.size     = "10"

if has_ndpi() then
	o = s:option(ListValue, "ndpi", translate("DPI protocol"))
	local pats = io.popen("iptables -m ndpi --help | grep -e '^--'")
	if pats then
		local l, s, e, prt_v, prt_d
		while true do
			l = pats:read("*l")
			if not l then break end
			s, e = l:find("%-%-[^%s]+")
			if s and e then
				prt_v = l:sub(s + 2, e)
			end
			s, e = l:find("for [^%s]+ protocol")
			if s and e then
				prt_d = l:sub(s + 3, e - 9)
			end
			o:value(prt_v, prt_d)
		end
		pats:close()
	end
end

return m
