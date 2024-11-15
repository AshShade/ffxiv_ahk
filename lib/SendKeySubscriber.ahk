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
            this.lastTimeKeySent.Set(key, A_TickCount)
            SendInput "{" key "}"
        }
    }
    debug() {
        interval := A_TickCount - this.lastTimeKeySent.Get("log")
        pmin := this.lastTimeKeySent.Get("min")
        pmax := this.lastTimeKeySent.Get("max")
        
        if (pmin == 0 || interval < pmin) {
            pmin := interval
        }
        if ((pmax == 0 || interval > pmax) && interval < 1000) {
            pmax := interval
        }

        this.lastTimeKeySent.Set("log",A_TickCount,"min",pmin,"max",pmax)
        ; Logger.log(interval " | Min: " pmin " | Max: " pmax)
    }
}