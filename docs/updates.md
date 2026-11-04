# Notch Workspace 运行隔离

## 个人版身份

| 项目 | 本地构建 |
|---|---|
| 应用包与进程 | `NotchWorkspace.app` / `NotchWorkspace` |
| Bundle ID 与偏好域 | `io.github.johnvip.notchworkspace`，使用该应用的 `UserDefaults.standard` |
| 本地数据 | `~/Library/Application Support/NotchWorkspace`，含 Notes、Shelf、Agent 状态和备份 |
| URL 入口 | `notchworkspace://show`，仍只展示消息 |
| 默认快捷键 | `⌃⌥W` 展开，`⌃⌥⇧N` 速记 |
| 签名 | 本地和 CI 使用 ad hoc；需要稳定权限时，可显式使用已有 Apple Development 证书 |
| 更新 | 从个人源码检出手动构建。应用无 Sparkle、更新源和自动替换流程 |

个人版从自己的偏好和数据目录开始。日历与提醒事项在用户授权后仍使用同一系统账户的数据，速记可由用户选择保存目录。登录项由用户在设置中打开，通过个人版的应用身份注册。若主动连接 Agents，两版仍使用 Agent 工具各自的配置文件，个人版只识别当前个人版脚本路径生成的命令。卸载前如曾连接，先在个人版内断开。

## 构建、验证与回滚

`make check-isolation SIGNING_IDENTITY=` 构建到检出目录并检查产物的 Bundle ID、URL Scheme、更新字段、框架及签名。CI 对个人分支执行同一检查。测试更新时先核对检出的分支与提交，再运行本地构建。启动只从个人版构建产物执行。

回滚个人版时，退出个人版，在独立检出构建上一份已通过隔离检查的个人版提交。首次隔离之前的源码基线应在另一检出中用作对照，验证其源码和编译即可。个人版设置、数据和已有官方应用分别保留，需要卸载个人版时可独立选择是否保留其本地数据。
