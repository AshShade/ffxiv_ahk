#Include, lib/Admin.ahk
#Include, lib/Condition.ahk

; 爆炸射击
bzsj := ["f",new CondTrue()]

; 灵魂能量
lhzs := new CondPixelActive(1601,1722)

; 集中
jz := ["f1", new CondAnd([new CondPixelEq(2425,1697,"FFFEDE"),lhzs])]

; 绝峰箭
jfj := ["f2", lhzs]

; 放浪神
fls := ["f3",new CondPixelEq(1980,1703,"858A33")]

; 军神
js := ["f4", new CondAnd([new CondPixelEq(1348,1593,"756437"),new CondPixelEq(1977,1691,"998787"),new CondPixelEq(2069,1705,"D9A545")])]

; 完美音调
wmyd := ["f5", new CondPixel(1513,1651,"F.F.F.")]


; 九天连箭
jtlj := ["f6", new CondPixel(2176,1751,"E0C4B5|F5E2D9")]
gcd_cond := new CondNot(new CondPixelEq(1804,1716,"2E5D7E"))
in_gcd := True

; 影噬箭
ysj := ["f7",new CondPixelEq(2339,1610,"4D465A")]

; 侧风诱导箭
cf := ["f8",new CondPixelEq(2434,1612,"8C5C5C")]

; 大地神    
dds := ["f9",new CondPixelEq(2344,1708,"62A948")]

; 伤足
sz := ["f10", new CondPixelEq(1980,1602,"9BB5A1")]

; 伤头
st := ["f11", new CondPixelEq(2064,1604,"795C2B")]

; 后跳
ht := ["f12", new CondPixelEq(2124,1656,"3C6644")]

out_range := ["q",new CondPixelEq(1772,1742,"BD2B2B")]

gcd_queue := [out_range,jz,jfj,bzsj]
ogcd_queue := [out_range,fls,js,ht,sz,ysj,wmyd,cf,jtlj,st,dds]
; ogcd_queue := [out_range,fls,js,ht,ysj,wmyd,cf,jtlj]



attack_key := 0 
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


gcd()
{
    global gcd_queue
    exec_queue(gcd_queue)
}



ogcd()
{
    global ogcd_queue
    exec_queue(ogcd_queue)
}

exec_queue(queue)
{
    for i,v in queue
    {   
        if (v[2].get()){
            HK := v[1]
            SendInput, {%HK%}
            return
        }
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
