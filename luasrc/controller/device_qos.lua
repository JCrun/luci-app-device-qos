module("luci.controller.device_qos", package.seeall)
function index()
 entry({"admin","network","device_qos"}, firstchild(), _("Device App QoS"), 60)
 entry({"admin","network","device_qos","global"}, cbi("device_qos/global"), _("Global Settings"), 10).leaf = true
 entry({"admin","network","device_qos","apps"}, cbi("device_qos/apps"), _("App Management"), 20).leaf = true
 entry({"admin","network","device_qos","providers"}, cbi("device_qos/providers"), _("Rule Sources"), 25).leaf = true
 entry({"admin","network","device_qos","devices"}, cbi("device_qos/devices"), _("Device Management"), 30).leaf = true
 entry({"admin","network","device_qos","limits"}, cbi("device_qos/limits"), _("Rate Limits"), 40).leaf = true
 entry({"admin","network","device_qos","service"}, call("action_service"), _("Service Control"), 50).leaf = true
 entry({"admin","network","device_qos","update_rules"}, call("action_update_rules"), nil).leaf = true
end
function action_service()
	local http = require "luci.http"
	local sys = require "luci.sys"
	local cmd = http.formvalue("cmd")
	local ok = false

	if cmd == "start" then
		ok = (sys.call("/etc/init.d/device-qos start >/dev/null 2>&1") == 0)
	elseif cmd == "stop" then
		ok = (sys.call("/etc/init.d/device-qos stop >/dev/null 2>&1") == 0)
	elseif cmd == "restart" or cmd == "reload" then
		ok = (sys.call("/etc/init.d/device-qos reload >/dev/null 2>&1") == 0)
	end

	http.prepare_content("application/json")
	http.write_json({success = ok})
end
function action_update_rules()
	local http = require "luci.http"
	local sys = require "luci.sys"

	-- 执行规则更新脚本
	local result = sys.call("/usr/libexec/device-qos/rules-update >/tmp/rules-update.log 2>&1")

	-- 准备反馈消息
	local success = (result == 0)
	local message = success and "Rules updated successfully!" or "Rules update failed, please check system log."

	-- 重定向回规则源页面，带上消息
	http.redirect(luci.dispatcher.build_url("admin", "network", "device_qos", "providers"))
end