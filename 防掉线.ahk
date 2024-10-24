#Include, lib/Admin.ahk

main(){
    global running
    p_name1 := "ffxiv_dx11.exe"
    WinGet, wid1,ID,ahk_exe %p_name1%
    if (!wid1){
        MsgBox, 找不到FFXIV
        ExitApp
    }

    key := "0"
    Loop {        
        ControlSend,,{ %key% }, ahk_id %wid1%
        Sleep, 300000
    }
}


main()