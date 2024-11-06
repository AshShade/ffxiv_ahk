#Requires AutoHotkey v2.0
#Include TimeTickPublisher.ahk
#Include ScreenShotProcessor.ahk
#Include FKeyHoldProcessor.ahk
#Include DesicionMaker.ahk
#Include SendKeySubscriber.ahk

class FFXIVCombatRole {
    __New(){
        timeTick := TimeTickPublisher(100)
        screenShot := ScreenShotProcessor(3)
        fKey := FKeyHoldProcessor.getInstance()
        decision := DecisionMaker(this.strategy())
        sendKey := SendKeySubscriber(decision, this.keyCooldowns())

        timeTick.subscribe(screenShot)
        timeTick.subscribe(fKey)
        fKey.subscribe(sendKey)
        screenShot.subscribe(decision)
    }
    keyCooldowns() {
        return Map()
    }
    strategy() {
        return []
    }
}

#Include FFXIVHotKeys.ahk