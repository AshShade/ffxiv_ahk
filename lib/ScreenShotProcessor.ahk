#Requires AutoHotkey v2.0

#Include Processor.ahk
#Include  pix.ahk

class ScreenShotProcessor extends Processor {
    __New(rate){
        this.counter := 0
        this.rate := rate
    }
    onNext(data) {
        if (this.counter == 0) {
            this.ps := pixScreenBatch()
            this.submit(this.ps)
            pixScreenFree(this.ps)
            this.ps := 0
        }
        this.counter := Mod(this.counter + 1, this.rate)
    }
}