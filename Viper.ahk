#Requires AutoHotkey v2.0
#Include lib/Admin.ahk
#Include lib/ScreenObservable.ahk
#Include lib/ActiveSkillObserver.ahk


class Viper extends ScreenObservable {
    __New() {
        this.activeOgcd := ActiveSkillObserver([[1830,1083],[1900,1083],[1970,1083]])
        this.soulLevel := ActiveSkillObserver([[1240,1060], [1210,1060], [1180,1060],[1150,1060],[1120,1060]],0xFFFFFF)
        this.soulComboKeys := ["q","e","1","2","r"]
        
        this.AddObserver(this.activeOgcd)
        this.AddObserver(this.soulLevel)
    }
    Attack() {
        state := this.activeOgcd.GetState()
        if (state > 0) {
            return "F" state
        }
        state := this.soulLevel.GetState()
        if (state > 0) {
            return this.soulComboKeys[state]
        }
        return 0
    }
}

v := Viper()
v.Start()


#HotIf WinActive("ahk_exe ffxiv_dx11.exe")
#z::Suspend
Space::Shift
CapsLock::0
RShift::Space
Esc::`
#Esc::Esc
f::{
    key := v.Attack()
    if (key) {
        SendInput "{" key "}"
    }
}
HotIfWinActive
#Hotif


