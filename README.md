# Notch Workspace

Notch Workspace 是面向 MacBook 刘海的本地优先工作台。它把日历、提醒事项、文件托盘、速记、计时器、系统快捷指令和 Codex／Claude Code 状态集中在一个入口，方便在办公和开发时查看下一步要做的事。

项目源自 [ILoveNotch](https://github.com/niyamvora/ILoveNotch)，现作为独立仓库维护，采用 SwiftUI 和 AppKit，保留上游 MIT 许可及第三方声明。

## 当前进度

**V1.0 开发中。** 精简和运行隔离已落在 [当前开发分支](https://github.com/JohnVIP/NotchWorkspace/tree/codex/trim-ai-usage)。该分支保留日历、提醒事项、Shelf、速记、计时器、快捷指令和 Agents，并使用独立的应用身份、设置和数据目录。

开发分支已完成 x86_64 本地 Debug 构建和应用包隔离检查。Apple Silicon 实体刘海、多屏交互和首次权限行为仍待真机验证。此处的 `main` 保留原始代码基线和项目入口说明。

## V1.0 计划

- **办公** · 从内建屏查看会议倒计时和当日待办，使用文件托盘、速记和常用快捷操作。
- **开发** · 在内建屏查看专注计时、Agent 运行和待授权状态，以及由指定构建动作发出的 Xcode 结果。Agent 授权由用户在原终端处理。
- **双屏与低干扰** · 在内建刘海两侧显示简短状态，接入已登记的家庭显示器时切换开发预设，并提供手动覆盖与演示隐私模式。

## 从源码构建

当前个人版源码和构建命令见 [开发分支 README](https://github.com/JohnVIP/NotchWorkspace/blob/codex/trim-ai-usage/README.md)。运行前可先查看[应用身份、数据位置和回滚说明](https://github.com/JohnVIP/NotchWorkspace/blob/codex/trim-ai-usage/docs/updates.md)。

## 许可

[MIT 许可证](LICENSE) · [第三方声明](THIRD_PARTY_NOTICES.md)
