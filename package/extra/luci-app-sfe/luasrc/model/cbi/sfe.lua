local m,s,o
local SYS  = require "luci.sys"


if SYS.call("lsmod | grep fast_classifier >/dev/null") == 0 then
	Status = translate("<strong><font color=\"green\">Shortcut Forwarding Engine is Running</font></strong>")
else
	Status = translate("<strong><font color=\"red\">Shortcut Forwarding Engine is Not Running</font></strong>")
end

m = Map("sfe")
m.title	= translate("Shortcut Forwarding Engine Acceleration Settings")
m.description = translate("Opensource Qualcomm Shortcut FE driver (Fast Path)")

s = m:section(TypedSection, "sfe", "")
s.addremove = false
s.anonymous = true
s.description = translate(string.format("%s<br /><br />", Status))

enable = s:option(Flag, "enabled", translate("Enable"))
enable.default = 0
enable.rmempty = false

bridge = s:option(Flag, "bridge", translate("Bridge Acceleration"))
bridge.default = 0
bridge.rmempty = false
bridge.description = translate("Enable Bridge Acceleration")

ipv6 = s:option(Flag, "ipv6", translate("IPv6 Acceleration"))
ipv6.default = 0
ipv6.rmempty = false
ipv6.description = translate("Enable IPv6 Acceleration")

function m.on_after_commit(self)
	os.execute("/etc/init.d/sfe restart >/dev/null 2>&1 &")
end

return m
