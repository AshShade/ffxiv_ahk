#Include, lib/Admin.ahk
#Include, lib/combat/LifecycleObserver.ahk
#Include, lib/combat/ComboChecker.ahk

#Include, lib/pix.ahk

class Warrior {
    __New(){
        this.gcd_window := 2.37
        this.gcd_coord := [1815,1710]
        this.gcd_idle := 0xFBF4F4
        this.gcd_busy := [0x8C8888, 0xA18888]

        this.decision := {}

        this.lo := new LifecycleObserver(this)
        this.cc := new ComboChecker([[1707,1846],[1786,1894],[1783,1798]])

        ; buff 监控
        this.buff_first := [1500,90] 
        this.buff_next := 90
        this.buff_count := 10
        this.buff_timer_offset := [-13,60]
        this.c_buff_stormseye := 0xCC4A19
        this.c_buff_inner_release := 0xED351B
        ; this.c_buff_nascent_chaos := 0x593311
        this.c_buff_timer :=[0x89C9A3,0xB5EED0,0x71B58B,0xB3EDCE,0xADE7C7] ; [1min,5x,4x,3x,2X]

        ; 原初的解放
        this.cond_inner_release := new PixCond(2000,1600,0xE68D75)

        ; 兽魂
        matcher_r200 := new PixRGBMatcher({"r_min" : 200})
        this.cond_beast_gauge_30 := new PixCond(1440,1670,matcher_r200)
        this.cond_beast_gauge_40 := new PixCond(1472,1670,matcher_r200)
        this.cond_beast_gauge_50 := new PixCond(1504,1670,matcher_r200)
        this.cond_beast_gauge_60 := new PixCond(1536,1670,matcher_r200)
        this.cond_beast_gauge_70 := new PixCond(1567,1670,matcher_r200)

        this.cond_decimate := new PixCond(1865,1860,[0x76A7B5,0x679DAD,0xF89273,0xF78664])

        ; 战嚎
        this.p_infuriate := [2085,1645]
        this.c_infuriate_stack2 := 0xFFFFFF
        this.c_infuriate_stack1 := 0xE8D7C9

        ; 动乱
        this.cond_upheaval :=  new PixCond(2170,1600,0x824D4A)
        
        this.key_c1 := "F1"
        this.key_ac1 := "F11"
        this.key_combo := ["F2","F3","F12"]
        this.key_stormseye := "F4" ; 红斩
        this.key_fell_cleave := "F5"         
        this.key_decimate := "F6" ; 地毁人亡

        this.ogcd_set := {}

        this.ogcd_set["zh1"]  := ["F7", new PixCond(this.p_infuriate[1],this.p_infuriate[2],this.c_infuriate_stack1)]
        this.ogcd_set["zh2"]  := ["F7", new PixCond(this.p_infuriate[1],this.p_infuriate[2],this.c_infuriate_stack2)]
        this.ogcd_set["dl"]   := ["F8", this.cond_upheaval]

        ; 防御能力技 defensive abilities
        this.ogcd_set["da_e"] := ["e",new PixCond(2000,1700,0x9DCF88)] ; 原初的直觉
        this.ogcd_set["da_q"] := ["q",new PixCond(2050,1700,0xCF67BF)] ; 雪仇
        this.ogcd_set["da_1"] := ["1",new PixCond(2150,1700,0x31783A)] ; 战栗
        this.ogcd_set["da_2"] := ["2",new PixCond(2200,1700,0x654432)] ; 铁壁
        this.ogcd_set["da_3"] := ["3",new PixCond(2300,1700,0x7A189D)] ; 复仇
        this.ogcd_set["da_4"] := ["4",new PixCond(2400,1700,0x889B82)] ; 摆脱
        this.ogcd_set["da_g"] := ["g",new PixCond(2300,1600,0x7C8838)] ; 泰然自若

        this.da_queue := []
    }

    decide_infuriate(inner_release){
        ; 有原初混沌或原初解放BUFF，不放战壕
        if (this.buff_state_inner_release || this.buff_state_nascent_chaos || this.decision.infuriate){
            return false   
        }

        c_infuriate := pixGet(this.p_infuriate,this.ps)

        ; 两层战壕，放了再说
        if (pixMatch(c_infuriate,this.c_infuriate_stack2)){
            return 2
        }

        if (inner_release){
            return false
        }

        ; 一层战壕
        if (pixMatch(c_infuriate,this.c_infuriate_stack1)){
            ; 兽魂20以下，放就完事了
            if (!this.cond_beast_gauge_30.meet(this.ps)){
                return 1
            }  

            ; 红斩时间充裕
            if (this.buff_state_stormseye == 2){
                ; 根据打完下个连击是否会溢出兽魂来决定是否放
                state := this.cc.get()     
                combo := state[1]
                if (combo == 2){
                    ; 兽魂 <= 30
                    return !this.cond_beast_gauge_40.meet(this.ps)
                } else if (combo == 1){
                    ; 兽魂 <= 40
                    return !this.cond_beast_gauge_50.meet(this.ps)
                } else {
                    ; 兽魂 <= 50
                    return !this.cond_beast_gauge_60.meet(this.ps)
                }
            }
        }
        return false
    }
    

    decide_ogcd(phase){
        compare := phase == 2 ? this.decision.ogcd1 : 0
    
        queue := this.da_queue
        index := 1
        Loop {
            if (index > queue.Length()) {
                Break
            }  
            name := queue[index]
            if (name == compare) {
                ++index
                Continue
            }
            a := this.ogcd_set[name]
            if (a[2].meet(this.ps)){
                return name
            } else {
                queue.RemoveAt(index)
            }
        }

        inner_release := this.cond_inner_release.meet(this.ps)
        infuriate := this.decide_infuriate(inner_release)
        if (infuriate){
            this.decision.infuriate := true
            return "zh" . infuriate
        }

        ; 动乱好了就放，除非解放也好了
        if (this.buff_state_stormseye > 0 && !inner_release && this.cond_upheaval.meet(this.ps)){
            return "dl"
        }

        return -1
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

    decide_gcd_type(ps){
        ; 在解放里么？
        ; 是 => 打FC
        ; 否 =>
        ;     有长连击么？
        ;     是 => 打连击
        ;     否 =>
        ;         断红斩了么？
        ;         是 => 打连击
        ;         否 =>
        ;             有原初混沌么？
        ;             是 => 打FC
        ;             否 =>
        ;                 兽魂要溢出了么？ (70兽魂)
        ;                 是 => 打FC
        ;                 否 =>
        ;                     打连击

        state := this.cc.get()     
        combo := state[1]
        long := state[2] > 4000
       
        if (this.buff_state_inner_release){
            return 2
        }

        if ((combo && long) || this.buff_state_stormseye == 0){
            return 1
        }

        if (this.buff_state_nascent_chaos || this.cond_beast_gauge_70.meet(ps)){
            return 2
        }
        return 1
    }

    get_gcd(aoe,is_end){
        t := this.decision.gcd_type
        if (t == 2 && this.cond_decimate.meet(this.ps)){
            if (aoe){
                return this.key_decimate
            } else {
                return this.key_fell_cleave
            }
        }

        state := this.cc.get()     
        combo := state[1]
        if (combo){
            if (combo == 2 && this.buff_state_stormseye < 2){
                return this.key_stormseye
            }
            return this.key_combo[combo]
        } 
        if (aoe){
            return this.key_ac1
        }
        return this.key_c1
    }

    check_buff_state(ps){
        x := this.buff_first[1]
        y := this.buff_first[2]
        p_buff_stormseye := false
        
        this.buff_state_inner_release := false
        this.buff_state_nascent_chaos := false

        Loop, % this.buff_count {
            c := pixGet(x,y,ps)
            if (pixMatch(c,this.c_buff_stormseye)){
                p_buff_stormseye := [x,y]
            } else if (pixMatch(c,this.c_buff_inner_release)){
                this.buff_state_inner_release := true
            } 
            
            x += this.buff_next
        }

        if (p_buff_stormseye){
            x := p_buff_stormseye[1] + this.buff_timer_offset[1]
            y := p_buff_stormseye[2] + this.buff_timer_offset[2]

            if (pixMatch(pixGet(x,y,ps),this.c_buff_timer)){
                this.buff_state_stormseye := 2
            } else {
                this.buff_state_stormseye := 1
            }
        } else {
            this.buff_state_stormseye := 0
        }   
    }

    make_decision(series){
        if (this.decision.series == series){
            return
        }

        ps := pixScreenBatch()
        this.cc.check(ps)

        this.check_buff_state(ps)

        d := {}
        d.series := series
        d.t_stamp := A_TickCount
        d.gcd_type := this.decide_gcd_type(ps)

        this.decision := d
        this.ps := ps
    }

    insert(btn){
        queue := this.da_queue
        name := "da_" btn
        a := this.ogcd_set[name]
        if (!a) {
            return
        }
        
        HK := a[1]
        SendInput, {%HK%}
        
        for key,val in queue {
            if (val == name) {
                return
            }
        }
        queue.Push(name)
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
job := new Warrior()
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

$e::job.insert("e")
$q::job.insert("q")
$1::job.insert("1")
$2::job.insert("2")
$3::job.insert("3")
$4::job.insert("4")
$g::job.insert("g")
#IfWinActive






; CutScreen(){
;     pixScreenSave("screencuts/" A_Now ".png")
; }
; $F1::CutScreen()
