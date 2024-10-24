#Requires AutoHotkey v2.0
#Include  %A_ScriptDir%\lib\pix.ahk

class ActiveSkillObserver {
    static DefaultActiveCond := PixRGBMatcher({r_min : 180, b_max : 80})
    __New(coords, activeCond := ActiveSkillObserver.DefaultActiveCond){
        this.coords := coords 
        this.state := 0
        this.is_active := activeCond
    }

    Update(ps) {
        ; pixScreenSave("screencuts/" A_Now ".png",ps)
        for k,v in this.coords {
            x := v[1]
            y := v[2]
            if (pixMatch(pixGet(x,y,ps),this.is_active) || pixMatch(pixGet(x - 5,y,ps),this.is_active)  || pixMatch(pixGet(x + 5,y,ps),this.is_active) ){
                this.SetState(k)
                return
            }
        }
        this.SetState(0)
    }

    SetState(val){
        this.state := val
    }

    GetState() {
        return this.state
    }
}