#Requires AutoHotkey v2.0

#Include Subscriber.ahk

class DecisionMaker extends Subscriber {
    __New(detectors) {
        this.state := 0
        this.detectors := detectors
    }
    onNext(ps) {
        state := 0
        For detector in this.detectors {
            if (IsObject(detector)) {
                state := detector.get(ps)
            } else {
                state := detector
            }
            if (state) {
                this.state := state
                return
            }
        }   
    }
    get() {
        return this.state
    }
}