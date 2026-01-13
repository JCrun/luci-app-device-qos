-- 设备应用限速 - 全局设置
local m = Map("device_qos", translate("设备应用限速"),
	translate("精确控制特定设备上特定应用的上传和下载带宽"))

-- 全局启用/禁用
local s = m:section(TypedSection, "global", translate("全局设置"))
s.anonymous = true
s.addremove = false

local enabled = s:option(Flag, "enabled", translate("启用服务"),
	translate("启用或禁用整个应用流量QoS服务"))
enabled.rmempty = false
enabled.default = "0"

-- WAN/LAN 接口配置
local wan = s:option(Value, "wan_if", translate("WAN接口"),
	translate("用于互联网连接的接口，通常是 wan 或 eth1"))
wan.datatype = "string"
wan.default = "wan"
wan.placeholder = "wan"

local lan = s:option(Value, "lan_if", translate("LAN接口"),
	translate("用于局域网连接的接口，通常是 lan 或 br-lan"))
lan.datatype = "string"
lan.default = "lan"
lan.placeholder = "br-lan"

-- 总带宽配置
local up = s:option(Value, "up_mbps", translate("总上传带宽 (Mbps)"),
	translate("您的ISP提供的上传带宽，单位：Mbps"))
up.datatype = "and(uinteger,min(1))"
up.default = "100"
up.placeholder = "100"

local down = s:option(Value, "down_mbps", translate("总下载带宽 (Mbps)"),
	translate("您的ISP提供的下载带宽，单位：Mbps"))
down.datatype = "and(uinteger,min(1))"
down.default = "100"
down.placeholder = "100"

-- 服务状态信息
local status = s:option(DummyValue, "_status", translate("服务状态"))
status.template = "device_qos/status"

return m
