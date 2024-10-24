#Requires AutoHotkey v2.0
#Include  %A_ScriptDir%\lib\pix.ahk

class ScreenObservable {
    __Init() {
        this.observers := []
    }
    AddObserver(observer) {
        this.observers.Push(observer)
    }
    Update() {
        ps := pixScreenBatch()
        Loop this.observers.Length
            this.observers[A_Index].Update(ps)
        pixScreenFree(ps)
    }
    Start(interval := 100){
        Loop {
            tick := A_TickCount
            this.Update()
            tick := interval - (A_TickCount - tick)
            if (tick > 0){
                Sleep(tick)
            }
        }
    }
}