# UU Mac Paste

在 Windows 上用网易 UU 远程控制 Mac 时，让闪电说这类通过剪贴板和 `Ctrl+V` 上屏的输入工具自动粘贴。脚本只在识别到前台是 UU 的 macOS 远控窗口时，把 `Ctrl+V` 转成 `Alt+V`（Mac 上的 `Command+V`）。

## 使用

1. 安装 [AutoHotkey v2](https://www.autohotkey.com/)，使用带有 `uuyc-cli.exe` 的 [网易 UU 远程](https://uuyc163.net/) Windows 客户端。
2. 确认在 Mac 远控窗口内手动按 `Alt+V` 能粘贴。UU 中的 Windows `Alt → Command` 映射需要已生效。
3. 下载或克隆本仓库，将两个脚本放在同一目录，双击 `UU-Mac-Paste.ahk`。右键 AutoHotkey 托盘图标，可用 **Suspend Hotkeys** 暂停改键，或用 **Exit** 退出。
4. 需要登录自启时，按 `Win+R` 打开 `shell:startup`，把 `UU-Mac-Paste.ahk` 的快捷方式放进去。

## 匹配与验证

- 脚本从正在运行的 UU 客户端目录找到 CLI，每 30 秒读取一次设备列表。只有列表中唯一同名且系统为 `macOS` 的设备才会匹配。设备未知、重名或查询失败时，`Ctrl+V` 保持原样。
- 默认等待 120 ms，让 UU 同步剪贴板。发送前会检查远控窗口仍在前台。多台 Mac 可以同时连接，只有前台窗口响应。
- Windows → Mac mini M5 Pro 已验证闪电说连续两次语音输入能分别粘贴新内容。M1 已验证设备识别。语音上屏依赖输入工具确实发送 `Ctrl+V` 以及 UU 已启用剪贴板同步。
