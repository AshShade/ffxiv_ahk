#Include, lib/Admin.ahk
#Include, lib/combat/LifecycleObserver.ahk
#Include, lib/combat/ComboChecker.ahk

#Include, lib/pix.ahk

class Machinist {
    __New(){    
        this.gcd_window := 1.5
        this.gcd_coord := [1815,1710]
        this.gcd_idle := 0xFFF864
        this.gcd_busy := 0x888436

        this.decision := {}

        this.lo := new LifecycleObserver(this)
        this.cc := new ComboChecker([[1707,1846],[1786,1894]])

        this.key_combo := ["F2","F3"]
    }

    decide_gcd_type(ps){
        buff := 0
        if (open_buff){
            if (states.ch()){
                if (yh[2].get()){
                    buff := yh[1]
                } else {
                    buff := states.ch_k
                }
            }
        }
    }

    make_decision(series){
        if (this.decision.series == series){
            return
        }

        ps := pixScreenBatch()
        this.cc.check(ps)

        d := {}
        d.series := series
        d.t_stamp := A_TickCount
        d.gcd_type := this.decide_gcd_type(ps)

        this.decision := d
        this.ps := ps
    }

    get(aoe){
        r := this.lo.get()

        state := r[1]
        series := r[2]

        this.make_decision(series)

        return (state == 1 || state == 4) ? this.get_gcd(aoe,state == 4) : this.get_ogcd(aoe, state - 1)
    }
}

attack_key := 0 
job := new Machinist()
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
