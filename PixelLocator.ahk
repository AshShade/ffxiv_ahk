#Requires AutoHotkey v2.0
#Include lib/Admin.ahk
#Include %A_ScriptDir%\lib\pix.ahk

class PixelLocator {
    __New(){
        ; Creates the overlay
        CoordMode "Pixel", "Screen"
        CoordMode "Mouse", "Screen"
        this.gui := Gui("-caption +ToolWindow +AlwaysOnTop +Lastfound", "pixel locator overlay")
        this.gui.SetFont("s24 cwhite W700", "Courier New")

        ; Make the background transparent,
        this.gui.BackColor := "EEAA99"
        WinSetTransColor("EEAA99", this.gui)

        this.gui.Show("x0 y0 w" A_ScreenWidth "h" A_ScreenHeight)

        this.x := 0
        this.y := 0
        this.scale := 1.25

        this.dot := 0
    }

    SetPixel(px,py){
        this.x := px
        this.y := py
        


        if (!this.dot) {
            this.dot := this.gui.Add("Progress","w5 h5 backgroundred")
            this.square := this.gui.Add("Progress", "x" ((A_ScreenWidth - 1000)/this.scale) " y" ((A_ScreenHeight - 200)/this.scale) " w30 h30")
            this.text := this.gui.Add("Text", "w900 x" ((A_ScreenWidth - 930)/this.scale) " y" ((A_ScreenHeight - 200)/this.scale))
        } 

        this.dot.Visible := false
        Sleep -1

        c := pixGet(px,py)
        cr := c >> 16 & 0xFF
        cg := c >> 8 & 0xFF
        cb := c & 0xFF
        colorHex := Format("{:06X}", c)
        guiText := Format("0x{}({: 3u},{: 3u},{: 3u})|{: 4u},{: 4u}",colorHex,cr,cg,cb,Px,Py)

        this.dot.Move(px/this.scale + 1, py/this.scale + 1)
        this.dot.Visible := true
        this.text.Text := guiText
        this.square.Opt("+background" colorHex)
        Sleep -1
        A_Clipboard := "0x" colorHex
    }
    Move(dx,dy) {
        this.SetPixel(this.x+dx, this.y+dy)
    }
}

pl := PixelLocator()

^Enter::{
    MouseGetPos &px,&py
    pl.SetPixel(px,py)
    return
}

^Up::pl.Move(0,-1)
^Left::pl.Move(-1,0)
^Right::pl.Move(1,0)
^Down::pl.Move(0,1)
^/::pl.Move(0,0)
^Backspace::CutScreen()

CutScreen(){
    pl.gui.Hide()
    pixScreenSave("screencuts/" A_Now ".png")
    pl.gui.Show()
}