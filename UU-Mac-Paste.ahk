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

RefreshMacTitles() {
    global macTitles
    nextTitles := Map()
    if ProcessExist("GameViewer.exe") {
        path := A_Temp "\uu-mac-titles-" ProcessExist() ".txt"
        shell := A_WinDir "\System32\WindowsPowerShell\v1.0\powershell.exe"
        helper := A_ScriptDir "\Get-UUMacTitles.ps1"
        try {
            result := RunWait(Format('"{1}" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "{2}" "{3}"', shell, helper, path), , "Hide")
            if result = 0 {
                for title in StrSplit(FileRead(path, "UTF-8"), Chr(10), Chr(13)) {
                    if title != ""
                        nextTitles[title] := true
                }
            }
        } catch OSError {
            ; Keep Ctrl+V native if the device list is unavailable.
        } finally {
            if FileExist(path)
                FileDelete(path)
        }
    }
    macTitles := nextTitles
}
