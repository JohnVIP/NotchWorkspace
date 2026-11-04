# Notch Workspace V1.0 · 源码审计与开发方案

更新日期 2026-11-05。

## 1. 源码基线

- 当前开发分支为 `codex/trim-ai-usage`，审计参照提交 `22f4945`。最初的上游只读审计基于 `1822c2b17de31c0c707dda185b357b5609b4c77a`。GitHub 仓库为独立的 `JohnVIP/NotchWorkspace`。
- 开发版保留 Calendar、Tasks、Shelf、Notes、Shortcuts、Timer 和 Agents。AI Usage、Quick Share、混音、媒体、镜头、剪贴板历史、网速监测、App Store 构建路径及 MediaRemote 子模块已移除。依据为 `App/AppDelegate.swift` 的 `featureList`、`Package.swift` 的 targets 和 `project.yml`。
- NW-006 已实现运行隔离。Bundle ID 为 `io.github.johnvip.notchworkspace`，数据写入 `~/Library/Application Support/NotchWorkspace`，展示入口为 `notchworkspace://show`。本地默认 ad hoc 签名，更新通过源码手动构建。依据为 `project.yml`、`App/Info.plist`、`Sources/NotchFeatures/Shared.swift` 的 `AppSupport.file` 和 `docs/updates.md`。
- 已有证据来自旧机器的 x86_64 Debug 构建、应用包隔离检查和 80 项定向测试。Apple Silicon 构建、实体刘海交互、权限弹窗及实际 Agent CLI 联动仍待验证。

## 2. 后续开发与验收环境

| 项目 | 基线 |
|---|---|
| 硬件 | 带实体刘海的 Apple Silicon MacBook，原生 `arm64` 构建与运行。单屏和开盖双屏都在该设备验收 |
| macOS | 开工时 Apple 已发布、该机型可安装的最新稳定版，记录具体版本和系统构建号 |
| Xcode | 开工时 Apple 已发布、与所选 macOS 兼容的最新稳定版，记录 Xcode 版本、构建号、macOS SDK 和 Swift 版本 |
| 辅助工具 | 使用本机 XcodeGen，记录版本。Homebrew 是项目提供的安装路径之一 |
| 当前部署下限 | `project.yml` 和 `Package.swift` 仍声明 macOS 14.6，SwiftPM 清单要求 Swift tools 6.2。提升开发环境与调整部署下限分开决策 |

「最新版」在新机开工时按 Apple 的发布清单和 Xcode 兼容表确定，随后将实际版本固定到当轮验收记录。主环境采用稳定版，Beta 和 RC 如需试用，单独留证。参考 [Apple 系统发布清单](https://support.apple.com/en-us/100100)和 [Xcode SDK 与系统兼容表](https://developer.apple.com/xcode/system-requirements/)。

### NW-003 · 建立 arm64 构建基线

在新 Mac 上检出个人版固定提交，先记录型号、芯片、提交和工具链，再执行以下检查。

```sh
uname -m
sw_vers
xcodebuild -version
xcrun --sdk macosx --show-sdk-version
swift --version
xcodegen --version
make check-isolation ARCH=arm64 SIGNING_IDENTITY=
make test
```

验收证据包括 `arm64` 应用包、签名与 Bundle ID、URL 入口、更新字段隔离结果，以及测试通过数和失败项。记录同一配置的 Debug 交互构建与 Release 性能构建。原版 `1822c2b` 留作历史对照，日常开发基线使用已隔离的个人版。

### NW-005 · 建立真机运行基线

先用模拟数据验收首次启动、点击与快捷键、Esc、拖放及菜单栏穿透，再检查单屏、外接主屏、热插拔、缩放、全屏、睡眠和锁屏。记录焦点归还、面板残留及空闲 CPU、内存。确认个人版数据路径后，再在单独步骤验证系统权限和真实 hooks。

## 3. V1.0 开发顺序

| 阶段 | 源码边界 | 验收 |
|---|---|---|
| NW-102 · 双侧状态原型 | 在 `Sources/NotchSurface/NotchView.swift` 与 `NotchMetrics.swift` 中复用现有呈现和几何，分别输入模拟倒计时与 Agent 状态 | 左右各一项，分别按可用宽度降级为图标或隐藏。真机验证不覆盖系统菜单和摄像头壳体 |
| NW-103～107 · 四态和交互 | 复用 `Sources/NotchCore/NotchState.swift` 的 `handle`、`NotchEngine.send` 及 `Sources/NotchSurface/NotchWindow.swift` 的非激活面板。把静默、常驻、提醒、展开映射到现有状态，保留键盘输入和系统暂停语义 | 点击优先，悬停可选。验证两种展开入口的 Esc、焦点归还、全屏及锁屏恢复 |
| R-04～05 · 屏幕与场景 | 在 `Sources/NotchSurface/PanelCoordinator.swift` 的 `rebuild` 附近加入内建屏过滤，再实现家庭显示器登记和手动覆盖 | 外接屏不重复显示。开盖、合盖、热插拔、唤醒及连接未知屏的结果可预测 |
| R-06～07 · 仲裁与隐私 | 现有 `PanelCoordinator.setOngoing` 选取一个常驻活动。将优先级、有效期、去重和限流建为独立可测试逻辑。审查 `NotchEngine.send` 的公开日志和界面、无障碍文本 | 同时到达的会议和 Agent 事件按规则展示。锁屏与演示模式隐藏敏感内容，日志只留诊断所需字段 |
| R-08～12 · 工作流接入 | 复用 `CalendarFeature.watchMeetings`、`AgentHooks.install`、`ShortcutsFeature.run` 及 `ShowInNotch.activity`。为指定 Xcode 构建动作新增类型化事件 | 验证 10/5/2 分钟提醒、真实待授权状态、构建成功与失败、预设快捷动作。Agent 审批由用户在原终端完成 |

R-13 的 Career Memory 接口另行设计，R-14 的 Worktile 深度集成不进入 V1.0。许可与第三方声明继续保留。新代码优先复用现有 Core、Surface、Features、Agents 四层边界。

## 4. 下一步与回滚

下一步是 **NW-003 的 Apple Silicon 构建验证**，随后完成 NW-005 真机基线，再启动 NW-102 双侧模拟状态。每项以独立提交交付，记录测试和真机证据。功能回归时撤回对应提交，或从上一份通过隔离检查的个人版提交重新构建。
