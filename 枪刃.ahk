#Include, lib/Admin.ahk
#Include, lib/Condition.ahk

; combo
c2 :=  new CondPixelActive(1413,1802)
c3 := new CondPixelActive(1512,1802)

; 无情CD
wqcd := new CondPixelEq(1987,1626,"524B74")
wq := new CondPixelEq(2000,1600,"2A4798")

; 音速破
ysp := ["F4", new CondAnd([wqcd,new CondPixel(2156,1600,"36456B|414F73")])]

; 烈牙
ly := ["F5", new CondPixel(1586,1820,"4C4689|575291")]

; 猛兽爪
msz := ["F6", new CondPixel(1685,1820,"D39C6B|D6A375")]

; 凶禽爪
xqz := ["F7", new CondPixel(1783,1820,"5F3628|694236")]

; 续剑
xj := ["F8", new CondNot(new CondPixelEq(1879,1817,"5A6648"))]


; 爆破领域
; wxly := ["F9",new CondPixelEq(2248,1595,"6070B5")]
wxly := ["F9",new CondPixelEq(2250,1600,"9EBFEE")]


; 弓形冲波
gxcb := ["F10",new CondAnd([wqcd,new CondPixelEq(2337,1599,"F4CC9B")])]

; 极光
jg := ["F11", new CondPixelEq(1987,1821,"F5ECD6")]

; 爆发击
bfj := ["F12", new CondPixelEq(1648,1652,"F")]


gcd_cond := new CondNot(new CondPixelEq(1804,1716,"143B3E"))

in_gcd := True

gcd_queue := [xqz,msz,ysp,ly,bfj]
ogcd_queue := [xj,wxly,gxcb,jg]
combo := 1
ogcd := 0
attack_key := 0 
last_reset := A_TickCount
open_buff  := False

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
    global gcd_cond,in_gcd,last_reset,open_buff

    if ((A_TickCount - last_reset) > 15000)
    {
        reset_combo()
    }


    if (gcd_cond.get()){
        if (!in_gcd){
            open_buff = True
        }
        in_gcd := True       
    } else {
        if (in_gcd){
            in_gcd := False
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
    global last_reset,combo
    combo := 1
    last_reset := A_TickCount
}

gcd()
{
    global wq,combo,gcd_queue,consume_ay, open_buff

    HK := 0
    if (open_buff){
        if (wq[2].get()){
            HK := wq[1]
        } else {
            open_buff = False
        }
    }

    if (HK){

    } else {
        for i,v in gcd_queue
        {   
            if (v[2].get()){
                HK := v[1]
                break
            }
        }
    }
    if (!HK){
        HK = F%combo%
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




; in_gcd := True

; combo := [xlz,cbd] 
; gcd_queue := [xqz,msz,ly,ysp,bfj]
; ogcd_queue := [xj,wxly,gxcb,jg]
; next := 1
; last_reset := A_TickCount
; attack_key := 0 




; main(){
;     Loop {
;         tick := A_TickCount
        
;         update_state()
;         attack()
        
;         tick := 100 - (A_TickCount - tick)
;         if (tick > 0){
;             Sleep, % tick
;         }
;     }
; }



; update_state(){
;     global gcd_cond,in_gcd
;     if (gcd_cond.get()){
;         in_gcd := True        
;     } else {
;         if (in_gcd){
;             in_gcd := False
;             reset_next()
;         }
;     }
;     decide_next()
; }


; decide_next(){
;     global next,combo,last_reset
    
;     if ((A_TickCount - last_reset) > 15000)
;     {
;         reset_next()
;     }

;     if (next != 1)
;     {
;         Return
;     }

;     key := check_queue(combo)

;     if (key > 0)
;     {
;         next := key
;     }
; }
; reset_next()
; {
;     global last_reset,next
;     next := 1
;     last_reset := A_TickCount
; }

; check_queue(queue)
; {
;     for i,v in queue
;     {   
;         if (v[2].get()){
;             return v[1]
;         }
;     }
;     return 0
; }

; gcd()
; {
;     global next,gcd_queue
;     key := check_queue(gcd_queue)
;     if (key){
;         HK := key 
;     } else {
;         HK = F%next%
;     }
;     SendInput, {%HK%}
; }



; ogcd()
; {
;     global ogcd_queue
;     key := check_queue(ogcd_queue)
;    if (key){
;         SendInput, {%key%}
;     }
; }

; attack(){
;     global in_gcd,attack_key
;     if (attack_key){
;         keyDown := GetKeyState(attack_key,"P")
;         if not keyDown 
;         {
;             attack_key := 0
;             Return
;         }
;     } else {
;         Return
;     }

;     if (in_gcd){
;         gcd()
;     } else {
;         ogcd()
;     }
; }

; startAttack(){
;     global attack_key
;     attack_key := "f"
;     Return
; }

; main()


; #z::Suspend
; Space::Shift
; $f::startAttack()
   