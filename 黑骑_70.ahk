#Include, lib/Admin.ahk
#Include, lib/combat/LifecycleObserver.ahk
#Include, lib/combat/ComboChecker.ahk

#Include, lib/pix.ahk

class DarkKnight {
    __New(){
        this.gcd_window := 2.38
        this.gcd_coord := [1815,1710]
        this.gcd_idle := 0xD98A60
        this.gcd_busy := [0x744A33, 0x8A4A33]

        this.decision := {}

        this.lo := new LifecycleObserver(this)
        this.cc := new ComboChecker([[1707,1846],[1786,1894]])

        matcher_rf0 := new PixRGBMatcher({"r_min" : 0xF0})
        matcher_rff := new PixRGBMatcher({"r_min" : 0xFF})

        this.cond_bloodspiller := new PixCond(1863,1857,[0x9630F2,0xA54BF4])


        this.key_bloodspiller := "F9" ; 血溅
        this.key_quietus := "5" ; 寂灭
        this.key_combo := ["F2","F3"]
        this.key_c1 := "F1"
        this.key_ac1 := "F11"

        ; buff 监控
        this.buff_first := [1500,90] 
        this.buff_next := 90
        this.buff_count := 10
        this.c_buff_delirium := 0xFA6575



        this.ogcd_set := {}

        ; 进攻能力技 offensive abilities
        this.ogcd_set["ls"] := ["F4" ,  new PixCond(2231,1594,0x6D70B1)]    ; 掠影示现 Living Shadow
        this.ogcd_set["cs"] := ["F6" ,  new PixCond(1480,1900,0x5A6E7D)]    ; 精雕怒斩 Carve and Spit
        this.ogcd_set["ad"] := ["F7" ,  new PixCond(1400,1860,0x493936)]    ; 吸血深渊 Abyssal Drain
        this.ogcd_set["se"] := ["F8" ,  new PixCond(1480,1860,0x290C09)]    ; 腐秽大地 Salted Earth
        this.ogcd_set["bw"] := ["F10",  new PixCond(2050,1600,0xCF3D65)]    ; 嗜血 Blood Weapon
  
        ; 暗影锋/暗影波动 泻蓝 Mana Consume
        cond_ayf1 := new PixCond(2510,1483,matcher_rf0)
        cond_ayf2 := new PixCond([[2421,1481,matcher_rf0],[1655,1729,matcher_rff]],true)
        key_ayf := "F5"
        key_aybd := "6"
        this.ogcd_set["mc_1"] := [key_ayf,cond_ayf1]
        this.ogcd_set["mc_2"] := [key_ayf,cond_ayf2]
        this.ogcd_set["mc_1_aoe"] := [key_aybd,cond_ayf1]
        this.ogcd_set["mc_2_aoe"] := [key_aybd,cond_ayf2]

        this.oa_queue := ["mc_1","ad","cs","mc_2","se"]


        ; 防御能力技 defensive abilities
        this.ogcd_set["da_e"] := ["e",new PixCond(2000,1700,0x1A4058)] ; 至黑之夜
        this.ogcd_set["da_q"] := ["q",new PixCond(2050,1700,0xCC61BB)] ; 雪仇
        this.ogcd_set["da_1"] := ["1",new PixCond(2150,1700,0x2E2E26)] ; 弃明投暗
        this.ogcd_set["da_2"] := ["2",new PixCond(2200,1700,0x5F3E2C)] ; 铁壁
        this.ogcd_set["da_3"] := ["3",new PixCond(2300,1700,0x1C1A29)] ; 暗影墙
        this.ogcd_set["da_4"] := ["4",new PixCond(2400,1700,0xCBA656)] ; 暗黑布道
        this.ogcd_set["da_z"] := ["z",new PixCond(2400,1600,0xEF4048)] ; 行尸走肉

        this.da_queue := []
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

        if (phase == 2 && this.ogcd_set.bw[2].meet(this.ps)){
            return -1
        }

        for key,name in this.oa_queue {
            a := this.ogcd_set[name]
            if (a[2].meet(this.ps)){
                return name
            }
        }
        return -1
    }
 

    get_ogcd(aoe,phase){
        if (!this.decision["ogcd" phase]){
            this.decision["ogcd" phase] := this.decide_ogcd(phase)
        }
        ogcd := this.decision["ogcd" phase]
        if (ogcd < 0){
            return
        }

        if (aoe and this.ogcd_set[ogcd "_aoe"]){
            a := this.ogcd_set[ogcd "_aoe"]
        } else {
            a := this.ogcd_set[ogcd]
        }
        return a[1]
    }

    decide_gcd(ps){
        ; 在血乱里么？
        ; 是 => 泻暗影
        ; 否 =>
        ;     有长连击么？
        ;     是 => 打连击
        ;     否 =>
        ;         暗影值50
        ;         是 => 泻暗影
        ;         否 => 打连击
  
        state := this.cc.get()     
        combo := state[1]
        long := state[2] > 5000

        if (this.buff_state_delirium){
            return 2
        } else if (combo && long){
            return 1
        } else if (this.cond_bloodspiller.meet(ps)){
            return 2
        } else {
            return 1
        }
    }

    get_gcd(aoe,is_end){
        if (is_end && this.decision.bw  && this.ogcd_set.bw[2].meet(this.ps)){
            return this.ogcd_set.bw[1]
        }

        t := this.decision.gcd_type
        if (t == 2 && this.cond_bloodspiller.meet(this.ps)){
            if (aoe){
                return this.key_quietus
            } else {
                return this.key_bloodspiller
            }
        }

        state := this.cc.get()     
        combo := state[1]
        if (combo){
            return this.key_combo[combo]
        } 
        if (aoe){
            return this.key_ac1
        }
        return this.key_c1
    }

    check_states(ps){
        this.buff_state_delirium := false
        x := this.buff_first[1]
        y := this.buff_first[2]
        Loop, % this.buff_count {
            c := pixGet(x,y,ps)
            if (pixMatch(c,this.c_buff_delirium)){
                this.buff_state_delirium := true
                break
            }
            x += this.buff_next
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
        d.gcd_type := this.decide_gcd(ps)
        d.bw := this.decision.ogcd2 == -1
  
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
        this.ba_queue := []
    }
}


attack_key := 0 
job := new DarkKnight()
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
$z::job.insert("z")
#IfWinActive






; CutScreen(){
;     pixScreenSave("screencuts/" A_Now ".png")
; }
; $F1::CutScreen()
