#Include, lib/Admin.ahk
#Include, lib/pix.ahk
#Include, fishing_strategy/重建4_摇风.ahk

window := new Window()
strategy := new Strategy()
task := new Task(window,strategy)
daemon := new Daemon(task)


OnExit("onAppExit")

onAppExit(){
    global window
    window.pin(0)
}

class Window {
    __New(){
        p_name1 := "ffxiv_dx11.exe"
        WinGet, wid1,ID,ahk_exe %p_name1%
        if (!wid1){
            MsgBox, 找不到FFXIV
            ExitApp
        }
        wid2 := this.findFishingGauge()
        if (!wid2){
            MsgBox, 找不到渔捞
            ExitApp
        }
        this.id := wid1

        WinGetPos , , , , height , ahk_id %wid1%
        y := A_ScreenHeight - height
        WinMove, ahk_id %wid1%,, 0, y
        WinMove, ahk_id %wid2%,, 0, 1320,1000,170
    }

    findFishingGauge(){
        WinGet, lst, List, ahk_exe 鱼糕.exe
        Loop %lst% {
            var = lst%A_Index%
            wid := %var%
            WinGetTitle, title, ahk_id %wid%
            if (title == "渔捞"){
                return wid
            }
        }
        return 0
    }

    send(key){
        wid := this.id 
        ControlSend,,{ %key% }, ahk_id %wid%
    }
    pin(val){
        wid := this.id 
        Winset, Alwaysontop, %val%, ahk_id %wid%
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
    __New(window,strategy){
        this.window := window
        this.strategy := strategy
    }
    init(){
        this.window.pin(1)
        this.fisher := new Fisher(this.window,this.strategy)
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
        this.window.pin(0)
        total := duration / 1000
        sec := Round(Mod(total,60))
        min := Round(total / 60)
        this.window.pin()
        if (this.fisher.s_amiss){
            this.send_notice("鱼塘警惕, 用时: " min "分" sec "秒")
        } else {
            MsgBox, % "停止运行, 用时: " min "分" sec "秒"
        }
    }   
}


class Fisher {
    __New(window,strategy){
        this.window := window
        this.strategy := strategy

        this.cond_amiss := new PixCond(314,1731,0x44B4FF)                           ; 警惕  

        this.cond_cast := new PixCond(700,1700,0xFF9212)                            ; 抛竿
        this.cond_hook := new PixCond(800,1700,0X80EEE6)                            ; 提钩 
        this.cond_mooch := new PixCond(860,1700,0x9C8B31)                           ; 以小钓大
        
        matcher := new PixRGBMatcher({r_max : 100, g_max : 100, b_max : 100})
        this.cond_gp_empty := new PixCond(773,1495,matcher)                         ; 采集力少于100
        this.cond_gp_lack := new PixCond(858,1493,0x57473D)                         ; 采集力少于400
        this.cond_gp_full := new PixCond(1015,1495,0x62A7CB)                        ; 采集力满了
        this.cond_cordial := new PixCond(910,1800,[0x82695F,0x6B695F])              ; [强心剂HQ,轻型强心剂HQ], 高级强心剂，
        this.cond_buff_patience := new PixCond(1000,1600,0xF5997E)                  ; 耐心BUFF
        this.cond_patience2 :=  new PixCond(910,1900,0x11363D)                      ; 耐心2

        this.p_gauge := [18,1350]
        this.c_tug_l := 0x2A9D8F
        this.c_tug_m := 0xC14953
        this.c_tug_h := 0xB68738

        this.p_mooch2 := [1015,1680]                                                ; 以小钓大2
        this.c_mooch2_active := 0x625E5C
        this.c_mooch2_ready := 0x5A5858
    } 

    collect_state_cast(){
        s := []
        ps := pixScreenBatch()
        c := pixGet(this.p_mooch2,ps)
        if (c == this.c_mooch2_active){
            s["mooch2"] := "active"
        } else if (c == this.c_mooch2_ready){
            s["mooch2"] := "ready"
        }
        s["mooch"] := this.cond_mooch.meet(ps)
        
        if (this.cond_gp_full.meet(ps)){
            s["gp"] := "full"
        } else if (this.cond_gp_empty.meet(ps)){
            s["gp"] := "empty"
        } else if (this.cond_gp_lack.meet(ps)){
            s["gp"] := "lack"
        }
        
        s["cordial"] := this.cond_cordial.meet(ps)
        s["buff_patience"] := this.cond_buff_patience.meet(ps)
        s["patience2"] := this.cond_patience2.meet(ps)
        pixScreenFree(ps)
        return s
    }

    get_tug(){
        c := pixGet(this.p_gauge)
        if (c == this.c_tug_l){
            return 1
        } else if (c == this.c_tug_m){
            return 2
        } else if (c == this.c_tug_h){
            return 3
        }
        return 0
    }

    collect_state_hook(){
        s := []
        s["tug"] := this.get_tug()
        s["buff_patience"] := this.cond_buff_patience.meet()
        s["last_cast"] := this.last_cast
        s["last_cast_t"] := this.last_cast_t
        return s
    }

    work(duration){
        if (this.cond_amiss.meet()){
            this.s_amiss := true
            return false
        }
        key := 0
        if (this.cond_cast.meet()){
            state := this.collect_state_cast()
            key := this.strategy.cast(state)
            if (key){
                this.last_cast := key
                this.last_cast_t := A_TickCount
                this.window.send(key)
            }
        } else if (this.cond_hook.meet()){
            state := this.collect_state_hook()
            key := this.strategy.hook(state)
            if (key){
                this.window.send(key)
            }
        }
        t := key ? 1000 : 100
        return t
    }
}

#MaxThreadsPerHotkey 3
#x::daemon.toggle()