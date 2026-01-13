-- 设备应用限速 - 限速规则配置
local m = Map("device_qos", translate("限速规则"),
	translate("为特定设备的特定应用配置上传和下载带宽限制"))

local s = m:section(TypedSection, "device_limit", translate("限速规则列表"))
s.addremove = true
s.anonymous = false
s.template = "cbi/tblsection"

-- 选择设备
local device = s:option(ListValue, "device", translate("目标设备"),
	translate("选择需要限速的设备"))
device.rmempty = false
device.width = "15%"

local uci = require "luci.model.uci".cursor()
uci:foreach("device_qos", "device", function(e)
	if e.enabled == "1" then
		device:value(e[".name"], e.name or e[".name"])
	end
end)

-- 选择应用
local app = s:option(ListValue, "app", translate("应用"),
	translate("选择需要限速的应用"))
app.rmempty = false
app.width = "15%"

uci:foreach("device_qos", "app", function(e)
	if e.enabled == "1" then
		app:value(e[".name"], e.name or e[".name"])
	end
end)

-- 上行保证带宽
local ur = s:option(Value, "up_rate", translate("上行保证"),
	translate("最小保证上传带宽，例如：512kbit, 1mbit"))
ur.rmempty = false
ur.placeholder = "512kbit"
ur.width = "12%"

-- 上行最大带宽
local uc = s:option(Value, "up_ceil", translate("上行上限"),
	translate("最大上传带宽，例如：1mbit, 2mbit"))
uc.rmempty = false
uc.placeholder = "1mbit"
uc.width = "12%"

-- 下行保证带宽
local dr = s:option(Value, "down_rate", translate("下行保证"),
	translate("最小保证下载带宽，例如：2mbit, 5mbit"))
dr.rmempty = false
dr.placeholder = "2mbit"
dr.width = "12%"

-- 下行最大带宽
local dc = s:option(Value, "down_ceil", translate("下行上限"),
	translate("最大下载带宽，例如：5mbit, 10mbit"))
dc.rmempty = false
dc.placeholder = "5mbit"
dc.width = "12%"

-- 带宽单位验证函数
local function validate_bandwidth(value)
	if not value or value == "" then
		return false, translate("带宽值不能为空")
	end

	-- 支持的单位：bit, kbit, mbit, gbit, kbps, mbps
	local pattern = "^%d+%.?%d*[kmg]?bits?$"
	if not value:lower():match(pattern) then
		return false, translate("带宽格式错误，例如：512kbit, 1mbit, 100mbps")
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

-- 检查设备和应用组合是否重复
function device.validate(self, value, section)
	if not value or value == "" then
		return nil, translate("必须选择一个设备")
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
		return nil, translate("该设备已配置此应用的限速规则")
	end

	return value
end

return m
