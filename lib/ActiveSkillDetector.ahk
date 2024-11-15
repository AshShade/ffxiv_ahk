#Requires AutoHotkey v2.0

class ActiveSkillDetector{
    static DefaultActiveCond := PixRGBMatcher({r_min:255, g_min:100, b_max : 150})
    __New(screenReader, skils, activeCond := ActiveSkillDetector.DefaultActiveCond){
        this.skills := []
        For skill in skils {
            key := skill[1]
            x := skill[2]
            y := skill[3]
            this.skills.Push([key,[screenReader.register(x,y),screenReader.register(x-5,y),screenReader.register(x+5,y)]])
        }
        this.screenReader := screenReader
        this.is_active := activeCond
    }
    get(ps) {
        For skill in this.skills {
            For index in skill[2] {
                if (pixMatch(this.screenReader.read(ps,index), this.is_active)) {
                    return skill[1]
                }
            }
        }
        return 0
    }
}