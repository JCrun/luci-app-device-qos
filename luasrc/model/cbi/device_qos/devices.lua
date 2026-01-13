-- 设备应用限速 - 设备管理
local m = Map("device_qos", translate("设备管理"),
	translate("配置需要进行应用限速的局域网设备"))

local s = m:section(TypedSection, "device", translate("设备列表"))
s.addremove = true
s.anonymous = false
s.template = "cbi/tblsection"

-- 启用/禁用单个设备
local en = s:option(Flag, "enabled", translate("启用"))
en.rmempty = false
en.default = "1"
en.width = "5%"

-- 设备名称（用户友好）
local name = s:option(Value, "name", translate("设备名称"),
	translate("易于识别的设备名称，例如：小明的手机、客厅电视"))
name.rmempty = false
name.placeholder = "小明的手机"
name.width = "20%"

-- 设备描述
local desc = s:option(Value, "desc", translate("设备描述"),
	translate("可选的设备描述，例如：华为 Mate 40"))
desc.placeholder = "设备型号或备注"
desc.width = "20%"

-- 设备IP地址
local ip = s:option(Value, "ip", translate("IP 地址"),
	translate("设备的固定IP地址（建议通过DHCP静态分配）"))
ip.datatype = "ip4addr"
ip.rmempty = false
ip.placeholder = "192.168.1.100"
ip.width = "15%"

-- 添加验证
function ip.validate(self, value, section)
	if not value or value == "" then
		return nil, translate("IP 地址不能为空")
	end

	-- 检查IP地址格式
	local valid = require "luci.ip"
	if not valid.IPv4(value) then
		return nil, translate("无效的 IPv4 地址格式")
	end

	-- 检查是否与其他设备冲突
	local uci = require "luci.model.uci".cursor()
	local conflict = false
	uci:foreach("device_qos", "device", function(s)
		if s[".name"] ~= section and s.ip == value then
			conflict = true
			return false
		end
	end)

	if conflict then
		return nil, translate("IP 地址与其他设备冲突")
	end

	return value
end

return m
