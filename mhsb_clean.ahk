#Include, lib/Admin.ahk

press(key){
    send, {%key% down}
    sleep, 20
    send, {%key% up}
    sleep, 20
}

stop := 0
F1::
    stop := 0
    while true {
        Loop 10 {
            Loop 10 {
                press("g")
                press("s")
                press("Space")
                press("s")
                press("Space")
                press("Space")
                press("d")
                if (stop == 1) {
                    goto, end_label
                }
            }
            press("s")
        }
        press("e")
    }
    end_label:
        sleep, 10

Esc::
    stop := 1