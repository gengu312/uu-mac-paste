#Requires AutoHotkey v2.0
#SingleInstance Force
InstallKeybdHook()
SetTitleMatchMode(3)

uuWindow := "ahk_class Qt51519QWindowIcon ahk_exe GameViewer.exe"
macTitles := Map()
pasteDelayMs := 120
A_IconTip := "UU macOS - Ctrl+V to Command+V"
RefreshMacTitles()
SetTimer(RefreshMacTitles, 30000)
SetTimer(RefreshRemoteHook, 250)

#HotIf ActiveMacWindow()
$^v:: {
    target := ActiveMacWindow()
    if !target
        return

    Sleep(pasteDelayMs)
    ; Let the original Ctrl release reach the remote session before Alt+V.
    if !KeyWait("LCtrl", "T1") || !KeyWait("RCtrl", "T1")
        return

    if !A_IsSuspended && ActiveMacWindow() = target
        SendEvent("!v")
}
#HotIf

ActiveMacWindow() {
    hwnd := WinActive(uuWindow)
    if !hwnd
        return 0

    try title := WinGetTitle(hwnd)
    catch TargetError
        return 0
    return title != "网易UU远程" && macTitles.Has(title) ? hwnd : 0
}

RefreshRemoteHook() {
    static lastTarget := 0
    target := A_IsSuspended ? 0 : ActiveMacWindow()
    if target && target != lastTarget
        InstallKeybdHook(true, true)
    lastTarget := target
}

RefreshMacTitles() {
    global macTitles
    if !ProcessExist("GameViewer.exe") {
        macTitles := Map()
        return
    }

    path := A_Temp "\uu-mac-titles-" ProcessExist() "-" A_TickCount ".txt"
    shell := A_WinDir "\System32\WindowsPowerShell\v1.0\powershell.exe"
    helper := A_ScriptDir "\Get-UUMacTitles.ps1"
    try {
        Run(Format('"{1}" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "{2}" "{3}"', shell, helper, path), , "Hide", &pid)
    } catch OSError {
        macTitles := Map()
        return
    }

    ; Leave the hotkey thread free while the UU device list is generated.
    started := A_TickCount
    SetTimer(() => CheckMacTitles(pid, path, started), -100)
}

CheckMacTitles(pid, path, started) {
    global macTitles
    if ProcessExist(pid) {
        if A_TickCount - started < 10000 {
            SetTimer(() => CheckMacTitles(pid, path, started), -100)
            return
        }

        try ProcessClose(pid)
        try FileDelete(path)
        macTitles := Map()
        return
    }

    nextTitles := Map()
    try {
        if FileExist(path) {
            for title in StrSplit(FileRead(path, "UTF-8"), Chr(10), Chr(13)) {
                if title != ""
                    nextTitles[title] := true
            }
        }
    } catch OSError {
        nextTitles := Map()
    } finally {
        try FileDelete(path)
    }
    macTitles := nextTitles
}
