#Include, lib/Admin.ahk
#Include, lib/Condition.ahk

class States {
    __New(){
        this.zt_c1 := new PixelGetter(1933,1656)
        this.zt_c2 := new PixelRGBGetter(1952,1655)
        this.kqm_c1 := new PixelGetter(2023,1656)
        this.kqm_c2 := new PixelRGBGetter(2042,1655)

        this.zt_k := "q"
        this.kqm_k := "e"
        this.ch_c := new CondPixelEq(2250,1700,"81FEDD")
        this.ch_k := "f6"
    }
    update(){
        this.zt := this.update_zt()
        this.kqm := this.update_kqm()
    }

    update_zt()
    {
        p := this.zt_c1.get()
        if (p == "EDDDC9" || p == "656156"){
            return 0
        }
        l := this.zt_c2.get()
        R := l[2]
        G := l[3]
        B := l[4]
        if (R == G && G == B && R >= 160)
        {
            return 2
        }
        if (p == "EDEDED" || p == "D4D4D4")
        {
            return 2
        }
        if (p == "EBEBEB"){
            return 0
        }
        return 1
    }
    update_kqm()
    {
        p := this.kqm_c1.get()
        if (p == "441D05" || p == "1E1004"){
            return 0
        }
        l := this.kqm_c2.get()
        R := l[2]
        G := l[3]
        B := l[4]
        if (R == G && G == B && R >= 160)
        {
            return 2
        }
        if (p == "EDEDED" || p == "D4D4D4")
        {
            return 2
        }
        if (p == "EBEBEB"){
            return 0
        }
        return 1
    }

    ch(){
        return this.kqm == 2 && this.zt == 2 && this.ch_c.get()
    }
    
}
states := new States()

; combo
c2 :=  new CondPixelActive(1413,1802)
c3 := new CondPixelActive(1512,1802)

; 热冲击
rcj := ["f4", new CondPixelEq(2156,1595,"FFFFF")]

; 野火
yh := ["f5", new CondPixelEq(2252,1613,"DCDCDC")]


; 机器人
jqr := ["f7", new CondPixelEq(2162,1709,"514E4E")]

; 整备
zb := ["f8",new CondPixelEq(1985,1694,"686DC8")]

; 枪管加热
qgjr := ["f9", new CondAnd([new CondPixelEq(2066,1707,"29A2E9"),new CondPixelEq(2250,1700,"4C8878")])]

; 虹吸弹3
hxd3 := ["f11", new CondPixelEq(2347,1743,"DFCDBE")]

; 弹射3
ts3 := ["f12", new CondPixelEq(2438,1744,"F4EEE9")]

; 虹吸弹
hxd := ["f11", new CondPixel(2358,1744,"FFFBF6|FFFFFF")]

; 弹射
ts := ["f12", new CondPixel(2446,1743,"F7EEE6|FFFFFF")]





gcd_cond := new CondNot(new CondPixelEq(1770,1700,"613505"))
in_gcd := True

ogcd_queue := [hxd3,ts3,qgjr,hxd,ts,jqr]
combo := 1
ogcd := 0
attack_key := 0 
last_reset := A_TickCount
open_buff  := False
last_buff := 0

main(){
    Loop {
        tick := A_TickCount
        
        update_state()
        decide_combo()
        attack()
        
        tick := 100 - (A_TickCount - tick)
        if (tick > 0){
            Sleep, % tick
        }
    }
}



update_state(){
    global gcd_cond,in_gcd,last_reset,open_buff,last_buff,states

    if ((A_TickCount - last_reset) > 15000)
    {
        reset_combo()
    }
    states.update()
    
    if (gcd_cond.get()){
        if (!in_gcd){
            open_buff = True
        }
        in_gcd := True       
    } else {
        if (in_gcd){
            in_gcd := False
            last_buff := 0
            reset_combo()
            decide_ogcd()
        }
    }
}

decide_ogcd(){
    global ogcd_queue,ogcd

    for i,v in ogcd_queue
    {   
        if (v[2].get()){
            ogcd := v
            Return
        }
    }
    ogcd := 0 
}


decide_combo(){
    global combo,c2,c3

    if (c2.get()){
        combo := 2
    } else if (c3.get()){
        combo := 3
    }
}



reset_combo()
{
    global last_reset,combo,last_buff
    combo := 1
    last_reset := A_TickCount
    last_buff := 0
}

gcd()
{
    global combo,states,open_buff,zb,yh,rcj,last_buff


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

    if (buff){
        HK := buff
        last_buff := buff
    } else {
        open_buff = False
    }

    use_zb := False
    if (HK){

    } else if (rcj[2].get() || last_buff == states.ch_k){
        HK := rcj[1]
    } else if (states.zt == 0) {
        HK := states.zt_k
        use_zb = True
    } else if (states.kqm == 0){
        HK := states.kqm_k
        use_zb = True
    } else if (!HK) {
        HK = F%combo%
    }
    if (use_zb && zb[2].get()){
        HK := zb[1]
    }
    SendInput, {%HK%}
}



ogcd()
{
    global ogcd
    if (ogcd && ogcd[2].get()){
        HK := ogcd[1]
        SendInput, {%HK%}
    }
}

attack(){
    global in_gcd,attack_key
    if (attack_key){
        keyDown := GetKeyState(attack_key,"P")
        if not keyDown 
        {
            attack_key := 0
            Return
        }
    } else {
        Return
    }

    if (in_gcd){
        gcd()
    } else {
        ogcd()
    }
}

startAttack(){
    global attack_key
    attack_key := "f"
    Return
}
main()


#z::Suspend
Space::Shift
$f::startAttack()
