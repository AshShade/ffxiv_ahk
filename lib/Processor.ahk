#Requires AutoHotkey v2.0
#Include Publisher.ahk

class Processor extends Publisher {
    onSubscribe() {
    }
    onNext(data := 0) {
        this.submit(data)
    }
    onComplete() {
        this.close()
    }
}