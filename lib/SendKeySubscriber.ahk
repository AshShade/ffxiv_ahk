#Requires AutoHotkey v2.0

#Include Subscriber.ahk

class SendKeySubscriber extends Subscriber {
    __New(keySupplier, keyCooldowns){
        this.keySupplier := keySupplier
        this.keyCooldowns := keyCooldowns
        this.lastTimeKeySent := Map()
        this.lastTimeKeySent.Default := 0
    }
    isKeyReady(key) {
        if (this.keyCooldowns.Has(key)) {
            return (A_TickCount - this.lastTimeKeySent.Get(key)) > this.keyCooldowns.Get(key)
        }
        return true
    }
    onNext(keyPress){
        key := this.keySupplier.get()
        if (!key) {
            key := keyPress
        }
        if (key && this.isKeyReady(key) ) {
            SendInput "{" key "}"
        }
    }
}