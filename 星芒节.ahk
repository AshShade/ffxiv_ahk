#Include, lib/Admin.ahk
#Include, lib/Condition.ahk

start := 0
FileName := "C:\Users\dingk\Desktop\FF14\ffxiv_ahk\log\music.log.txt"

main(){
    global start, FileName
    cond := new CondPixelEq(95,98,"7A933A")
    Loop {
        if (cond.get()){
            start := A_TickCount
            FileDelete, %FileName%
            return
        }
    }
}

input(t){
    global start, FileName
    tick := A_TickCount - start
    FileAppend, %t% %tick%`n, %FileName%
    switch t {
        case 1:
            SendInput, i
        case 2:
            SendInput, u
        case 3:
            SendInput, {u Down}
            Sleep, 700
            SendInput {u Up}
    }
}

restart(){
    MsgBox, Restart!
    main()
}

main()
#z::Suspend
$i::input(1)
$u::input(2)
$o::input(3)

$r::restart()
