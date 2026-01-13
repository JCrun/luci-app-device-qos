module("luci.controller.device_qos", package.seeall)
function index()
 entry({"admin","network","device_qos"}, firstchild(), "设备应用限速", 60)
 entry({"admin","network","device_qos","global"}, cbi("device_qos/global"), "全局设置", 10).leaf = true
 entry({"admin","network","device_qos","apps"}, cbi("device_qos/apps"), "应用管理", 20).leaf = true
 entry({"admin","network","device_qos","providers"}, cbi("device_qos/providers"), "规则源", 25).leaf = true
 entry({"admin","network","device_qos","devices"}, cbi("device_qos/devices"), "设备管理", 30).leaf = true
 entry({"admin","network","device_qos","limits"}, cbi("device_qos/limits"), "限速规则", 40).leaf = true
 entry({"admin","network","device_qos","service"}, call("action_service"), "服务控制", 50).leaf = true
end
function action_service()
 local http = require "luci.http"
 local util = require "luci.util"
 local cmd = http.formvalue("cmd")
 local ok = false
 if cmd == "start" then ok = util.exec("/etc/init.d/device-qos start") == "" end
 if cmd == "stop" then ok = util.exec("/etc/init.d/device-qos stop") == "" end
 if cmd == "restart" or cmd == "reload" then ok = util.exec("/etc/init.d/device-qos reload") == "" end
 http.prepare_content("application/json")
 http.write_json({success=ok})
end
