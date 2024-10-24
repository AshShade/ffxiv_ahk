#Include,  %A_ScriptDir%\lib\admin.ahk

refresh_advertise(ffxiv){
    ffxiv.click(1200,1062)
    Sleep, 1500
    ffxiv.click(1408,1128)
    Sleep, 1500
    ffxiv.click(1980,1388)
}

main(){
    Loop {        
        Send, 
        Sleep, 300000
    }
}


main()