#Requires AutoHotkey v2.0
#Include TimeTickPublisher.ahk
#Include ScreenShotProcessor.ahk
#Include KeySender.ahk
#Include DesicionMaker.ahk
#Include ScreenReader.ahk

class FFXIVCombatRole {
    __New(){
        this.screen := ScreenReader()
        timeTick := TimeTickPublisher(100)
        screenShot := ScreenShotProcessor(1, this.screen)
        decision := DecisionMaker(this.strategy())
        sendKey := KeySender(decision, this.keyMeta())

        timeTick.subscribe(screenShot)
        timeTick.subscribe(sendKey)
        screenShot.subscribe(decision)
    }
    keyMeta() {
        return Map()
    }
    strategy() {
        return []
    }
}

#Include FFXIVHotKeys.ahk