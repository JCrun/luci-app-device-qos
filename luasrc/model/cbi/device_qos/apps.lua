-- 设备应用限速 - 应用管理
local m = Map("device_qos", translate("应用管理"),
	translate("定义需要限速的应用及其域名列表。应用通过域名识别，支持多个域名。"))

local s = m:section(TypedSection, "app", translate("应用列表"))
s.addremove = true
s.anonymous = false
s.template = "cbi/tblsection"

-- 启用/禁用单个应用
local en = s:option(Flag, "enabled", translate("启用"))
en.rmempty = false
en.default = "1"
en.width = "6%"

-- 应用名称
local name = s:option(Value, "name", translate("应用名称"),
	translate("用户友好的应用名称，例如：抖音短视频、哔哩哔哩"))
name.rmempty = false
name.placeholder = "抖音短视频"
name.width = "18%"

-- 应用描述
local desc = s:option(Value, "desc", translate("描述"),
	translate("可选的应用描述或说明"))
desc.placeholder = "应用说明"
desc.width = "20%"

-- 防火墙标记基准值
local base = s:option(Value, "fwmark_base", translate("标记值"),
	translate("防火墙标记基准值，用于内核识别。建议：1000、2000、3000..."))
base.datatype = "and(uinteger,min(100))"
base.rmempty = false
base.placeholder = "1000"
base.width = "10%"

-- 域名列表
local domains = s:option(DynamicList, "domains", translate("域名列表"),
	translate("与该应用相关的域名，每行一个域名。例如：douyin.com、bytecdn.cn"))
domains.rmempty = false
domains.placeholder = "example.com"

-- 添加验证
function domains.validate(self, value, section)
	if not value or #value == 0 then
		return nil, translate("至少需要添加一个域名")
	end
	return value
end

function base.validate(self, value, section)
	if not value then
		return nil, translate("Fwmark 基准值不能为空")
	end

	local num = tonumber(value)
	if not num or num < 100 then
		return nil, translate("Fwmark 基准值必须大于等于 100")
	end

	-- 检查是否与其他应用冲突
	local uci = require "luci.model.uci".cursor()
	uci:foreach("device_qos", "app", function(s)
		if s[".name"] ~= section then
			local other_base = tonumber(s.fwmark_base or 0)
			if other_base == num then
				return nil, translate("Fwmark 基准值与其他应用冲突")
			end
		end
	end)

	return value
end

return m
