#Include, lib/Admin.ahk
#Include, lib/Condition.ahk
#Include, lib/Logger.ahk

WID := GetFFXIVWindow()
Running := false
TickStart := 0
TickPG := 0
TickNX := 0

MGL_MODE := false
; 直感
; 宽度    300
; 高度    50
; 抛竿    #666666
; 轻杆    #00FFFF
; 中杆    #0000FF
; 鱼王杆  #FF00FF
ZG := new PixelRGBGetter(11,1339)

; 抛竿
PG := new CondPixelEq(700,1700,"FF950D")

; 提钩
TG := new CondPixelEq(800,1700,"64E4E4")

; 耐心
NX := new CondPixelEq(990,1600,"F59478")

; 双重提钩
SCTG := new CondPixelEq(800,1800,"D6F8E7")

; 以小钓大
YXDD := False

YXDD1 := new CondPixelEq(850,1700,"97852B")
YXDD2 := new PixelGetter(1005,1680)

; 采集力不够
NGP := new CondPixelEq(860,1492,"504137")

; 采集力满了
FGP := new CondPixelEq(1005,1495,"5CA2C8")

; 强心剂
QXJ := new CondPixel(900,1800,"656358|302F2A") ; 强心剂


; 结束
ED := new CondPixel(680,1730,"FFFFFF|000000")

; 拍击水面
PJSM := new CondPixelEq(970,1810,"08B9FF")

; 上一杆
Last := 0

; 结果
cond_result := new CondPixelEq(407,1818,"F2F2F2")
p_result := new PixelGetter(370,1830)


GetFFXIVWindow()
{
    Pname1 := "ffxiv_dx11.exe"
    Pname2 := "渔人的直感.exe"
    WinGet, WID1,ID,ahk_exe %Pname1%
    if (!WID1){
        MsgBox, 找不到FFXIV
        ExitApp
    }
    WinGet,WID2,ID,ahk_exe %Pname2%
    if (!WID2){
        MsgBox, 找不到渔人的直感
        ExitApp
    }
    WinGetPos , , , , Height , ahk_id %WID1%
    Y := A_ScreenHeight - Height
    WinMove, ahk_id %WID1%, , -10, Y
    Winset, Alwaysontop, 1, ahk_id %WID1%
    WinMove, ahk_id %WID2%,, 0, 1295
    return WID1
}

SendBg(Key)
{
    global WID
    ControlSend,,{ %Key% }, ahk_id %WID%
    Return
}

DoPG(Key){
    global TickPG,YXDD, MGL_MODE
    YXDD := Key != "1"
    TickPG := A_TickCount
    SendBg(Key)
}

DecidePG()
{
    global NX,YXDD1,YXDD2,NGP,QXJ,TickNX,PJSM, Last

    Colour := YXDD2.get()
    NX_ON := NX.get()
    GP := !NGP.get()

    ; 以小钓大2 激活中
    if (Colour == "5C5756"){
        DoPG("3")
        Return
    }

    if (YXDD1.get()){
        DoPG("2")
        Return
    }
    if (!GP){
        if (QXJ.get()){
            SendBg("b")
            Sleep, 500
            Return
        }
    } else {
        if (!NX_ON && (Colour != "545252")){
            ; 以小钓大2 CD中
            TickNX := A_TickCount
            SendBg("z")
            Sleep, 500
            Return
        }
        if (PJSM.get() && Last == 2){
            SendBg("t")
            Sleep, 500
            Return
        }
    }
    DoPG("1")



    ; 以小钓大2 激活中
    ; if (Colour == "5C5756" && !NX_ON){
    ;     if (MGL_MODE || GP){
    ;         DoPG("3")
    ;         Return
    ;     }
    ; }
    ; if (YXDD1.get()){
    ;     if (MGL_MODE){
    ;         if (EndCount(TickNX) < 40 || !NX_ON){
    ;             DoPG("2")
    ;             Return
    ;         }
    ;     } else if (EndCount(TickNX) < 25 || (GP && !NX_ON)){
    ;         DoPG("2")
    ;         Return
    ;     }
    ;     Return
    ; }

    ; if (!GP){
    ;     if (QXJ.get()){
    ;         SendBg("c")
    ;         Sleep, 200
    ;         Return
    ;     }
    ; } else {
    ;     if (PJSM.get() && Last == 2){
    ;         SendBg("4")
    ;         Return
    ;     }
    ;     if (!NX_ON && (Colour != "545252")){
    ;         ; 以小钓大2 CD中
    ;         TickNX := A_TickCount
    ;         SendBg("z")
    ;         Return
    ;     }
    ; }

    ; ; 以小钓大2 CD转好了
    ; if (Colour == "545252"){

    ; DoPG("1")
}

DoTG(Key){
    global cond_result,p_result
    SendBg(Key)
    result := 0
    i := 0
    while (++i < 150){
        if (cond_result.get()){
            c := p_result.get()
            Switch c {
                case "5A6162":
                    log("蛉蝎")
                case "A55D49":
                    log("飞翼鲂")
                case "B7A1A5":
                    log("白影")
                case "141114":
                    log("特供飞沙鱼")
                default:
                    log(c)
            }
            return
        }
        Sleep, 100
    }
    log("没有检测到钓上来的鱼")
}

DecideTG()
{
    global NX,YXDD,ZG,SCTG,TickPG,MGL_MODE,FGP,Last,QXJ

    State := ZG.get()

    R := State[2]
    G := State[3]
    B := State[4]
    
    ; 轻杆    #00FFFF
    ; 中杆    #0000FF
    ; 鱼王杆  #FF00FF


    if (B < 200){
        Return
    }

    if (G > 200){
        Last := 1
    } else if (R > 200){
        Last := 3
    } else {
        Last := 2
    }



    if (NX.get()){
        if (Last == 1){
            DoTG("q")
        } else {
            DoTG("e")
        }
    } else {
        DoTG("f")
    }
 
    ; if (MGL_MODE){
    ;     if (B < 200){
    ;         Return
    ;     }
    ;     if (NX.get()){
    ;         if (G > 200){
    ;             SendBg("q")
    ;         } else {
    ;             SendBg("f")
    ;         }
    ;     } else {
    ;         if (YXDD && G > 200 && SCTG.get()){
    ;             SendBg("r")
    ;         } else {
    ;             SendBg("f")
    ;         }
    ;     }
    ; } else {
    ;     Sec := EndCount(TickPG)
    ;     if (B < 200){
    ;         if (Sec > 18 && !YXDD){
    ;             SendBg("f")
    ;         }
    ;         if (Last > 1){
    ;             Last := 3
    ;         } else {
    ;             Last := 0
    ;         }
    ;         Return
    ;     }
    ;     if (G < 200){
    ;         if (!YXDD && Last < 2 && !NX.get() && (FGP.get() || QXJ.get())){
    ;             SendBg("f")
    ;             Last := 2
    ;         }
    ;         Return
    ;     }
    ;     Last := 1
    ;     if (NX.get()){
    ;         SendBg("q")
    ;     } else if (YXDD && SCTG.get()){
    ;         SendBg("r")
    ;     } else {
    ;         SendBg("f")
    ;     }
    ; }
}
EndCount(Tick)
{
    return (A_TickCount - Tick) / 1000
}

SendNotice()
{
    global TickStart
    Sec := Round(EndCount(TickStart))
    SoundPlay, sounds/butterfly.mp3
    MsgBox, 向左或向右移动游戏人物几步，对着岸边按下F1，如果还是触发此提示，则叫你老公起床, 鱼塘警惕用时%Sec% 秒
    SoundPlay, sounds/none.mp3
}



Start()
{
    #MaxThreadsPerHotkey 1
    global Running, TickStart, ED, PG, TG

    if Running  ; This means an underlying thread is already running the loop below.
    {
        Running := false  ; Signal that thread's loop to stop.
        Sec := EndCount(TickStart)
        MsgBox, 停止运行, 用时：%Sec% 秒
        return  ; End this thread so that the one underneath will resume and see the change made by the line above.
    }
    Running := true
    TickStart := A_TickCount
    Loop
    {
        if not Running 
            break

        if (ED.get()){
            Running := false
            SendNotice()
            break
        }
        if (PG.get()){
            DecidePG()
        } else if (TG.get()){
            DecideTG()
        }
        Sleep, 100
    }
}

End()
{
    global WID
    Winset, Alwaysontop, 0, ahk_id %WID%
    ExitApp
}

#MaxThreadsPerHotkey 3
$F1::Start()
; $F2::End()