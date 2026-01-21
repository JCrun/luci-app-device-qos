# Changelog

## [1.0.0-2] - 2026-01-22

### Changed

- **Internationalization**: Converted all Chinese strings to English with i18n support
- All Lua controller, CBI model, and HTM view files now use `translate()` and `<%:%>` syntax

### Added

- **Translation Support**: Added `po/templates/device-qos.pot` template file
- **Chinese Translation**: Added `po/zh_Hans/device-qos.po` for Chinese localization
- Separate `luci-i18n-device-qos-zh-cn` package will be generated during build

## [1.0.0] - Initial Release

### Features

- Per-device per-application bandwidth control
- Support for Hikvision, TP-Link and generic RTSP/RTMP cameras
- NFTables-based traffic marking and shaping
- External rule source subscription (Clash Rule Set)
- Real-time service status monitoring
- Configurable upload/download rate limits with guaranteed and ceiling bandwidth
