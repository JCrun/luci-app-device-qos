-- Device App QoS - Rate Limit Rules
local m = Map("device_qos", translate("Rate Limits"),
	translate("Configure upload and download bandwidth limits for specific apps on specific devices. Rate (guaranteed) is minimum guaranteed bandwidth, Ceil (ceiling) is maximum bandwidth."))

local s = m:section(TypedSection, "device_limit", translate("Rate Limit Rules"))
s.addremove = true
s.anonymous = false
s.template = "cbi/tblsection"

-- Select Device
local device = s:option(ListValue, "device", translate("Device"),
	translate("Select target device"))
device.rmempty = false
device.width = "18%"

local uci = require "luci.model.uci".cursor()
uci:foreach("device_qos", "device", function(e)
	if e.enabled == "1" then
		local display_name = e.name or e[".name"]
		if e.ip then
			display_name = display_name .. " (" .. e.ip .. ")"
		end
		device:value(e[".name"], display_name)
	end
end)

-- Select Application
local app = s:option(ListValue, "app", translate("Application"),
	translate("Select target application"))
app.rmempty = false
app.width = "18%"

uci:foreach("device_qos", "app", function(e)
	if e.enabled == "1" then
		app:value(e[".name"], e.name or e[".name"])
	end
end)

-- Upload Guaranteed Bandwidth
local ur = s:option(Value, "up_rate", translate("Upload Rate"),
	translate("Minimum guaranteed upload bandwidth"))
ur.rmempty = false
ur.placeholder = "512kbit"
ur.width = "14%"

-- Upload Maximum Bandwidth
local uc = s:option(Value, "up_ceil", translate("Upload Ceil"),
	translate("Maximum upload bandwidth"))
uc.rmempty = false
uc.placeholder = "1mbit"
uc.width = "14%"

-- Download Guaranteed Bandwidth
local dr = s:option(Value, "down_rate", translate("Download Rate"),
	translate("Minimum guaranteed download bandwidth"))
dr.rmempty = false
dr.placeholder = "2mbit"
dr.width = "14%"

-- Download Maximum Bandwidth
local dc = s:option(Value, "down_ceil", translate("Download Ceil"),
	translate("Maximum download bandwidth"))
dc.rmempty = false
dc.placeholder = "5mbit"
dc.width = "14%"

-- Bandwidth unit validation function
local function validate_bandwidth(value)
	if not value or value == "" then
		return false, translate("Bandwidth value cannot be empty")
	end

	-- Supported units: bit, kbit, mbit, gbit, kbps, mbps
	local pattern = "^%d+%.?%d*[kmg]?bits?$"
	if not value:lower():match(pattern) then
		return false, translate("Invalid bandwidth format, e.g.: 512kbit, 1mbit, 100mbps")
	end

	return true, nil
end

-- 添加验证
function ur.validate(self, value, section)
	local valid, err = validate_bandwidth(value)
	if not valid then
		return nil, err
	end
	return value
end

function uc.validate(self, value, section)
	local valid, err = validate_bandwidth(value)
	if not valid then
		return nil, err
	end
	return value
end

function dr.validate(self, value, section)
	local valid, err = validate_bandwidth(value)
	if not valid then
		return nil, err
	end
	return value
end

function dc.validate(self, value, section)
	local valid, err = validate_bandwidth(value)
	if not valid then
		return nil, err
	end
	return value
end

-- Check for duplicate device+app combinations
function device.validate(self, value, section)
	if not value or value == "" then
		return nil, translate("Must select a device")
	end

	-- 获取当前配置的应用
	local current_app = m:formvalue("cbid.device_qos." .. section .. ".app")
	if not current_app then
		return value
	end

	-- 检查是否已存在相同的设备+应用组合
	local conflict = false
	uci:foreach("device_qos", "device_limit", function(s)
		if s[".name"] ~= section then
			if s.device == value and s.app == current_app then
				conflict = true
				return false
			end
		end
	end)

	if conflict then
		return nil, translate("This device already has a rate limit rule for this app")
	end

	return value
end

return m
