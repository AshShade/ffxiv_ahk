#Include, lib/Admin.ahk
#Include, lib/Logger.ahk
#Include, lib/pix.ahk

9::
    WinGet, wid,ID,A
    key := "``"
    ControlSend,,{%key%}, ahk_id %wid%