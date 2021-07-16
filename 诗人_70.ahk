#Include, lib/Condition.ahk

ae := ["e",new CondPixel(2155,1632,"C76D5F")]
a1 := ["1",new CondPixelMultiColor(1976,1594,["F2894C","F49A65"])]
aq := ["q",new CondPixel(2056,1633,"1B011B")]
at := ["t",new CondAnd([new CondPixel(1285,1594,"615826"),new CondPixel(1516,1654,"FFFFFF")])]
ag := ["g",new CondAnd([new CondPixel(1558,1754,"FFFFFF"),new CondPixel(2207,1656,"D5FAFE")])]
av := ["v",new CondPixel(2244,1725,"6993BA")]
af := ["f",new CondTrue()]
ar := ["r",new CondTrue()]
a4 := ["4",new CondAnd([new CondPixel(2415,1725,"8D6F5F"),new CondNot(new CondPixel(2420,1629,"865E33"))])]
; gcd := new CondPixelMultiColor(1804,1716,["58B1F1","68B9F2"])
gcd := new CondPixelMultiColor(1804,1716,["75CBFA","82D0FA"]) ; 绝神兵
need_dot := new CondPixel(1338,1465,"B0EDCD") ; 4sec
check_dot := new CondPixelMultiColor(1333,1440,["A9E6C5","ABE8C7"])
ogcd_queue := [at,ae,aq,a4,av]
r_queue := [ar]
gcd_queue := [ag,a1,af]

dot := True
SetTimer,update_state, 700
toggle := True
F1:: Suspend
Space::Shift

update_state(){
    global dot,check_dot,need_dot
    if (!dot){
        dot := need_dot.get()
        if (dot) {
            SoundBeep
        }
    } else {
        dot := !check_dot.get()
    }
}
attack(key){
    ; global gcd_queue,ogcd_queue
    global gcd_queue,ogcd_queue,r_queue,gcd,dot
    Loop
    {
        keyDown := GetKeyState(Key,"P")
        if not keyDown 
        {
            break
        }
        tick := A_TickCount
       
        if (gcd.get()){
            if (dot){
                queue := r_queue
            } else {
                queue := gcd_queue
            }
        } else {
            queue := ogcd_queue
        }
        for i,v in queue
        {   
            if (v[2].get()){
                SendInput, % v[1]
                break
            }
        }

        tick := 100 - (A_TickCount - tick)
        if (tick > 0){
            Sleep, % tick
        }
    }
}
$f::attack("f")
