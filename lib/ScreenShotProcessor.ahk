#Requires AutoHotkey v2.0

#Include Processor.ahk
#Include  ScreenReader.ahk

class ScreenShotProcessor extends Processor {
    __New(rate, screen){
        this.counter := 0
        this.rate := rate
        this.screen := screen
    }
    onNext(data) {
        if (this.counter == 0) {
            this.ps := this.screen.capture()
            this.submit(this.ps)
            this.screen.release(this.ps)
            this.ps := 0
        }
        this.counter := Mod(this.counter + 1, this.rate)
    }
}