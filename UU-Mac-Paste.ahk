#Requires AutoHotkey v2.0
#SingleInstance Force
InstallKeybdHook()
SetTitleMatchMode(3)

uuWindow := "ahk_class Qt51519QWindowIcon ahk_exe GameViewer.exe"
macTitles := Map()
watchedUuPid := 0
queryRunning := false
refreshAfter := 0
pasteDelayMs := 120
A_IconTip := "UU macOS - Ctrl+V to Command+V"
TracePaste("started")
RefreshMacTitles()
SetTimer(RefreshMacTitles, 500)
SetTimer(RefreshRemoteHook, 250)

#HotIf ActiveMacWindow()
$^v:: {
    TracePaste("ctrl-v intercepted")
    target := ActiveMacWindow()
    if !target
        return

    Sleep(pasteDelayMs)
    ; Let the original Ctrl release reach the remote session before Alt+V.
    if !KeyWait("LCtrl", "T1") || !KeyWait("RCtrl", "T1") {
        TracePaste("ctrl release timed out")
        return
    }

    if !A_IsSuspended && ActiveMacWindow() = target {
        SendEvent("!v")
        TracePaste("alt-v sent")
    } else
        TracePaste("focus changed")
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
    SetVoiceMode(!ActiveMacWindow())
    if target && target != lastTarget {
        InstallKeybdHook(true, true)
        TracePaste("mac focus hook refreshed")
    }
    lastTarget := target
}

RefreshMacTitles() {
    global macTitles, watchedUuPid, queryRunning, refreshAfter

    uuPid := ProcessExist("GameViewer.exe")
    if uuPid != watchedUuPid {
        watchedUuPid := uuPid
        macTitles := Map()
        refreshAfter := 0
    }

    if !uuPid || queryRunning || A_TickCount < refreshAfter
        return

    path := A_Temp "\uu-mac-titles-" ProcessExist() "-" A_TickCount ".txt"
    shell := A_WinDir "\System32\WindowsPowerShell\v1.0\powershell.exe"
    helper := A_ScriptDir "\Get-UUMacTitles.ps1"
    queryRunning := true
    try {
        Run(Format('"{1}" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "{2}" "{3}"', shell, helper, path), , "Hide", &pid)
    } catch OSError {
        FinishMacTitles(uuPid, Map(), false)
        return
    }

    ; Leave the hotkey thread free while the UU device list is generated.
    started := A_TickCount
    SetTimer(() => CheckMacTitles(uuPid, pid, path, started), -100)
}

CheckMacTitles(uuPid, pid, path, started) {
    if ProcessExist(pid) {
        if A_TickCount - started < 10000 {
            SetTimer(() => CheckMacTitles(uuPid, pid, path, started), -100)
            return
        }

        try ProcessClose(pid)
        try FileDelete(path)
        FinishMacTitles(uuPid, Map(), false)
        return
    }

    nextTitles := Map()
    querySucceeded := false
    try {
        if FileExist(path) {
            for title in StrSplit(FileRead(path, "UTF-8"), Chr(10), Chr(13)) {
                if title != ""
                    nextTitles[title] := true
            }
            querySucceeded := true
        }
    } catch OSError {
        nextTitles := Map()
    } finally {
        try FileDelete(path)
    }
    FinishMacTitles(uuPid, nextTitles, querySucceeded)
}

FinishMacTitles(uuPid, nextTitles, querySucceeded) {
    global macTitles, watchedUuPid, queryRunning, refreshAfter
    queryRunning := false
    if uuPid != watchedUuPid || uuPid != ProcessExist("GameViewer.exe")
        return

    macTitles := nextTitles
    TracePaste("discovery success=" querySucceeded " count=" macTitles.Count)
    ; UU can start before its device directory is ready. Retry promptly.
    refreshAfter := A_TickCount + (querySucceeded ? 30000 : 2000)
}

TracePaste(eventName) {
    path := EnvGet("LOCALAPPDATA") "\UU-Mac-Paste.log"
    try {
        if FileExist(path) && FileGetSize(path) > 65536
            FileDelete(path)
        FileAppend(FormatTime(, "yyyy-MM-dd HH:mm:ss") " " eventName Chr(10), path, "UTF-8")
    }
}
SetVoiceMode(direct) {
    static applied := -1
    if applied = direct
        return
    path := A_AppData "\Shandianshuo\config.json"
    stage := path ".uu-route-" ProcessExist()
    try {
        original := FileRead(path, "UTF-8")
        changed := RegExReplace(original, '("use_direct_input"\s*:\s*)(true|false)', '$1' (direct ? "true" : "false"), &count)
        if count != 1
            return
        if changed != original {
            file := FileOpen(stage, "w", "UTF-8-RAW")
            file.Write(changed)
            file.Close()
            if FileRead(path, "UTF-8") != original
                return
            FileMove(stage, path, 1)
        }
        applied := direct
        TracePaste(direct ? "local direct mode" : "mac paste mode")
    } catch OSError {
        return
    } finally {
        if FileExist(stage)
            try FileDelete(stage)
    }
}
