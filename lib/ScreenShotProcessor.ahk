#Requires AutoHotkey v2.0

#Include Processor.ahk
#Include  pix.ahk

class ScreenShotProcessor extends Processor {
    onNext(data) {
        this.ps := pixScreenBatch()
        this.submit(this.ps)
    }
    onComplete() {
        this.close()
        if (this.ps) {
            pixScreenFree(this.ps)
        }
    }
}