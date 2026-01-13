-- 设备应用限速 - 全局设置
local m = Map("device_qos", translate("全局设置"),
	translate("配置设备应用限速的基本参数和服务状态"))

-- 服务状态面板
local status_section = m:section(SimpleSection, nil, translate("服务状态"))
status_section.template = "device_qos/status"

-- 基本配置区域
local s = m:section(TypedSection, "global", translate("基本配置"))
s.anonymous = true
s.addremove = false

local enabled = s:option(Flag, "enabled", translate("启用服务"),
	translate("启用或禁用整个应用流量QoS服务。关闭时所有限速规则将不生效。"))
enabled.rmempty = false
enabled.default = "0"

-- 网络接口配置
local iface_section = m:section(SimpleSection, nil, translate("网络接口配置"))
iface_section.description = translate("配置用于流量识别的网络接口")

local s_iface = m:section(TypedSection, "global", "")
s_iface.anonymous = true
s_iface.addremove = false

local wan = s_iface:option(Value, "wan_if", translate("WAN 接口"),
	translate("用于互联网连接的接口名称，通常为 wan、eth1 或 pppoe-wan"))
wan.datatype = "string"
wan.default = "wan"
wan.placeholder = "wan"
wan.size = 20

local lan = s_iface:option(Value, "lan_if", translate("LAN 接口"),
	translate("用于局域网连接的接口名称，通常为 lan 或 br-lan"))
lan.datatype = "string"
lan.default = "lan"
lan.placeholder = "br-lan"
lan.size = 20

-- 带宽配置
local bw_section = m:section(SimpleSection, nil, translate("带宽配置"))
bw_section.description = translate("配置总带宽，建议设置为实际带宽的 90-95% 以避免ISP端排队延迟")

local s_bw = m:section(TypedSection, "global", "")
s_bw.anonymous = true
s_bw.addremove = false

local up = s_bw:option(Value, "up_mbps", translate("总上传带宽"),
	translate("您的ISP提供的实际上传带宽（Mbps）"))
up.datatype = "and(uinteger,min(1))"
up.default = "100"
up.placeholder = "100"
up.size = 15

local down = s_bw:option(Value, "down_mbps", translate("总下载带宽"),
	translate("您的ISP提供的实际下载带宽（Mbps）"))
down.datatype = "and(uinteger,min(1))"
down.default = "100"
down.placeholder = "100"
down.size = 15

return m
