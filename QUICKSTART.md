# 快速开始指南

## 5 分钟快速配置

### 1. 安装依赖

```bash
opkg update
opkg install tc kmod-sched ipset iptables-mod-ipopt dnsmasq-full
```

### 2. 全局设置

进入 **网络 → 设备应用限速 → 全局设置**

- ✅ 启用服务
- WAN 接口：`wan`
- LAN 接口：`br-lan`
- 总上传带宽：`100` (Mbps)
- 总下载带宽：`100` (Mbps)

保存并应用

### 3. 添加应用（以抖音为例）

进入 **网络 → 设备应用限速 → 应用管理** → 添加

- Section ID: `douyin`
- ✅ 启用
- 应用名称：`抖音短视频`
- 应用描述：`抖音及相关CDN`
- Fwmark 基准值：`1000`
- 域名列表：
  ```
  douyin.com
  amemv.com
  snssdk.com
  bytecdn.cn
  ```

保存并应用

### 4. 添加设备

进入 **网络 → 设备应用限速 → 设备管理** → 添加

- Section ID: `phone1`
- ✅ 启用
- 设备名称：`小明的手机`
- 设备描述：`华为 Mate 40`
- IP 地址：`192.168.1.100`

保存并应用

**重要**：确保设备使用固定 IP（在 DHCP 设置中配置静态租约）

### 5. 添加限速规则

进入 **网络 → 设备应用限速 → 限速规则** → 添加

- Section ID: `phone1_douyin`
- 目标设备：`小明的手机`
- 应用：`抖音短视频`
- 上行保证：`512kbit`
- 上行上限：`1mbit`
- 下行保证：`2mbit`
- 下行上限：`5mbit`

保存并应用

### 6. 验证

```bash
# 查看服务状态
/usr/sbin/device-qos status

# 查看 TC 规则
tc -s class show dev wan

# 查看日志
logread | grep device-qos
```

## 配置示例

### 常见应用域名列表

#### 抖音（TikTok）
```
douyin.com
amemv.com
snssdk.com
bytecdn.cn
tiktokcdn.com
```

#### 哔哩哔哩（Bilibili）
```
bilibili.com
bilivideo.com
biliapi.net
hdslb.com
biligame.com
```

#### 腾讯视频
```
v.qq.com
video.qq.com
vv.video.qq.com
```

#### YouTube
```
youtube.com
googlevideo.com
ytimg.com
```

#### Netflix
```
netflix.com
nflxvideo.net
nflxext.com
nflximg.net
```

### 带宽配置建议

#### 轻度限制（允许基本使用）
- 上行保证：512kbit，上行上限：2mbit
- 下行保证：2mbit，下行上限：10mbit

#### 中度限制（标清视频）
- 上行保证：256kbit，上行上限：1mbit
- 下行保证：1mbit，下行上限：5mbit

#### 严格限制（仅文字和图片）
- 上行保证：128kbit，上行上限：512kbit
- 下行保证：512kbit，下行上限：2mbit

## 故障排查

### 问题：限速不生效

**解决步骤**：

1. 检查全局服务是否启用
   ```bash
   uci get device_qos.global.enabled
   ```

2. 检查设备和应用是否启用
   ```bash
   uci show device_qos | grep enabled
   ```

3. 检查 ipset 是否创建
   ```bash
   ipset list | grep app_
   ```

4. 检查域名是否解析到 ipset
   ```bash
   # 先解析域名
   nslookup douyin.com
   # 检查 IP 是否在 ipset 中
   ipset test app_douyin_ips <IP地址>
   ```

5. 检查 iptables 规则
   ```bash
   iptables -t mangle -L DEVICE_QOS_UP -v -n
   ```

6. 检查 tc 规则
   ```bash
   tc -s class show dev wan
   tc -s class show dev br-lan
   ```

### 问题：域名解析后 IP 没有加入 ipset

**可能原因**：
- dnsmasq 配置未生效
- 域名已被缓存

**解决方法**：
```bash
# 重启 dnsmasq
/etc/init.d/dnsmasq restart

# 清除 DNS 缓存（客户端）
# Android: 重启飞行模式
# iOS: 设置 → 通用 → 还原 → 还原网络设置
# Windows: ipconfig /flushdns
```

### 问题：设备 IP 改变

**解决方法**：
1. 在 LuCI 进入 **网络 → DHCP/DNS → 静态租约**
2. 添加设备的 MAC 地址和固定 IP
3. 重启设备获取新 IP

## 进阶技巧

### 1. 批量导入应用配置

编辑 `/etc/config/device_qos`，直接添加配置块：

```bash
uci set device_qos.youtube=app
uci set device_qos.youtube.enabled=1
uci set device_qos.youtube.name='YouTube'
uci set device_qos.youtube.fwmark_base=4000
uci add_list device_qos.youtube.domains='youtube.com'
uci add_list device_qos.youtube.domains='googlevideo.com'
uci commit device_qos
/etc/init.d/device-qos reload
```

### 2. 查看实时流量统计

```bash
# 循环显示 tc 统计
watch -n 1 'tc -s class show dev wan'
```

### 3. 临时禁用某个设备的限速

```bash
uci set device_qos.phone1.enabled=0
uci commit device_qos
/etc/init.d/device-qos reload
```

### 4. 备份配置

```bash
# 备份配置文件
cp /etc/config/device_qos /etc/config/device_qos.backup

# 或导出为可读格式
uci export device_qos > /tmp/device_qos_backup.uci
```

## 性能优化

### 对于低性能路由器

1. 减少限速规则数量
2. 使用更大的 fwmark_base 间隔
3. 减少域名列表数量，只保留核心域名
4. 考虑只对部分设备启用限速

### 对于高性能路由器

1. 可以配置更多的限速规则
2. 可以添加更详细的域名列表
3. 可以使用更小的带宽粒度

## 联系支持

如遇到问题，请提供以下信息：

```bash
# 收集调试信息
cat /etc/config/device_qos
tc -s qdisc show
tc -s class show dev wan
iptables -t mangle -L -v -n
ipset list
logread | grep device-qos
```

将以上输出保存并提交 Issue。
