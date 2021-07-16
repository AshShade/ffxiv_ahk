#Include, lib/Admin.ahk
#Include, lib/combat/LifecycleObserver.ahk
#Include, lib/combat/ComboChecker.ahk

#Include, lib/pix.ahk



class Gunbreaker {
    __New(){
        this.gcd_window := 2.42
        this.gcd_coord := [1815,1710]
        this.gcd_idle := 0x376847
        this.gcd_busy := [0x1D3726, 0x323726]

        this.decision := {}

        this.lo := new LifecycleObserver(this)
        this.cc := new ComboChecker([[1500,1798],[1590,1846],[1707,1846],[1786,1894],[1783,1798]])

        ; buff 监控
        this.buff_first := [1500,90] 
        this.buff_next := 90
        this.buff_count := 10
        this.c_buff_no_mercy := 0x6A4142

        ; 晶壤
        matcher_cartridge := new PixRGBMatcher({"r_min" : 100, "g_min" : 150, "b_min" : 255})
        this.cond_cartridge_1 := new PixCond(1630,1670,matcher_cartridge)
        this.cond_cartridge_2 := new PixCond(1690,1670,matcher_cartridge)

        ; 音速破
        this.cond_sonic_break := new PixCond(1867,1861,[0x47567C,0x474D73,0x374770,0x37426B])

        ; 烈牙
        this.cond_gnashing_fang := new PixCond(1424,1862,[0x565292,0x564B8A,0x4A478B,0x4A4286])

        ; 无情20秒以上
        this.cond_no_mercy_cd := new PixCond(1938,1637,0x102736)
        
        ; 弓形冲波
        this.cond_bow_shock := new PixCond(2340,1820,0xF6F47D)

        ; 爆破领域
        this.cond_blasting_zone := new PixCond(2340,1920,0x7D89DC)


        this.key_c1 := "F1"
        this.key_ac1 := "F11"
        this.key_combo := ["F6","F7","F2","F3","F12"]
        this.key_burst_strike := "F8"
        this.key_sonic_break := "F4"
        this.key_gnashing_fan := "F5"



        this.ogcd_set := {}

        this.ogcd_set["bz"] := ["F9", this.cond_blasting_zone] ; 爆破领域
        this.ogcd_set["bs"] := ["F10", this.cond_bow_shock] ; 弓形冲波
        this.ogcd_set["xj"] := ["5", true] ; 续剑

        ; 防御能力技 defensive abilities
        this.ogcd_set["da_e"] := ["e",new PixCond(2000,1700,0x384993)] ; 石之心
        this.ogcd_set["da_q"] := ["q",new PixCond(2050,1700,0xCC61BB)] ; 雪仇
        this.ogcd_set["da_1"] := ["1",new PixCond(2150,1700,0x698DB4)] ; 伪装
        this.ogcd_set["da_2"] := ["2",new PixCond(2200,1700,0x5F3E2C)] ; 铁壁
        this.ogcd_set["da_3"] := ["3",new PixCond(2300,1700,0x27211A)] ; 星云
        this.ogcd_set["da_4"] := ["4",new PixCond(2400,1700,0x745013)] ; 光之心
        this.ogcd_set["da_g"] := ["g",new PixCond(2300,1600,0x466271)] ; 极光

        this.da_queue := []
    }
    
    decide_ogcd(ps){
        if (this.buff_state_no_mercy && this.cond_bow_shock.meet(ps)){
            return "bs"
        }
        if ((this.buff_state_no_mercy || this.state_no_mercy_cd) && this.cond_blasting_zone.meet(ps)){
            return "bz"
        }
        return false
    }
 
    get_ogcd_phase(phase){
        compare := phase == 2 ? this.decision.ogcd1 : 0


        if (phase == 2 && this.state_continuation){
            return "xj"
        }


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

        name := this.decision.ogcd
        if (name){
            a := this.ogcd_set[name]
            if (a[2].meet(this.ps)){
                this.decision.ogcd := false
                return name
            }
        }
        return -1
    }


    get_ogcd(aoe,phase){
        if (!this.decision["ogcd" phase]){
            this.decision["ogcd" phase] := this.get_ogcd_phase(phase)
        }
        ogcd := this.decision["ogcd" phase]
        if (ogcd < 0){
            return
        }

        a := this.ogcd_set[ogcd]
        return a[1]
    }


    get_gcd(aoe,is_end){
        ; 在子弹连？
        ; 是 => 打子弹连
        ; 否 =>
        ;     有长连击么？
        ;     是 => 打连击
        ;     否 =>
        ;         在无情内？
        ;         是 => 
        ;             烈牙CD?
        ;             是 =>
        ;                 打烈牙
        ;             否 =>
        ;                 音速破CD?
        ;                 是 =>
        ;                     打音速破
        ;                 否 =>
        ;                     有晶壤?
        ;                     是 =>
        ;                         打爆发击
        ;                     否 =>
        ;                         打连击
        ;         否 =>
        ;             无情还早且烈牙CD？
        ;             是 =>
        ;                 打烈牙
        ;             否 =>
        ;                 晶壤溢出?
        ;                 是 =>
        ;                     打爆发击
        ;                 否 =>
        ;                     打连击

        state := this.cc.get()     
        combo := state[1]
        long := state[2] > 7000

        this.state_continuation := false

        if (this.buff_state_no_mercy){
            if (this.state_gnashing_fang){
                this.state_continuation := true
                return this.key_gnashing_fan
            }
            if (this.state_sonic_break){
                return this.key_sonic_break
            }
        }
        if (combo > 0){
            if (combo < 3){
                this.state_continuation := true
                return this.key_combo[combo]
            }
            if (long){
                return this.key_combo[combo]
            }
        }

        if (this.buff_state_no_mercy){
            if (this.state_cartridge > 0){
                return this.key_burst_strike
            }
        } else {
            if (this.state_no_mercy_cd && this.state_gnashing_fang){
                this.state_continuation := true
                return this.key_gnashing_fan
            }
            if (combo > 3  && this.state_cartridge == 2){
                return this.key_burst_strike
            }
        }

        if (combo > 0){
            return this.key_combo[combo]
        }

        if (aoe){
            return this.key_ac1
        }
        return this.key_c1
    }

    check_states(ps){
        x := this.buff_first[1]
        y := this.buff_first[2]
        s_buff_no_mercy := false
        Loop, % this.buff_count {
            c := pixGet(x,y,ps)
            if (pixMatch(c,this.c_buff_no_mercy)){
                s_buff_no_mercy := true
                break
            }
            x += this.buff_next
        }
        this.buff_state_no_mercy := s_buff_no_mercy
            
        this.state_no_mercy_cd := this.cond_no_mercy_cd.meet(ps)
        this.state_sonic_break := this.cond_sonic_break.meet(ps)
        this.state_gnashing_fang := this.cond_gnashing_fang.meet(ps)
    
        if (this.cond_cartridge_2.meet(ps)){
            this.state_cartridge := 2
        } else if (this.cond_cartridge_1.meet(ps)){
            this.state_cartridge := 1
        } else {
            this.state_cartridge := 0
        }
    }

    make_decision(series){
        if (this.decision.series == series){
            return
        }
        ps := pixScreenBatch()
        this.cc.check(ps)
        this.check_states(ps)

        d := {}
        d.series := series
        d.ogcd := this.decide_ogcd(ps)

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

    update(){
        this.ps := 0
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
job := new Gunbreaker()
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
