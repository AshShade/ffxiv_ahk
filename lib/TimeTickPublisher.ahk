#Requires AutoHotkey v2.0
#Include Publisher.ahk

class TimeTickPublisher extends Publisher {
    __New(interval := 100){
        this.interval :=interval
        this.timer := ObjBindMethod(this, "task")
        this.window := "ahk_exe ffxiv_dx11.exe"
        SetTimer ObjBindMethod(this, "start"), -1
        this.lastTime := 0
    }

    start() {
        SetTimer this.timer, this.interval
        WinWaitNotActive(this.window)
        this.stop()
    }
    stop(){
        SetTimer this.timer, 0
        WinWaitActive(this.window)
        this.start()
    }

    task() {
        if (A_IsSuspended) {
            return
        }
        interval := A_TickCount - this.lastTime
        if (interval < this.interval) {
            Sleep this.interval - interval
        }
        this.submit(0)
        this.close()
        this.lastTime := A_TickCount
    }
}