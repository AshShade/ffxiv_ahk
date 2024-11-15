#Requires AutoHotkey v2.0
#Include lib/FFXIVCombatRole.ahk
#Include lib/ActiveSkillDetector.ahk


class Viper extends FFXIVCombatRole {
    strategy() {
        return [
            ActiveSkillDetector(this.screen,
            [
                ["F1",1830,1083],
                ["F2",1900,1083],
                ["F3",1970,1083]
            ]),
            ActiveSkillDetector(this.screen,
            [
                ["q",1240,1060],
                ["e",1210,1060],
                ["1",1180,1060],
                ["2",1150,1060],
                ["r",1120,1060]
            ], 0xFFFFFF),
            ActiveSkillDetector(this.screen,
            [
                ["2",1970,1009],
                ["1",1900,1009],
                ["e",1830,1009],
                ["q",1760,1009]
            ]),
            "e"
        ]
    }
    keyCooldowns() {
        return Map(
            "F2", 1500,
            "F3", 1500
        )
    }
}
Viper()