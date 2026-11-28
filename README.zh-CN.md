# UU Mac Paste

<p>
  <a href="./README.md"><img src="https://img.shields.io/badge/Docs-English-64748B?style=flat-square" alt="English" /></a>
  <a href="./README.zh-CN.md"><img src="https://img.shields.io/badge/%E6%96%87%E6%A1%A3-%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-2563EB?style=flat-square" alt="简体中文" /></a>
</p>

在 Windows 上用网易 UU 远程控制 Mac 时，让闪电说这类通过剪贴板和 `Ctrl+V` 上屏的输入工具自动粘贴。脚本只在识别到前台是 UU 的 macOS 远控窗口时，把 `Ctrl+V` 转成 `Alt+V`（Mac 上的 `Command+V`）。

## 使用

1. 安装 [AutoHotkey v2](https://www.autohotkey.com/)，使用带有 `uuyc-cli.exe` 的 [网易 UU 远程](https://uuyc163.net/) Windows 客户端。
2. 确认在 Mac 远控窗口内手动按 `Alt+V` 能粘贴。UU 中的 Windows `Alt → Command` 映射需要已生效。
3. 下载或克隆本仓库，将两个脚本放在同一目录，双击 `UU-Mac-Paste.ahk`。右键 AutoHotkey 托盘图标，可用 **Suspend Hotkeys** 暂停改键，或用 **Exit** 退出。
## 登录自启

按 `Win+R` 打开 `shell:startup`，新建快捷方式，把目标设为以下命令，并替换其中两个路径。已有直接启动 AHK 的快捷方式可改用这一条。

```powershell
powershell.exe -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Tools\uu-mac-paste\Start-UUMacPaste.ps1" -AutoHotkeyPath "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
```

登录后，启动器会等待当前用户的 UU 客户端进程出现，再启动 AutoHotkey。AutoHotkey 随后确认设备列表就绪。

## 闪电说输入方式

脚本按前台窗口切换闪电说 v0.8.2 的输入方式。在 Windows 本地使用实验室的直接输入，绕开剪贴板；进入已识别的 UU macOS 远控窗口时切回粘贴。已在一次持续连接中验证本机 ChatGPT 和远端 Mac mini 分别上屏。脚本退出时闪电说会保留最后一次设置。

## 匹配与验证

- 脚本从正在运行的 UU 客户端目录找到 CLI，UU 启动或重启后立即查询设备列表。列表为空或查询失败时约 2 秒后重试，成功后每 30 秒刷新。只有列表中唯一同名且系统为 `macOS` 的设备才会匹配。设备未知、重名或查询失败时，`Ctrl+V` 保持原样。
- 默认等待 120 ms，让 UU 同步剪贴板。发送前会检查远控窗口仍在前台。多台 Mac 可以同时连接，只有前台窗口响应。
- Windows → Mac mini M5 Pro 已验证闪电说连续两次语音输入能分别粘贴新内容。M1 已验证设备识别。语音上屏依赖输入工具确实发送 `Ctrl+V` 以及 UU 已启用剪贴板同步。
