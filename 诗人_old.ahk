#Include, lib/Admin.ahk
#Include, lib/Condition.ahk

; 失血箭
sx_cond := new CondPixelEq(2155,1632,"CC6556")
sx := ["e",sx_cond]
; 死亡箭雨
swjy := ["F4",sx_cond]

; 辉煌箭
hh := ["1",new CondPixel(1976,1594,"F2894C|F49A65")]

; 九天连箭
jt := ["q",new CondPixelEq(2056,1633,"1B011B")]

; 完美音调
wmyd := ["F1",new CondAnd([
    ; 旅神量普
    ,new CondPixel(1283,1604,"CEC94C")
    ; 第三诗心
    ,new CondPixel(1516,1654,"F.F.F.")])]

; 绝峰箭
jf := ["g",new CondPixel(1558,1754,"FFFFFF")]

; 战斗之声
zdzs := ["F2",new CondPixel(2244,1725,"6993BA")]

; 爆炸射击
bzsj := ["f",new CondTrue()]

; 连珠箭
lz := ["F3",new CondNot(new CondPixel(1145,1860,"CB3232"))]


; 伶牙俐齿
lylc := ["r",new CondTrue()]

cf_cond := new CondAnd([new CondPixel(2415,1725,"8D6F5F"),new CondNot(new CondPixel(2420,1629,"865E33"))])
; 侧风诱导箭
cf := ["4",cf_cond]
; 影噬箭
ysj := ["F5",cf_cond]

in_gcd := False
gcd_cond := new CondNot(new CondPixel(1804,1716,"2E5D7E"))
need_dot := new CondPixel(1338,1465,"B0EDCD") ; 4sec
check_dot := new CondPixel(1333,1440,"A9E6C5|ABE8C7")

r_queue := [lylc]
gcd_queue := [jf,hh,bzsj]
ogcd_queue := [wmyd,sx,jt,cf,zdzs]
aoe_gcd_queue := [jf,lz,hh,bzsj]
aoe_ogcd_queue := [swjy,wmyd,jt,ysj,zdzs]

main(){
    Loop {
        tick := A_TickCount
        
        update_state()
        attack()
        
        tick := 100 - (A_TickCount - tick)
        if (tick > 0){
            Sleep, % tick
        }
    }
}



update_state(){
    global gcd_cond,in_gcd

    if (gcd_cond.get()){
        in_gcd := True       
    } else {
        if (in_gcd){
            in_gcd := False
        }
    }
}

check_queue(queue)
{
    for i,v in queue
    {   
        if (v[2].get()){
            return v[1]
        }
    }
    return 0
}

gcd()
{
    global gcd_queue

    HK := check_queue(gcd_queue)
    SendInput, {%HK%}
}



ogcd()
{
    global ogcd_queue

    HK := check_queue(ogcd_queue)
    SendInput, {%HK%}
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

; dot := True
; SetTimer,update_state, 400
; toggle := True
; #z:: Suspend
; Space::Shift

; update_state(){
;     global dot,check_dot,need_dot
;     if (!dot){
;         dot := need_dot.get()
;         if (dot) {
;             SoundBeep
;         }
;     } else {
;         dot := !check_dot.get()
;     }
; }
; attack(key,gcd_q,ogcd_q){
;     global r_queue,in_gcd,dot
;     Loop
;     {
;         keyDown := GetKeyState(Key,"P")
;         if not keyDown 
;         {
;             break
;         }
;         tick := A_TickCount
       
;         if (in_gcd.get()){
;             if (dot){
;                 queue := r_queue
;             } else {
;                 queue := gcd_q
;             }
;         } else {
;             queue := ogcd_q
;         }
;         for i,v in queue
;         {   
;             if (v[2].get()){
;                 HK := v[1]
;                 SendInput, {%HK%}
;                 break
;             }
;         }

;         tick := 100 - (A_TickCount - tick)
;         if (tick > 0){
;             Sleep, % tick
;         }
;     }
; }
; $f::attack("f",gcd_queue,ogcd_queue)
; $v::attack("v",aoe_gcd_queue,aoe_ogcd_queue)
