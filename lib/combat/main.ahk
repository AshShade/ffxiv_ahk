attack_key := 0 
main(){
    global attack_key,job
    Loop {
        tick := A_TickCount
        
        job.update()

        if (attack_key && GetKeyState(attack_key,"P")){
            HK := job.get(attack_key == "v")
            if (HK){
                SendInput, {%HK%}
            }
        } else {
            attack_key := 0
        }

        job.free()

        tick := 100 - (A_TickCount - tick)
        if (tick > 0){
            Sleep, % tick
        }
    }
}

startAttack(key){
    global attack_key
    attack_key := key
    Return
}

main()


#IfWinActive, ahk_exe ffxiv_dx11.exe
#z::Suspend
Space::Shift
$f::startAttack("f")
$v::startAttack("v")
#IfWinActive
