#Include  %A_ScriptDir%\lib\admin.ahk

CoordMode "Mouse", "Screen"

class FFXIVWindow {
    __New(){
        p_name1 := "ffxiv_dx11.exe"
        wid := WinGetId("ahk_exe" p_name1)
        if (!wid){
            MsgBox "找不到FFXIV"
            ExitApp
        }
        this.wid := wid
    }
    click(x,y){
        MouseClick "left", x, y
    }
    send(key){
        wid := this.wid
        ControlSend key,, "ahk_id" wid
    }
}