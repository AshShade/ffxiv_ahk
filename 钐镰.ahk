#Include, lib/Admin.ahk
#Include, lib/combat/LifecycleObserver.ahk
#Include, lib/combat/ComboChecker.ahk
#Include, lib/pix.ahk
#Include, lib/Logger.ahk

class Reaper {
    __New(){
        this.gcd_window := 2.49
        this.gcd_coord := [2290,45]
        this.gcd_idle := 0x417087
        this.gcd_busy := 0x324A56

        this.decision := {}

        this.lo := new LifecycleObserver(this)
        this.cc := new ComboChecker([[1850,40],[1900,40]])

        this.cond_soul := new PixCond(1860,50,[0xA7ECE7,0xB0E9E5,0xB0EEE9])
        this.fire_matcher := new PixRGBMatcher({"b_min" : 255})
        this.fire_y := 940
        this.fire_xs := 1220
        this.fire_xd := 30
       
        this.ogcd_set := {}
    }

    decide_ogcd(phase){
        compare := phase == 2 ? this.decision.ogcd1 : 0
    
        ; queue := this.da_queue
        ; index := 1
        ; Loop {
        ;     if (index > queue.Length()) {
        ;         Break
        ;     }  
        ;     name := queue[index]
        ;     if (name == compare) {
        ;         ++index
        ;         Continue
        ;     }
        ;     a := this.ogcd_set[name]
        ;     if (a[2].meet(this.ps)){
        ;         return name
        ;     } else {
        ;         queue.RemoveAt(index)
        ;     }
        ; }

        return -1
    }

    update_fires(){
        if (!this.fires){
            if (pixMatch(pixGet(this.fire_xs,this.fire_y, this.ps),this.fire_matcher)){
                Loop, 4 {
                    x := this.fire_xs + (5 - A_Index) * this.fire_xd
                    if (pixMatch(pixGet(x,this.fire_y,this.ps),this.fire_matcher)){
                        this.fires := 6 - A_Index
                        return
                    }
                }
                this.fires := 1
                return
            }
            this.fires := 0
        }
        ; log(this.fires) 
    }
 
    get_ogcd(aoe,phase){
        valid := false
        if (!this.decision["ogcd" phase]){
            this.decision["ogcd" phase] := this.decide_ogcd(phase)
            valid := true
        } 

        ogcd := this.decision["ogcd" phase]
        if (ogcd < 0){
            return
        }

        a := this.ogcd_set[ogcd]
        if (!valid && !a[2].meet(this.ps)){
            return
        }
        return a[1]
    }

    get_gcd(aoe,is_end){
        this.update_fires()
        if (this.fires){
            if (Mod(this.fires,2) == 1){
                return "q"
            }
            return "e"
        }

        t := this.cc.get()[1]
        if (t && this.cond_soul.meet(this.ps)){
            if (t == 1) {
                return "q"
            } 
            if (t == 2){
                return "e"
            }
        }
  

        if (aoe){
            return "v"
        }
        return "f"
    }

    make_decision(series){
        if (this.decision.series == series){
            return
        }
        
        this.ps := pixScreenBatch()
        this.cc.check(this.ps)
        this.update_fires()

        d := {}
        d.series := series
        d.t_stamp := A_TickCount

        this.decision := d
    }

    get(aoe){
        r := this.lo.get()

        state := r[1]
        series := r[2]

        this.make_decision(series)
        return (state == 1 || state == 4) ? this.get_gcd(aoe,state == 4) : this.get_ogcd(aoe, state - 1)
    }

    update(){
        this.lo.observe()
    }
    
    free(){
        if (this.ps){
            pixScreenFree(this.ps)
            this.ps := 0
        }
    }

    onCombatEnd(){
        this.decision := {}
        this.da_queue := []
    }
}


attack_key := 0 
job := new Reaper()
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






; CutScreen(){
;     pixScreenSave("screencuts/" A_Now ".png")
; }
; $F1::CutScreen()
