#Requires AutoHotkey v2.0
#Include Admin.ahk

#HotIf WinActive("ahk_exe ffxiv_dx11.exe")
#SuspendExempt
#z::Suspend
#SuspendExempt false
Space::Shift
CapsLock::0 
RShift::Space
Esc::`
#Esc::Esc
#Hotif