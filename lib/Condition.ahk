class CondAnd {
    __New(Conds){
        this.Conds := Conds
    }
    get(){
        for k, v in this.Conds{
            if (!v.get()){
                return False
            }
        }
        return True
    }
}
class CondOr {
    __New(Conds){
        this.Conds := Conds
    }
    get(){
        for k, v in this.Conds{
            if (v.get()){
                return True
            }
        }
        return False
    }
}

class CondTrue{
    get() {
        return True
    }
}


class CondNot{
    __New(Cond){
        this.Cond := Cond
    }
    get(){
        return ! this.Cond.get()
    }
}

CoordMode, Pixel, Screen

class PixelGetter {
    __New(Px,Py){
        this.Px := Px
        this.Py := Py
    }
    get(){
        PixelGetColor, Pcolor, this.Px, this.Py,RGB
        Return Substr(Pcolor,3)
    }
}

class PixelRGBGetter extends PixelGetter{
    get(){
        PixelGetColor, Pcolor, this.Px, this.Py,RGB
        HexR := Substr(Pcolor,1,4)
        R := HexR & 255
        HexG := "0x"Substr(Pcolor,5,2)
        G := HexG & 255
        HexB := "0x"Substr(Pcolor,7,2)
        B := HexB & 255
        Return [Pcolor,R,G,B]
    }
}

class CondPixel {
    __New(Px,Py,Regex){
        this.Px := Px
        this.Py := Py
        this.Regex := "^" . Regex . "$"
    }
    get(){
        PixelGetColor, Pcolor, this.Px, this.Py,RGB
        Return RegExMatch(Substr(Pcolor,3), this.Regex)
    }
}
class CondPixelEq {
    __New(Px,Py,Pcolor){
        this.Px := Px
        this.Py := Py
        this.Color := Pcolor
        this.Len := StrLen(this.Color)
    }
    get(){
        PixelGetColor, Pcolor, this.Px, this.Py,RGB
        Return Substr(Pcolor,3,this.Len) == this.Color
    }
}




class CondPixelActive {
    __New(Px,Py){
        this.Px := Px
        this.Py := Py
    }
    get(){
        PixelGetColor, Pcolor, this.Px, this.Py,RGB
        HexR := Substr(Pcolor,1,4)
        R := HexR & 255
        HexB := "0x"Substr(Pcolor,7,2)
        B := HexB & 255
        return R > 180 && B < 80
    }
}

class CondPixelCountDown {
     __New(Px,Py){
        this.Px := Px
        this.Py := Py
    }
    get(){
        PixelGetColor, Pcolor, this.Px, this.Py,RGB
        HexR := Substr(Pcolor,1,4)
        R := HexR & 255
        HexG := "0x"Substr(Pcolor,5,2)
        G := HexG & 255
        HexB := "0x"Substr(Pcolor,7,2)
        B := HexB & 255

        return R == G && G == B && R >= 160
    }
}