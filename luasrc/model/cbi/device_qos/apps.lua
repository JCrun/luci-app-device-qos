-- Device App QoS - App Management
local m = Map("device_qos", translate("App Management"),
	translate("Define applications to rate limit and their domain lists. Applications are identified by domains, multiple domains supported."))

local s = m:section(TypedSection, "app", translate("Application List"))
s.addremove = true
s.anonymous = false
s.template = "cbi/tblsection"

-- Enable/Disable individual app
local en = s:option(Flag, "enabled", translate("Enable"))
en.rmempty = false
en.default = "1"
en.width = "6%"

-- App Name
local name = s:option(Value, "name", translate("App Name"),
	translate("User-friendly application name, e.g.: TikTok, Bilibili"))
name.rmempty = false
name.placeholder = "TikTok"
name.width = "18%"

-- App Description
local desc = s:option(Value, "desc", translate("Description"),
	translate("Optional application description or notes"))
desc.placeholder = "App description"
desc.width = "20%"

-- Firewall Mark Base Value
local base = s:option(Value, "fwmark_base", translate("Mark Value"),
	translate("Firewall mark base value for kernel identification. Recommended: 1000, 2000, 3000..."))
base.datatype = "and(uinteger,min(100))"
base.rmempty = false
base.placeholder = "1000"
base.width = "10%"

-- Domain List
local domains = s:option(DynamicList, "domains", translate("Domain List"),
	translate("Domains related to this application, one per line. e.g.: douyin.com, bytecdn.cn"))
domains.rmempty = false
domains.placeholder = "example.com"

-- Add validation
function domains.validate(self, value, section)
	if not value or #value == 0 then
		return nil, translate("At least one domain is required")
	end
	return value
end

function base.validate(self, value, section)
	if not value then
		return nil, translate("Fwmark base value cannot be empty")
	end

	local num = tonumber(value)
	if not num or num < 100 then
		return nil, translate("Fwmark base value must be at least 100")
	end

	-- Check for conflicts with other apps
	local uci = require "luci.model.uci".cursor()
	uci:foreach("device_qos", "app", function(s)
		if s[".name"] ~= section then
			local other_base = tonumber(s.fwmark_base or 0)
			if other_base == num then
				return nil, translate("Fwmark base value conflicts with another app")
			end
		end
	end)

	return value
end

return m
