#Requires AutoHotkey v2.0

#Include Subscriber.ahk

class KeySender extends Subscriber {
    __New(keySupplier, keyMeta){
        this.keySupplier := keySupplier
        this.keyCooldowns := Map()
        this.autoKeys := Map()
        For key, meta in keyMeta {
            if (meta.HasOwnProp("cooldown")) {
                this.keyCooldowns.Set(key, meta.cooldown)
            }
            if (meta.HasOwnProp("auto") && meta.auto) {
                this.autoKeys.Set(key, 1)
            }
        }
        this.lastTimeKeySent := Map()
        this.lastTimeKeySent.Default := 0
    }
    isKeyReady(key) {
        if (!this.autoKeys.Has(key) && !GetKeyState("f")) {
            return false
        }

        if (this.keyCooldowns.Has(key)) {
            this.debug()
            return (A_TickCount - this.lastTimeKeySent.Get(key)) > this.keyCooldowns.Get(key)
        }
        return true
    }
    onNext(data){
        key := this.keySupplier.get()
        if (!key) {
            return
        }
        if (this.isKeyReady(key)) {
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
    }
}