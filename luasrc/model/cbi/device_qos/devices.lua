-- Device App QoS - Device Management
local m = Map("device_qos", translate("Device Management"),
	translate("Configure LAN devices that need app rate limiting. Devices must use static IP addresses."))

local s = m:section(TypedSection, "device", translate("Device List"))
s.addremove = true
s.anonymous = false
s.template = "cbi/tblsection"

-- Enable/Disable individual device
local en = s:option(Flag, "enabled", translate("Enable"))
en.rmempty = false
en.default = "1"
en.width = "6%"

-- Device Name (user-friendly)
local name = s:option(Value, "name", translate("Device Name"),
	translate("Easy-to-identify device name, e.g.: John's Phone, Living Room TV"))
name.rmempty = false
name.placeholder = "John's Phone"
name.width = "25%"

-- Device Description
local desc = s:option(Value, "desc", translate("Description"),
	translate("Optional device description or model"))
desc.placeholder = "Device model or notes"
desc.width = "25%"

-- Device IP Address
local ip = s:option(Value, "ip", translate("IP Address"),
	translate("Device's static IP address. Recommend configuring in Network → DHCP/DNS → Static Leases"))
ip.datatype = "ip4addr"
ip.rmempty = false
ip.placeholder = "192.168.1.100"
ip.width = "18%"

-- Add validation
function ip.validate(self, value, section)
	if not value or value == "" then
		return nil, translate("IP address cannot be empty")
	end

	-- Check IP address format
	local valid = require "luci.ip"
	if not valid.IPv4(value) then
		return nil, translate("Invalid IPv4 address format")
	end

	-- Check for conflicts with other devices
	local uci = require "luci.model.uci".cursor()
	local conflict = false
	uci:foreach("device_qos", "device", function(s)
		if s[".name"] ~= section and s.ip == value then
			conflict = true
			return false
		end
	end)

	if conflict then
		return nil, translate("IP address conflicts with another device")
	end

	return value
end

return m
