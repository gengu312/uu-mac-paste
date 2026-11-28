# UU Mac Paste

<p>
  <a href="./README.md"><img src="https://img.shields.io/badge/Docs-English-2563EB?style=flat-square" alt="English" /></a>
  <a href="./README.zh-CN.md"><img src="https://img.shields.io/badge/%E6%96%87%E6%A1%A3-%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-64748B?style=flat-square" alt="简体中文" /></a>
</p>

When controlling a Mac from Windows using NetEase UU Remote, input utilities like Shandianshuo (闪电说)—which commit dictated text via the clipboard and `Ctrl+V`—can paste automatically with this helper. The script remaps `Ctrl+V` to `Alt+V` (`Command+V` on macOS) **only** when the active foreground window is recognized as a UU macOS remote-control window.

## Usage

1. Install [AutoHotkey v2](https://www.autohotkey.com/) and use the [NetEase UU Remote](https://uuyc163.net/) Windows client that ships with `uuyc-cli.exe`.
2. Confirm that pressing `Alt+V` manually inside the Mac remote window pastes properly. The Windows `Alt → Command` key mapping in UU must already be active.
3. Download or clone this repository, keep both scripts in the same directory, and double-click `UU-Mac-Paste.ahk`. Right-click the AutoHotkey tray icon to pause remapping via **Suspend Hotkeys** or quit via **Exit**.

## Launch at Sign-In

Press `Win+R` to open `shell:startup`, create a new shortcut, set its target to the command below, and replace both paths with your local installation paths. If you already have a shortcut launching the `.ahk` file directly, replace it with this command:

```powershell
powershell.exe -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Tools\uu-mac-paste\Start-UUMacPaste.ps1" -AutoHotkeyPath "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
```

After Windows sign-in, the launcher waits for the current user's UU client process to appear before starting AutoHotkey. AutoHotkey then verifies that the UU device list is ready.

## Shandianshuo (闪电说) Input Method Switching

The script dynamically switches Shandianshuo (闪电说) v0.8.2's input mode based on the active foreground window. On local Windows apps, it enables the experimental Direct Input mode to bypass the clipboard; when focusing a recognized UU macOS remote window, it switches back to Clipboard Paste mode. Verified in a continuous session committing text separately to local ChatGPT on Windows and a remote Mac mini. When the script exits, Shandianshuo retains whichever setting was active last.

## Device Matching & Verification

- The script locates `uuyc-cli.exe` from the running UU client directory and queries the device list immediately when UU starts or restarts. If the list is empty or the query fails, it retries after ~2 seconds; once successful, it refreshes every 30 seconds. A window matches **only** when there is a unique device with that exact name in the list whose operating system is `macOS`. When a device is unknown, shares a duplicate name, or the query fails, `Ctrl+V` passes through unchanged.
- Waits 120 ms by default so UU can synchronize the clipboard, and verifies that the remote window is still in the foreground right before sending `Alt+V`. Multiple Macs can be connected simultaneously; only the active foreground window responds.
- Verified on Windows → Mac mini M5 Pro that two consecutive Shandianshuo voice inputs paste distinct new clipboard contents properly. Device recognition has also been verified on M1. Voice paste relies on the input tool sending `Ctrl+V` and clipboard sync being enabled in UU.
