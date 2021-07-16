#Include, lib/Admin.ahk
#Include, lib/Condition.ahk
#Include, lib/Logger.ahk

class File {
    __New(name){
        this.path := "C:\Users\dingk\Desktop\FF14\ffxiv_ahk\log\" name
    }
    append(msg){
        path := this.path
        FileAppend, % msg "`n", % this.path
    }
}

class Window {
    __New(){
        p_name1 := "ffxiv_dx11.exe"
        p_name_2 := "渔人的直感.exe"
        WinGet, wid1,ID,ahk_exe %p_name1%
        if (!wid1){
            MsgBox, 找不到FFXIV
            ExitApp
        }
        WinGet,wid2,ID,ahk_exe %p_name_2%
        if (!wid2){
            MsgBox, 找不到渔人的直感
            ExitApp
        }
        WinGetPos , , , , height , ahk_id %WID1%
        y := A_ScreenHeight - height
        WinMove, ahk_id %wid1%, , -10, y
        Winset, Alwaysontop, 1, ahk_id %wid1%
        WinMove, ahk_id %wid2%,, 0, 1295
        Winset, Alwaysontop, 1, ahk_id %wid2%
        this.pinned := 1
        this.id := wid1
    }
    send(key){
        wid := this.id 
        ControlSend,,{ %key% }, ahk_id %wid%
    }
    pin(){
        pinned := 1 - this.pinned
        wid := this.id 
        this.pinned := pinned
        Winset, Alwaysontop, %pinned%, ahk_id %wid%
    }   
}

class Daemon {
    __New(task){
        this.running := false
        this.t_start := 0
        this.task := task
    }
    toggle(){
        #MaxThreadsPerHotkey 1
        if this.running { ; This means an underlying thread is already running the loop below.
            this.running := false ; Signal that thread's loop to stop.
            return  ; End this thread so that the one underneath will resume and see the change made by the line above.
        }   
        
        this.running := true
        this.task.init()
        this.t_start := A_TickCount
        Loop
        {
            if not this.running {
                break
            }
            t_wait := this.task.run(A_TickCount - this.t_start)
            if (!t_wait){
                this.running := false
            } else {
                Sleep, % t_wait
            }
        }
        this.task.destroy(A_TickCount - this.t_start)
    }
}

class Task {
    __New(){
        this.window := new Window()
        this.file := new File("fisher.log")
    }
    init(){
        this.fisher := new Fisher(this.window,this.file)
    }
    run(duration){
        return this.fisher.work(duration)
    }
    send_notice(msg){
        SoundPlay, sounds/butterfly.mp3
        MsgBox, % msg
        SoundPlay, sounds/none.mp3
    }

    destroy(duration){
        total := duration / 1000
        sec := Round(Mod(total,60))
        min := Round(total / 60)
        if (this.fisher.s_amiss){
            this.send_notice("鱼塘警惕, 用时: " min "分" sec "秒")
        } else if (this.fisher.fail_doublehook){
            this.send_notice("淦, 双提了" this.fisher.fail_doublehook)
        } else if (this.fisher.fail_useless_fish){
            this.send_notice("淦, 提到了杂鱼" this.fisher.fail_useless_fish)
        } else {
            MsgBox, % "停止运行, 用时: " min "分" sec "秒"
        }
    }   
}


class Fisher {
    __New(window,file){
        this.window := window
        this.file := file

        this.t_cast := 0                                                ; 抛竿时间
        this.t_hook := 0                                                ; 提钩时间
        this.t_cordial := 0                                             ; 强心剂转好的时间

        this.p_intuition := new PixelRGBGetter(11,1339)                 ; 直感
        this.p_result := new PixelGetter(370,1830)                      ; 结果


        this.cond_cast := new CondPixelEq(700,1700,"FF950D")            ; 抛竿
        this.cond_hook := new CondPixelEq(800,1700,"64E4E4")            ; 提钩
        this.cond_doublehook := new CondPixelEq(800,1800,"D6F8E7")      ; 双重提钩

        this.cond_gp_full := new CondPixelEq(1005,1495,"5CA2C8")        ; 采集力满了
        this.cond_gp_lack := new CondPixelEq(848,1493,"514138")         ; 采集力少于400
        this.cond_gp_less_800 := new CondPixelEq(980,1493,"514138")     ; 采集力少于800

        this.cond_cordial := new CondPixel(900,1800,"656358|302F2A")    ; 强心剂
        this.cond_slap := new CondPixelEq(970,1810,"08B9FF")            ; 拍击水面
        this.cond_identicalcast := new CondPixelEq(700,1800,"B4DA3A")   ; 专一垂钓

        this.cond_amiss := new CondPixel(680,1730,"FFFFFF|000000")      ; 警惕   
        this.cond_result := new CondPixel(407,1818,"F2F2F2|BCFFBC")     ; 结果
    } 

    cast(key){
        this.window.send(key)
        this.t_cast := A_TickCount
    }

    hook(key){
        this.window.send(key)
        this.catching := 1
        this.is_doublehook := key == "r"
    }

    check_fish(){
        c := this.p_result.get()        
        this.t_hook := A_TickCount

        is_target := false 
        is_useless := false
        Switch c {
            case "5A6162":
                name := "蛉蝎"
                is_useless := true
            case "A55D49":
                name := "飞翼鲂"
            case "B7A1A5":
                name := "白影"
                is_useless := true
            case "141114":
                name := "特供飞沙鱼"
            case "929CBF":
                this.need_slap := true
                name := "皇家披风"
            case "B9C4D0":
                is_target := true
                this.need_identicalcast := this.s_identicalcast ? false : true
                name := "特供飞蝠鲼"
            case "2F3439":
                name := "特供云鲨"
            default:
                name := c
        }

        msg := name " " this.duration (this.s_chum ? " chum" : "")
        if (this.is_doublehook and !is_target){
            this.fail_doublehook := msg
        }
        if (is_useless){
            this.fail_useless_fish := msg
        }
        return msg
    }
    decide_cast(){
        if (this.need_slap){
            if (this.cond_slap.get()){
                this.window.send("t")
                this.need_slap := false
                this.s_slap := true
                return 1000
            }             
            ; else if (A_TickCount - this.t_hook > 15000){
            ;     this.need_slap := false
            ; }
            ; return
        }

        if (this.need_identicalcast) {
            this.need_identicalcast := false
            ; if (this.cond_identicalcast.get() and (!this.cond_gp_less_800.get() or cordial or (this.t_cordial and this.t_cordial - A_TickCount < 15000))){
            if (this.cond_identicalcast.get()){
                this.s_identicalcast := true
                this.window.send("g")
                return 1000
            }
        }

        cordial := this.cond_cordial.get()
        gp_lack := this.cond_gp_lack.get()     
        if (gp_lack and cordial){
            this.window.send("b")
            this.t_cordial := A_TickCount + 180000
            return 1000
        }
        
        if (this.s_identicalcast){
            if (!gp_lack){
                this.cast("1")
            }
            return
        } 
        
        if (this.cond_gp_full.get()){
            this.window.send("c")
            this.s_chum := true
            return 1000
        }
        this.cast("1")
    }

    get_hook_time(){
        ; [披风最大时间,白影最大时间]
        if (this.s_chum){
            ; 撒饵后
            return [17, 10.3]
        } else {
            return [32.1,17.2]
        }
    }

    decide_hook(tug){
        this.duration := (A_TickCount - this.t_cast)/ 1000
        times := this.get_hook_time()
        time_max_hjpf := times[1]
        time_max_by := times[2]

        if (this.cond_doublehook.get()){
            if (this.s_identicalcast){
                 this.hook("r")
                 return
            }

            if (tug == 2){
                if (this.duration > time_max_hjpf){
                    this.hook("r")
                    return
                }
                if (this.s_slap and this.duration > time_max_by){
                    this.hook("r")
                    return
                }
            }
        }

        if (this.duration < time_max_by){
            return
        }
        this.hook("f")
    }
    get_tug(){
        ; 渔人的直感
        ; 宽度    300
        ; 高度    50
        ; 抛竿    #666666
        ; 轻杆    #00FFFF
        ; 中杆    #0000FF
        ; 鱼王杆  #FF00FF
        c := this.p_intuition.get()

        r := c[2]
        g := c[3]
        b := c[4]
        
        if (b < 200){
            Return 0 
        } else if (g > 200){
            return 1
        } else if (r > 200){
            return 3
        } else {
            return 2
        }
    }

    before_next_cast(){
        this.catching := false
        this.s_identicalcast := false
        this.s_slap := false
    }
     
    work(duration){
        if (this.fail_doublehook or this.fail_useless_fish){
            return false
        }
        if (this.cond_amiss.get()){
            this.s_amiss := true
            return false
        }

        if (this.catching)
        {
            if (this.catching++ > 150){
                log("没有检测到钓起的鱼")
                this.before_next_cast()
            } else if (this.cond_result.get()){
                msg := this.check_fish()
                log(msg)
                this.file.append(msg)
                this.before_next_cast()
            }
        } else if (this.cond_cast.get()){
            if (duration > 2700000 and !this.s_slap and !this.s_identicalcast){
                this.s_amiss := true
                return false
            }
            if (this.state != 1){
                this.state := 1
                this.s_chum := false
            }
            t := this.decide_cast()
        } else if (this.cond_hook.get()){
            if (this.state == 1){
                this.state := 2
            }
            tug := this.get_tug()
            if (tug){
                if (this.state != 3){
                    this.state := 3
                    t := this.decide_hook(tug)
                }
            }
        }
        t := t ? t : 100
        return t
    }
}

task := new Task()
daemon := new Daemon(task)

#MaxThreadsPerHotkey 3
$F1::daemon.toggle()
$F2::task.window.pin()