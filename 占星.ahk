#Include, lib/Admin.ahk
#Include, lib/pix.ahk
#Include, lib/combat/LifecycleObserver.ahk
#Include, lib/combat/BuffObserver.ahk

#Include, lib/Logger.ahk

class TeamController {
    __New(){
        ; 木桩
        ; melee_jobs := []
        ; range_jobs := [1]

        ; 四人本
        ; melee_jobs := [3,2]
        ; range_jobs := [4,1]

        ; 八人本
        melee_jobs := [5,6,3,2]
        range_jobs := [8,7,4,1]
    
        this.queues := [this.arrayMerge(melee_jobs,range_jobs),this.arrayMerge(range_jobs,melee_jobs)]
        this.timers := [0,0,0,0,0,0,0,0]
    }
    arrayMerge(Byref a1,Byref a2){
        a := []
        loop % a1.length(){
            a.push(a1[A_Index])
        } 
        loop % a2.length(){
            a.push(a2[A_Index])
        } 
        return a 
    }

    get(t){
        queue := this.queues[t]
        for k , v in queue {
            if ((A_TickCount - this.timers[v]) / 1000 > 15 ){
                return [v , k == 1]
            }
        }
        return [queue[1], false]
    }

    play(i){
        this.timers[i] := A_TickCount
    }

    report(){
        MsgBox, % (A_TickCount - this.timers[1]) / 1000
    }
    reset(){
        this.timers := [0,0,0,0,0,0,0,0]
    }
}

class DrawCardController {
    __New(){
        this.pHand := [2060,1930]
        this.pSeal1 := [1521,1572]
        this.pSeal2 := [1585,1572]
        this.pSeal3 := [1649,1572]
        this.pDivination := [2300,1600]


        this.types := []
        
        ; 太阳神之衡
        this.types[1] := [0xF0A87D,0x78543E]

        ; 世界树之干
        this.types[2] := [0x80916E,0x404837]
        
        ; 放浪神之箭
        this.types[3] := [0xAAB3C4,0x555962]

        ; 河流神之瓶
        this.types[4] := [0xC1E5FF,0x60737F]

        ; 战争神之枪
        this.types[5] := [0x4F61AE,0x283157]

        ; 建筑神之塔
        this.types[6] := [0xE1CDBA,0x71675D]

  
        this.cSolar  := 0xFBEFE5
        this.cLunar := 0xFAF3CE
        this.cCelestial := 0xB4ECEA

        this.cDivinationActive := 0x483A3A
        this.cDivinationReady := 0x373030

        this.kDivination := "F3"
        this.kPlay := ["F9","F10","F11","F12","5","6","7","8"]
        this.kMinor := ["9","0","-","=","[","]","'","/"]

        this.condDraw := new PixCond(2060,1835,0xAE7E4F)
        this.condSDraw := new PixCond(1985,1885,0x726985)
        this.condRDraw := new PixCond(2174,1907,[0xFFFFFF,0xE8D7C9])
        this.kDraw := "F6"
        this.kSDraw := "F7"
        this.kRDraw := "F8"

        this.lastPlay := 0
        this.lastDraw := [0, 0]
        this.tc := new TeamController()
    }

    getSeal(pSeal){
        c := pixGet(pSeal)
        Switch c {
            case this.cSolar:
                return 1
            case this.cLunar:
                return 2
            case this.cCelestial:
                return 3
        }
        return 0
    }

    update(){
        this.updateHandCard()
    }

    updateSeals(){
        this.seals := [this.getSeal(this.pSeal1),this.getSeal(this.pSeal2),this.getSeal(this.pSeal3)]
    }

    updateHandCard(){
        colour := pixGet(this.pHand)
        cardcode := -1
        for k,v in this.types {
            if (pixMatch(colour,v)){
                cardcode := k - 1
                break
            }
        }
        if (cardcode == -1 && this.handcard){
            this.tc.play(this.lastPlay)
        }
        this.handcard := cardcode == -1 ? 0 : [(cardcode >> 1) + 1,(cardcode & 1) + 1]
    }
    
 
    decideTarget(){
        t := this.tc.get(this.handcard[2])
        this.target := t[1]
        this.isBestTarget := t[2]
    }

    play(is_minor := false){
        this.lastPlay := this.target
        return is_minor ? this.kMinor[this.target] : this.kPlay[this.target]
    }

    getPlayAction(cDivination,kDraw){
        ; 占卜转好了么？
        ; 是 =>发卡
        ; 否 =>
        ;     占卜标识满了么？
        ;     是 => 
        ;         抽卡/袖内抽卡转好了么？
        ;         是 => 小奥秘卡
        ;         否 => 什么也不做
        ;     否 =>
        ;         抽卡/袖内抽卡转好了么？
        ;         是 =>
        ;             是合适的卡么？（标识不重复）
        ;             是 => 发卡
        ;             否 => 小奥秘卡
        ;         否 =>
        ;             是合适的卡么？（标识不重复）
        ;             是 => 
        ;                 发卡的最优目标身上有BUFF么？
        ;                 是 => 什么也不做
        ;                 否 => 发卡
        ;             否 => 
        ;                 重抽转好了么？
        ;                 是 =>重抽
        ;                 否 =>什么也不做
    
        this.decideTarget()
        if (pixMatch(cDivination,this.cDivinationReady)){
            return this.play()
        }
        
        if (this.seals[1] != 0){
            if (kDraw) {
                return this.play(true)
            } 
            return 0
        }

        isOwnedSeal := this.seals[2] == this.handcard[1] or this.seals[3] == this.handcard[1]

        if (kDraw) {
            if (isOwnedSeal){
                return this.play(true)
            } else {
                return this.play()
            }
        }

        if (isOwnedSeal){
            if (this.condRDraw.meet()) {
                return this.kRDraw
            }
            return 0
        }

        if (this.isBestTarget){
            return this.play()
        }
        return 0
    }

    getReadyDrawSkill(){
        if (this.condDraw.meet()){
            return this.kDraw
        } else if (this.condSDraw.meet()){
            return this.kSDraw
        }
        return 0
    }

    getDrawAction(kDraw){
        if (this.lastDraw[1] != kDraw and (A_TickCount - this.lastDraw[2] < 1000 )){
            return 0
        }
        this.lastDraw := [kDraw,A_TickCount]
        return kDraw
    }

    getAction(){
        cDivination := pixGet(this.pDivination)

        if (pixMatch(cDivination,this.cDivinationActive)){
            return this.kDivination
        }
        this.updateSeals()
        kDraw := this.getReadyDrawSkill()
        if (this.handcard == 0){
            if (kDraw){
                return this.getDrawAction(kDraw)
            }
        } else {
            return this.getPlayAction(cDivination,kDraw)
        }
        return 0
    }
}

class Astrologian{
    __New(){    
        this.gcd_window := 2.41
        this.gcd_coord := [1815,1710]
        this.gcd_idle := 0xFFF864
        this.gcd_busy := [0x342939,0x685172]
        this.lo := new LifecycleObserver(this)
        this.bo := new BuffObserver({"lightspeed" : new PixCond(1500,90,0x7C784D), "swiftcast" : new PixCond(1500,90,0x8E4495)})
        this.mo := new MoveObserver()
        this.dcc := new DrawCardController()
        this.cond_ogcd := new PixCond(1490,1930,0x69441C)
        this.cond_dot := new PixCond(1340,1360,0xC0F4FF)
        this.cond_dot_renew := new PixCond(1340,1395,[0x4B9666,0x569C73])
        this.cond_lucid_dreaming := new PixCond([[2455,1482,0x57473D],[1490,1840,0x4A2724]])
        this.cond_celestial_intersection := new PixCond(1400,1900,0xAC7C7C)
    }

    is_moving(){
        for k,v in ["w","a","s","d"]{
            if (GetKeyState(v,"P")){
                return true
            }
        }

        for k,v in ["LButton","RButton"]{
            if (!GetKeyState(v,"P")){
                return false
            }
        }
        return true
    }

    get_gcd(aoe)
    {
        if (!this.cond_dot.meet(this.ps) || this.cond_dot_renew.meet(this.ps)){
            return "F1"
        }
        ps := pixScreenBatch()
        this.bo.update(ps)
        this.ps := ps
        if (!(this.bo.get("lightspeed") || this.bo.get("swiftcast")) && this.is_moving()){
            return this.get_ogcd(aoe)
        }
        return aoe ? "v" : "f"
    }

    get_ogcd()
    {
        if (!this.cond_ogcd.meet(this.ps)) {
            return
        }

        HK := this.dcc.getAction()
        if (HK){
            return HK
        }

        if (this.cond_lucid_dreaming.meet(this.ps)){
            return "F5"
        }

        if (this.cond_celestial_intersection.meet(this.ps)){
            return "F2"
        }

    }

    get(aoe){
        r := this.lo.get()
        state := r[1]
        return state == 1 || state == 4 ? this.get_gcd(aoe) : this.get_ogcd(aoe)
    }

    

    update(){       
        this.dcc.update()
        this.lo.observe()
    }
    
    free(){
        if (this.ps){
            pixScreenFree(this.ps)
            this.ps := 0
        }
    }
}


job := new Astrologian()


#Include, lib/combat/main.ahk