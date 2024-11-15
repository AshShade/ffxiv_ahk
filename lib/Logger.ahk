#Requires AutoHotkey v2.0

class Logger {
    __New(){
        ; Creates the overlay
        CoordMode "Pixel", "Screen"
        CoordMode "Mouse", "Screen"
        this.gui := Gui("-caption +ToolWindow +AlwaysOnTop +Lastfound", "ahk debugger message show")
        this.gui.SetFont("s24 cwhite W700", "Courier New")

        ; Make the background transparent,
        this.gui.BackColor := "EEAA99"
        WinSetTransColor("EEAA99", this.gui)

        width := 1000
        height := 200
        padding := 30
        this.gui.Show("x" A_ScreenWidth - width - padding  "y" padding "w" width "h" height)
        this.text := 0
    }

    show(message){
        if (!this.text) {
            this.text := this.gui.Add("Text", "w800 x0 y0")
        } 
        this.text.Text := message
        Sleep -1
    }

    static instance := 0
    static getInstance(){
        if (!Logger.instance) {
            Logger.instance := Logger()
        }
        return Logger.instance
    }
    static log(message) {
        Logger.getInstance().show(message)
    }
}

Logger.log("Hello World")