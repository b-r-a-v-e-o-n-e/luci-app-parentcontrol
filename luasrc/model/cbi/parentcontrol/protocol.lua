local o = require "luci.sys"
local fs = require "nixio.fs"
local ipc = require "luci.ip"
local net = require "luci.model.network".init()
local sys = require "luci.sys"
local a, t, e
a = Map("parentcontrol", translate("Parent Control"), translate("<b><font color=\"green\">Use iptables Tool software to control packet filtering and prohibit users who meet set conditions from connecting to the Internet.</font> </b></br>\
Protocol filtering: Can control whether the specified MAC machine uses the specified protocol port, include IPV4 and IPV6，Ports can be consecutive port ranges separated by colons such as 5000:5100 or multiple ports separated by commas such as: 5100, 5110, 5001:5002, 440:443</br>Not specify MAC it means restricting all machines, The start control time should be less than the stop control time， Express period without specifying time" ))

a.template = "parentcontrol/index"
t = a:section(TypedSection, "basic", translate(""))
t.anonymous = true
e = t:option(DummyValue, "parentcontrol_status", translate("Current status"))
e.template = "parentcontrol/parentcontrol"
e.value = translate("Collecting data...")

e = t:option(Flag, "enabled", translate("Turn on"))
e.rmempty = false

e = t:option(ListValue, "algos", translate("Filtration strength"))
e:value("bm", "General filtering")
e:value("kmp", "Powerful filtering")
e.default = "kmp"

e = t:option(ListValue, "control_mode",translate("Restricted mode"), translate("Blacklist mode, Client settings in the list will be disabled；Whitelist mode: Only client settings in the list are allowed."))
e.rmempty = false
e:value("white_mode", "Whitelist")
e:value("black_mode", "Blacklist")
e.default = "black_mode"

t = a:section(TypedSection, "protocol", translate("Protocol filtering"))
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true
e = t:option(Value, "mac", translate("MAC address <font color=\"green\">(Leave blank to filter all clients)</font>"))
e.placeholder = "ALL"
e.rmempty = true
o.net.mac_hints(function(t, a) e:value(t, "%s (%s)" % {t, a}) end)
e = t:option(ListValue, "proto", translate("<font color=\"gray\">Port protocol</font>"))
e.rmempty = false
e.default = 'tcp'
e:value("tcp", translate("TCP"))
e:value("udp", translate("UDP"))
e:value("icmp", translate("ICMP"))
e = t:option(Value, "ports", translate("<font color=\"gray\">Source port</font>"))
e.rmempty = true
e = t:option(Value, "portd", translate("<font color=\"gray\">Destination port</font>"))
e:value("",translate("ICMP"))
e:value("80", "TCP-HTTP")
e:value("443", "TCP-HTTPS")
e:value("22", "TCP-SSH")
e:value("1723", "TCP-PPTP")
e:value("25", "TCP-SMTP")
e:value("110", "TCP-POP3")
e:value("21", "TCP-FTP21")
e:value("23", "TCP-TELNET")
e:value("53", "TCP-DNS53")
e:value("20", "UDP-FTP20")
e:value("1701", "UDP-L2TP")
e:value("69", "UDP-TFTP")
e:value("500", "UDP-IPSEC")
e:value("53", "UDP-DNS53")
e:value("161", "UDP-SNMP")
e.rmempty = true
    function validate_time(self, value, section)
        local hh, mm, ss
        hh, mm, ss = string.match (value, "^(%d?%d):(%d%d)$")
        hh = tonumber (hh)
        mm = tonumber (mm)
        if hh and mm and hh <= 23 and mm <= 59 then
            return value
        else
            return nil, "The time format must be HH:MM Or leave it blank"
        end
    end
e = t:option(Value, "timestart", translate("Start time"))
e.placeholder = '00:00'
e.default = '00:00'
e.validate = validate_time
e.rmempty = true
e = t:option(Value, "timeend", translate("Stop time"))
e.placeholder = '00:00'
e.default = '00:00'
e.validate = validate_time
e.rmempty = true

week=t:option(ListValue,"week",translate("Week Day"))
week.rmempty = true
week:value('*',translate("Everyday"))
week:value(7,translate("Sunday"))
week:value(1,translate("Monday"))
week:value(2,translate("Tuesday"))
week:value(3,translate("Wednesday"))
week:value(4,translate("Thursday"))
week:value(5,translate("Friday"))
week:value(6,translate("Saturday"))
week.default='*'


e = t:option(Flag, "enable", translate("Turn on"))
e.rmempty = false
e.default = '1'

a.apply_on_parse = true
a.on_after_apply = function(self,map)
	luci.sys.exec("/etc/init.d/parentcontrol restart")
end

return a


