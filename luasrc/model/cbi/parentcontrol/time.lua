local o = require "luci.sys"
local fs = require "nixio.fs"
local ipc = require "luci.ip"
local net = require "luci.model.network".init()
local sys = require "luci.sys"
local a, t, e
a = Map("parentcontrol", translate("Parent Control"), translate("<b><font color=\"green\">Use iptables Tool software to control packet filtering and prohibit users who meet set conditions from connecting to the Internet.</font> </b></br>\
Time limit: Restrictions specified MAC Whether the address machine is connected to the Internet. Includes IPV4 and IPV6</br>Not specifying MAC means restricting all machines. The start control time should be less than the stop control time. Not specifying time means all time periods." ))

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

e = t:option(ListValue, "control_mode",translate("Restricted mode"), translate("In blacklist mode, client settings in the list will be prohibited; In whitelist mode: Only client settings in the list are allowed."))
e.rmempty = false
e:value("white_mode", "Whitelist")
e:value("black_mode", "Blacklist")
e.default = "black_mode"

t = a:section(TypedSection, "time", translate("Time limit"))
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true

e = t:option(Value, "mac", translate("<font color=\"green\">MAC address*</font>"))
e.rmempty = true
o.net.mac_hints(function(t, a) e:value(t, "%s (%s)" % {t, a}) end)

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


