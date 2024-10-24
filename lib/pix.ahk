#Include %A_ScriptDir%\lib\Gdip_All.ahk
; Start gdip+
If !pToken := Gdip_Startup()
{
   MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
   ExitApp
}


CoordMode "Pixel", "Screen"

pixScreenBatch(){
    ps := Gdip_BitmapFromScreen(0)
    if (ps == -1){
        MsgBox "pixScreenBatch failed"
        ExitApp    
    }
    return ps
}

pixScreenFree(ps){
    Gdip_DisposeImage(ps)
}

; pixGet(x,y,ps)
; pixGet([x,y],ps)
pixGet(x,y := 0,ps := 0){ 
    if (IsObject(x)){
        ps := y
        y := x[2]
        x := x[1]
    }
    if (ps){
        c := Gdip_GetPixel(ps,x,y) 
    } else {
        c := PixelGetColor(x, y)
    }
    return c & 0xFFFFFF
}
pixScreenSave(fileName, ps := 0){
    ps := ps ? ps : pixScreenBatch()
    Gdip_SaveBitmapToFile(ps,fileName)
}
pixMatch(pix,t){
    if (HasMethod(t,"match")){
        return t.match(pix)
    } else if (IsObject(t)){
        for k, v in t {
            if (pixMatch(pix,v)){
                return True
            }
        }
        return False
    } else {
        return pix == t
    }
}

; new PixCond(x,y,t)
; new PixCond([[x,y,t],...],any=false)
class PixCond {
    __New(x,y := false,t := 0){
        if (IsObject(x)){
            this.conds := x
            this.any := y
        } else {
            this.conds := [[x,y,t]]
            this.any := true
        }
    }
    meet(ps := 0) {
        for k, v in this.conds {
            r := pixMatch(pixGet(v[1],v[2], ps),v[3])
            if (r == this.any){
                return this.any
            } 
        }
        return !this.any
    }
}

class PixRGBMatcher {
    __New(c){
        this.r_min := HasProp(c,"r_min") ? c.r_min : 0
        this.r_max := HasProp(c,"r_max") ? c.r_max : 255

        this.g_min := HasProp(c,"g_min") ? c.g_min : 0
        this.g_max := HasProp(c,"g_max") ? c.g_max : 255
      
        this.b_min := HasProp(c,"b_min") ? c.b_min : 0
        this.b_max := HasProp(c,"b_max") ? c.b_max : 255
    }
    match(pix){
        r := pix >> 16 & 0xFF
        g := pix >> 8 & 0xFF
        b := pix & 0xFF
    
        return r >= this.r_min && r <= this.r_max && g >= this.g_min && g <= this.g_max && b >= this.b_min && b <= this.b_max
    }
}