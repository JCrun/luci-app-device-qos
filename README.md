# LuCI App Device QoS

## 项目简介

`luci-app-device-qos` 是一个为 OpenWrt 路由器设计的 LuCI 应用，提供用户友好的图形界面，允许用户精确控制 **特定设备上特定应用** 的上传和下载带宽，无需直接操作复杂的命令行。

### 核心特性

- **应用识别**：通过域名列表识别应用流量（抖音、哔哩哔哩、腾讯视频等）
- **设备级控制**：为不同设备（手机、电视、电脑等）配置独立的限速规则
- **精确限速**：为每个设备的每个应用单独设置上传/下载的保证带宽和上限带宽
- **灵活管理**：支持启用/禁用全局服务、单个应用、单个设备
- **自动化**：自动通过 dnsmasq + ipset 识别应用 IP，通过 iptables + tc 实现流量控制

## 功能需求

### 一、基本功能

#### 1. 全局启用/禁用功能
- 一键启用或禁用整个应用流量 QoS 服务
- 不影响路由器其他网络功能

#### 2. WAN/LAN 接口配置
- 选择路由器的 WAN 接口（互联网连接）
- 选择路由器的 LAN 接口（局域网连接）
- 确保限速规则应用到正确的网络路径

#### 3. 总带宽配置
- 配置 ISP 提供的总上传和下载带宽
- 作为流量控制的基础，避免过度限速

### 二、应用定义与管理

#### 应用配置功能
- **应用列表管理**：查看、添加、编辑、删除应用定义
- **应用名称**：用户友好的名称（例如"抖音短视频"）
- **应用描述**：可选的详细描述
- **域名列表**：支持多个域名，用于识别应用流量
- **Fwmark 基准值**：每个应用的唯一标记，用于内核层面的流量识别

#### 示例应用配置
- 抖音短视频：douyin.com, amemv.com, snssdk.com, bytecdn.cn
- 哔哩哔哩：bilibili.com, bilivideo.com, biliapi.net, hdslb.com
- 腾讯视频：v.qq.com, video.qq.com, vv.video.qq.com

### 三、设备管理

#### 设备配置功能
- **设备列表管理**：查看、添加、编辑、删除设备
- **设备启用/禁用**：独立控制每个设备的限速规则
- **设备名称**：用户友好的名称（例如"小明的手机"）
- **设备描述**：可选的设备型号或备注
- **设备 IP 地址**：必须是固定 IP（建议通过 DHCP 静态分配）

### 四、限速规则配置

#### 限速规则功能
- **规则列表管理**：查看、添加、编辑、删除限速规则
- **设备选择**：从已配置的设备列表中选择
- **应用选择**：从已配置的应用列表中选择
- **上传限速**：
  - 上行保证（Rate）：最小保证上传带宽
  - 上行上限（Ceil）：最大上传带宽
- **下载限速**：
  - 下行保证（Rate）：最小保证下载带宽
  - 下行上限（Ceil）：最大下载带宽

#### 带宽单位支持
- kbit（千比特/秒）
- mbit（兆比特/秒）
- 示例：512kbit, 1mbit, 10mbit

## 技术架构

### 工作原理

1. **域名解析与 IP 收集**
   - 通过 dnsmasq 的 ipset 功能，将配置的域名解析的 IP 地址自动加入对应的 ipset 集合
   - 每个应用对应一个独立的 ipset 集合

2. **流量标记**
   - 使用 iptables mangle 表，根据源/目标 IP（ipset）和设备 IP，为匹配的数据包打上 fwmark 标记
   - 标记规则：fwmark = fwmark_base + limit_rule_index

3. **流量控制**
   - 使用 tc（Traffic Control）的 HTB（Hierarchical Token Bucket）算法
   - 根据 fwmark 标记，将流量分配到对应的 tc class
   - 每个 class 设置独立的 rate（保证带宽）和 ceil（最大带宽）

### 核心组件

- **LuCI 界面**：Lua 编写的 Web 管理界面
- **UCI 配置**：OpenWrt 统一配置接口
- **dnsmasq**：DNS 服务器，支持 ipset 集成
- **ipset**：内核 IP 地址集合，高效匹配
- **iptables**：netfilter 防火墙，流量标记
- **tc**：Linux 流量控制工具，带宽管理

## 安装

### 方法一：使用预编译的 IPK 包

```bash
# 上传 IPK 包到路由器
scp luci-app-device-qos_*.ipk root@192.168.1.1:/tmp/

# SSH 登录路由器
ssh root@192.168.1.1

# 安装依赖和软件包
opkg update
opkg install tc ipset iptables-mod-ipopt
opkg install /tmp/luci-app-device-qos_*.ipk
```

### 方法二：从源码编译

```bash
# 将项目复制到 OpenWrt 源码目录
cp -r luci-app-device-qos /path/to/openwrt/package/luci/applications/

# 编译
cd /path/to/openwrt
make package/luci/applications/luci-app-device-qos/compile V=s
```

## 配置指南

### 步骤 1：全局设置

1. 登录路由器 LuCI 界面
2. 进入 **网络 → 设备应用限速 → 全局设置**
3. 配置以下参数：
   - **启用服务**：勾选启用
   - **WAN 接口**：通常是 `wan`
   - **LAN 接口**：通常是 `br-lan` 或 `lan`
   - **总上传带宽**：填写您的实际上传带宽（Mbps）
   - **总下载带宽**：填写您的实际下载带宽（Mbps）
4. 点击 **保存并应用**

### 步骤 2：添加应用

1. 进入 **网络 → 设备应用限速 → 应用管理**
2. 点击 **添加**，配置应用信息：
   - **Section ID**：英文标识（例如：`douyin`）
   - **启用**：勾选
   - **应用名称**：抖音短视频
   - **应用描述**：抖音及其相关 CDN 域名
   - **Fwmark 基准值**：1000（每个应用使用不同的值，建议间隔 1000）
   - **域名列表**：
     ```
     douyin.com
     amemv.com
     snssdk.com
     bytecdn.cn
     ```
3. 点击 **保存并应用**

重复以上步骤添加更多应用（哔哩哔哩、腾讯视频等）

### 步骤 3：添加设备

1. 进入 **网络 → 设备应用限速 → 设备管理**
2. 点击 **添加**，配置设备信息：
   - **Section ID**：英文标识（例如：`phone1`）
   - **启用**：勾选
   - **设备名称**：小明的手机
   - **设备描述**：华为 Mate 40
   - **IP 地址**：192.168.1.100
3. 点击 **保存并应用**

**注意**：设备必须使用固定 IP 地址，建议在 DHCP 设置中配置静态 IP 分配。

### 步骤 4：配置限速规则

1. 进入 **网络 → 设备应用限速 → 限速规则**
2. 点击 **添加**，配置限速规则：
   - **Section ID**：英文标识（例如：`phone1_douyin`）
   - **目标设备**：选择"小明的手机"
   - **应用**：选择"抖音短视频"
   - **上行保证**：512kbit（最小保证上传带宽）
   - **上行上限**：1mbit（最大上传带宽）
   - **下行保证**：2mbit（最小保证下载带宽）
   - **下行上限**：5mbit（最大下载带宽）
3. 点击 **保存并应用**

重复以上步骤为不同设备和应用组合添加限速规则。

### 步骤 5：应用配置并启动服务

1. 确保所有配置保存后，服务会自动重载
2. 检查服务状态：
   ```bash
   /usr/sbin/device-qos status
   ```
3. 手动重启服务（如需要）：
   ```bash
   /etc/init.d/device-qos restart
   ```

## 配置文件示例

完整的 UCI 配置示例（`/etc/config/device_qos`）：

```
# 全局配置
config global 'global'
	option enabled '1'
	option wan_if 'wan'
	option lan_if 'br-lan'
	option up_mbps '100'
	option down_mbps '100'

# 应用：抖音
config app 'douyin'
	option enabled '1'
	option name '抖音短视频'
	option desc '抖音及其相关CDN域名'
	option fwmark_base '1000'
	list domains 'douyin.com'
	list domains 'amemv.com'
	list domains 'snssdk.com'
	list domains 'bytecdn.cn'

# 应用：哔哩哔哩
config app 'bilibili'
	option enabled '1'
	option name '哔哩哔哩'
	option desc 'B站视频及直播'
	option fwmark_base '2000'
	list domains 'bilibili.com'
	list domains 'bilivideo.com'
	list domains 'biliapi.net'
	list domains 'hdslb.com'

# 设备：小明的手机
config device 'phone1'
	option enabled '1'
	option name '小明的手机'
	option desc '华为 Mate 40'
	option ip '192.168.1.100'

# 限速规则：小明的手机 - 抖音
config device_limit 'phone1_douyin'
	option device 'phone1'
	option app 'douyin'
	option up_rate '512kbit'
	option up_ceil '1mbit'
	option down_rate '2mbit'
	option down_ceil '5mbit'

# 限速规则：小明的手机 - 哔哩哔哩
config device_limit 'phone1_bilibili'
	option device 'phone1'
	option app 'bilibili'
	option up_rate '1mbit'
	option up_ceil '2mbit'
	option down_rate '3mbit'
	option down_ceil '10mbit'
```

## 常见问题

### 1. 限速不生效怎么办？

**检查步骤**：
- 确认全局服务已启用
- 确认目标设备和应用都已启用
- 检查设备 IP 是否正确
- 查看系统日志：`logread | grep device-qos`
- 检查 tc 规则：`tc -s class show dev wan`
- 检查 iptables 规则：`iptables -t mangle -L DEVICE_QOS_UP -v -n`

### 2. 如何确定应用的域名列表？

**方法**：
- 使用抓包工具（Wireshark）观察应用流量
- 查看 DNS 查询记录：`logread | grep dnsmasq`
- 参考网上已有的域名列表资源
- 测试并逐步完善域名列表

### 3. Fwmark 基准值如何设置？

**建议**：
- 每个应用使用不同的基准值
- 建议间隔 1000（例如：1000, 2000, 3000）
- 确保 fwmark_base + 限速规则数量 < 下一个应用的 fwmark_base
- 避免与其他系统服务的 fwmark 冲突

### 4. Rate 和 Ceil 的区别？

- **Rate（保证带宽）**：即使网络拥堵，该应用也能获得的最小带宽
- **Ceil（最大带宽）**：该应用能使用的最大带宽上限

**示例**：
```
up_rate='512kbit'  # 保证至少 512kbit 上传
up_ceil='2mbit'    # 最多不超过 2mbit 上传
```

### 5. 如何调试？

```bash
# 查看服务状态
/usr/sbin/device-qos status

# 查看系统日志
logread | grep device-qos

# 查看 tc 规则和统计
tc -s qdisc show dev wan
tc -s class show dev wan

# 查看 iptables 规则
iptables -t mangle -L -v -n

# 查看 ipset 内容
ipset list app_douyin_ips

# 测试域名是否被正确分配到 ipset
nslookup douyin.com
ipset test app_douyin_ips <解析出的IP>
```

## 卸载

```bash
# 停止服务
/etc/init.d/device-qos stop
/etc/init.d/device-qos disable

# 卸载软件包
opkg remove luci-app-device-qos
```

## 注意事项

1. **固定 IP**：设备必须使用固定 IP 地址，否则限速规则无法正确匹配
2. **域名完整性**：应用的域名列表需要尽可能完整，否则部分流量可能无法被识别
3. **带宽设置**：总带宽应设置为实际带宽的 90-95%，避免 ISP 端的排队延迟
4. **性能影响**：过多的限速规则可能影响路由器性能，建议根据实际需求配置
5. **HTTPS 流量**：本方案基于域名识别，对 HTTPS 流量同样有效（通过 DNS 查询识别）

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 更新日志

### v1.0.0 (2026-01-09)
- 完整重写项目结构
- 优化 UCI 配置模型
- 改进 LuCI 界面用户体验
- 增强后端脚本的稳定性和日志功能
- 添加详细的配置验证和错误提示
- 完善文档和使用说明
