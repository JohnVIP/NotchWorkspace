# Notch Workspace

面向 MacBook 刘海的本地优先工作台，采用 SwiftUI 和 AppKit。当前分支是 V1.0 的开发基线，包含日历、提醒事项、文件托盘、速记、计时器、系统快捷指令和 Codex／Claude Code 状态。

项目源自 [ILoveNotch](https://github.com/niyamvora/ILoveNotch)，现作为独立仓库维护。保留上游 [MIT 许可](LICENSE)与[第三方声明](THIRD_PARTY_NOTICES.md)。

## 当前进度

- 已精简上游功能并完成运行隔离。个人版使用独立的应用身份、偏好、数据目录和 URL 入口。
- 已验证 x86_64 Debug 构建和应用包隔离检查。Apple Silicon 实体刘海、多屏交互及首次权限行为待真机验证。
- V1.0 计划包括办公和开发预设、刘海两侧的简短状态、家庭显示器识别、事件优先级、演示隐私模式和受控的 Xcode 构建结果提示。

## 本地构建

运行目标为 macOS 14.6 或更高版本。构建需要 Swift 6.2 工具链、包含 macOS 26 API 的 Xcode SDK 和 XcodeGen。

```sh
make check-isolation SIGNING_IDENTITY=
make test
```

默认构建产物位于 `.build/xcode/Build/Products/Debug/NotchWorkspace.app`。`make run` 从构建目录打开个人版。个人版默认使用 ad hoc 签名，更新通过手动构建。详见[运行隔离与回滚说明](docs/updates.md)。

## 使用入口

- `⌃⌥W` 展开或收起工作台，`⌃⌥⇧N` 快速新建笔记。
- 日历和提醒事项在授权后读取系统数据。文件托盘保留拖放、Quick Look 和 AirDrop。
- 在 Agents 页手动连接 Codex 或 Claude Code。待授权状态只作提示，审批在原终端完成。
- 可通过快捷指令的 **Show in Notch** 操作或本地 URL 显示一条简短消息。

```sh
open -g 'notchworkspace://show?title=Build%20done&symbol=hammer.fill&seconds=5'
```

[隐私说明](PRIVACY.md) · [仓库首页](https://github.com/JohnVIP/NotchWorkspace)
