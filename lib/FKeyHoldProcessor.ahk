#Requires AutoHotkey v2.0

#Include Processor.ahk

class FKeyHoldProcessor extends Processor {
    static instance := 0
    static getInstance(){
        if (!FKeyHoldProcessor.instance) {
            FKeyHoldProcessor.instance := FKeyHoldProcessor()
        }
        return FKeyHoldProcessor.instance
    }
    onNext(data) {
        if (GetKeyState("f")) {
            this.submit()
        }
    }
}