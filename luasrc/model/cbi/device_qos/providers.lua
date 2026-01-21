-- Device App QoS - Rule Source Configuration
local m = Map("device_qos", translate("Rule Sources"),
	translate("Configure external rule subscription sources (e.g. Clash Rule Set) for automatic rule updates. Supports downloading rules from URL and applying to corresponding apps."))

-- Add description
local info = m:section(SimpleSection, nil, translate("Description"))
info.description = translate("Rule sources can automatically download domain and IP rules from external URLs and merge them into corresponding apps. Click 'Update Rules Now' button to manually trigger update.")

-- Rule Source List
local s = m:section(TypedSection, "provider", translate("Rule Source List"))
s.template = "cbi/tblsection"
s.addremove = true
s.anonymous = false

-- Enable/Disable
local en = s:option(Flag, "enabled", translate("Enable"))
en.rmempty = false
en.default = "1"
en.width = "6%"

-- Rule Type
local type_opt = s:option(ListValue, "type", translate("Type"))
type_opt:value("clash", "Clash (YAML)")
type_opt.default = "clash"
type_opt.width = "12%"

-- Associated Application
local app_opt = s:option(ListValue, "app", translate("Associated App"), translate("Bind downloaded rules to which application"))
app_opt.rmempty = false
app_opt.width = "18%"

-- Dynamically load defined applications
local uci = require "luci.model.uci".cursor()
uci:foreach("device_qos", "app", function(s)
	if s['.name'] then
		-- 显示应用名称（如果有）或 Section ID
		app_opt:value(s['.name'], s.name or s['.name'])
	end
end)

-- URL
local url = s:option(Value, "url", translate("Rule URL"), translate("Clash rule file download URL (supports HTTPS/jsdelivr)"))
url.rmempty = false
url.width = "45%"

-- Validate URL
function url.validate(self, value, section)
	if not value then return nil, translate("URL cannot be empty") end
	if not (value:match("^http://") or value:match("^https://")) then
		return nil, translate("Must start with http:// or https://")
	end
	return value
end

-- Add update button section
local update_section = m:section(SimpleSection, nil, translate("Manual Update"))
update_section.template = "device_qos/update_button"

return m
