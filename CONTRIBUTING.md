## 贡献指南

非常欢迎你为 `luci-app-device-qos` 提交 Issue 和 Pull Request！

### 提交 Issue

- **尽量提供完整信息**：
  - 路由器型号与 CPU
  - OpenWrt 版本（例如：23.05.2）
  - 本插件版本（`luci-app-device-qos` 版本号）
  - 复现步骤
  - 预期行为 & 实际行为
- **附上调试信息（如相关）**：
  - `/etc/config/device_qos`
  - `logread | grep device-qos`
  - `tc -s class show dev wan`
  - `iptables -t mangle -L -v -n`

### 提交 Pull Request

1. Fork 本仓库并创建分支：
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. 确保代码风格与现有 Lua/Shell 代码保持一致：
   - Lua：缩进 1 Tab
   - Shell：使用 `#!/bin/sh`，兼容 `ash`
3. 为新增/变更的功能补充或更新文档（`README.md` / `QUICKSTART.md`）。
4. 本地自测通过后，提交 PR：
   - 简要说明修改内容
   - 标明是否有破坏性变更（breaking changes）

### 提交前自检清单

- [ ] 能在 OpenWrt 上正常编译/安装
- [ ] 基础功能可用（添加应用、设备、限速规则）
- [ ] 不会破坏已有配置（向后兼容）
- [ ] 日志中无明显错误/告警
- [ ] 文档已更新

### 行为准则

本项目遵循开源社区的基本礼仪和行为准则，详情见 `CODE_OF_CONDUCT.md`。

