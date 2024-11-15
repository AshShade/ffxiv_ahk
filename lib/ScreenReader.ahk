#Requires AutoHotkey v2.0
#Include pix.ahk

class ScreenReader {
    __New() {
        this.min_x := 99999
        this.min_y := 99999
        this.max_x := 0
        this.max_y := 0
        this.width := 0
        this.height := 0
        this.coords := []
    }
    register(x,y) {
        this.coords.Push([x,y])
        this.min_x := x < this.min_x ? x : this.min_x
        this.min_y := y < this.min_y ? y : this.min_y
        this.max_x := x > this.max_x ? x : this.max_x
        this.max_y := y > this.max_y ? y : this.max_y
        this.width := this.max_x - this.min_x + 1
        this.height := this.max_y - this.min_y + 1
        this.width := this.width < 0 ? 0 : this.width
        this.height := this.height < 0 ? 0 : this.height
        return this.coords.Length
    }
    read(ps, index) {
        coord := this.coords.Get(index)
        return Gdip_GetPixel(ps,coord[1] - this.min_x, coord[2] - this.min_y)  & 0xFFFFFF
    }
    capture() {
        ps := Gdip_BitmapFromScreen(this.min_x "|" this.min_y "|" this.width "|" this.height)
        if (ps == -1){
            MsgBox "ScreenReader capture failed"
            ExitApp    
        }
        return ps
    }
    save(ps) {
        Gdip_SaveBitmapToFile(ps,"screencuts/" A_Now ".png")
    }
    release(ps) {
        Gdip_DisposeImage(ps)
    }
}