#Requires AutoHotkey v2.0

class Publisher {
    __Init() {
        this.subscribers := []
    }
    submit(data := 0) {
        Loop this.subscribers.Length
            this.subscribers[A_Index].onNext(data)
    }
    subscribe(subscriber) {
        this.subscribers.Push(subscriber)
        subscriber.onSubscribe()
    }
    close() {
        Loop this.subscribers.Length
            this.subscribers[A_Index].onComplete()
    }
}