#Requires AutoHotkey v2.0
#Include Publisher.ahk

class TimeTickPublisher extends Publisher {
    __New(interval := 100){
        timer := ObjBindMethod(this, "task")
        SetTimer timer, interval
    }
    task() {
        this.submit(0)
        this.close()
    }
}