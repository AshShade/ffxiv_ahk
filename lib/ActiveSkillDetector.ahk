#Requires AutoHotkey v2.0
#Include pix.ahk

class ActiveSkillDetector{
    static DefaultActiveCond := PixRGBMatcher({r_min : 180, b_max : 80})
    __New(skils, activeCond := ActiveSkillDetector.DefaultActiveCond){
        this.skils := skils
        this.is_active := activeCond
    }
    get(ps) {
        For skill in this.skils {
            key := skill[1]
            coord := skill[2]
            x := coord[1]
            y := coord[2]
            if (pixMatch(pixGet(x,y,ps),this.is_active) || pixMatch(pixGet(x - 5,y,ps),this.is_active)  || pixMatch(pixGet(x + 5,y,ps),this.is_active) ){
                return key
            }
        }
        return 0
    }
}