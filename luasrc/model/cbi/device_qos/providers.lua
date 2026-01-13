-- 设备应用限速 - 规则源配置
local m = Map("device_qos", translate("规则源配置"),
	translate("配置外部规则订阅源（如 Clash Rule Set），实现规则自动更新与扩充。支持从URL自动下载规则并应用到对应应用。"))

-- 添加说明信息
local info = m:section(SimpleSection, nil, translate("说明"))
info.template = "cbi/tvalue"
info.description = translate("规则源可以从外部URL自动下载域名和IP规则，并合并到对应应用中。点击"立即更新规则"按钮可手动触发更新。")

-- 规则源列表
local s = m:section(TypedSection, "provider", translate("规则源列表"))
s.template = "cbi/tblsection"
s.addremove = true
s.anonymous = false

-- 启用/禁用
local en = s:option(Flag, "enabled", translate("启用"))
en.rmempty = false
en.default = "1"
en.width = "6%"

-- 规则类型
local type_opt = s:option(ListValue, "type", translate("类型"))
type_opt:value("clash", "Clash (YAML)")
type_opt.default = "clash"
type_opt.width = "12%"

-- 关联应用
local app_opt = s:option(ListValue, "app", translate("关联应用"), translate("将下载的规则绑定到哪个应用"))
app_opt.rmempty = false
app_opt.width = "18%"

-- 动态加载已定义的应用
local uci = require "luci.model.uci".cursor()
uci:foreach("device_qos", "app", function(s)
	if s['.name'] then
		-- 显示应用名称（如果有）或 Section ID
		app_opt:value(s['.name'], s.name or s['.name'])
	end
end)

-- URL
local url = s:option(Value, "url", translate("规则 URL"), translate("Clash 规则文件的下载地址 (支持 HTTPS/jsdelivr)"))
url.rmempty = false
url.width = "45%"

-- 验证 URL
function url.validate(self, value, section)
	if not value then return nil, translate("URL 不能为空") end
	if not (value:match("^http://") or value:match("^https://")) then
		return nil, translate("必须以 http:// 或 https:// 开头")
	end
	return value
end

-- 添加更新按钮区域
local update_section = m:section(SimpleSection, nil, translate("手动更新"))
update_section.template = "device_qos/update_button"

return m
