-- Device App QoS - Global Settings
local m = Map("device_qos", translate("Global Settings"),
	translate("Configure basic parameters and service status for device app QoS"))

-- 添加提交后的处理函数
m.on_after_commit = function(self)
	local sys = require "luci.sys"
	local uci = require "luci.model.uci".cursor()
	local enabled = uci:get("device_qos", "global", "enabled") or "0"

	if enabled == "1" then
		-- 启用服务时，重启以应用新配置
		sys.call("/etc/init.d/device-qos restart >/dev/null 2>&1")
	else
		-- 禁用服务时，停止服务
		sys.call("/etc/init.d/device-qos stop >/dev/null 2>&1")
	end
end

-- Service Status Panel
local status_section = m:section(SimpleSection, nil, translate("Service Status"))
status_section.template = "device_qos/status"

-- Basic Configuration
local s = m:section(TypedSection, "global", translate("Basic Configuration"))
s.anonymous = true
s.addremove = false

local enabled = s:option(Flag, "enabled", translate("Enable Service"),
	translate("Enable or disable the entire app traffic QoS service. When disabled, all rate limit rules will not take effect."))
enabled.rmempty = false
enabled.default = "0"

-- Network Interface Configuration
local iface_section = m:section(SimpleSection, nil, translate("Network Interface Configuration"))
iface_section.description = translate("Configure network interfaces for traffic identification")

local s_iface = m:section(TypedSection, "global", "")
s_iface.anonymous = true
s_iface.addremove = false

local wan = s_iface:option(Value, "wan_if", translate("WAN Interface"),
	translate("Interface name for internet connection, usually wan, eth1 or pppoe-wan"))
wan.datatype = "string"
wan.default = "wan"
wan.placeholder = "wan"
wan.size = 20

local lan = s_iface:option(Value, "lan_if", translate("LAN Interface"),
	translate("Interface name for LAN connection, usually lan or br-lan"))
lan.datatype = "string"
lan.default = "lan"
lan.placeholder = "br-lan"
lan.size = 20

-- Bandwidth Configuration
local bw_section = m:section(SimpleSection, nil, translate("Bandwidth Configuration"))
bw_section.description = translate("Configure total bandwidth, recommend setting to 90-95% of actual bandwidth to avoid ISP queuing delay")

local s_bw = m:section(TypedSection, "global", "")
s_bw.anonymous = true
s_bw.addremove = false

local up = s_bw:option(Value, "up_mbps", translate("Total Upload Bandwidth"),
	translate("Actual upload bandwidth provided by your ISP (Mbps)"))
up.datatype = "and(uinteger,min(1))"
up.default = "100"
up.placeholder = "100"
up.size = 15

local down = s_bw:option(Value, "down_mbps", translate("Total Download Bandwidth"),
	translate("Actual download bandwidth provided by your ISP (Mbps)"))
down.datatype = "and(uinteger,min(1))"
down.default = "100"
down.placeholder = "100"
down.size = 15

return m
