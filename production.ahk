#SingleInstance off
AskAdminPermission()
WID := GetFFXIVWindow()

MFile := ""
Missions := []
Total := 0
Running := False
Locking := False

SelectMissions()

SendBg(Key)
{
    global WID
    ControlSend,,{ %Key% }, ahk_id %WID%
    Return
}

AskAdminPermission()
{
    full_command_line := DllCall("GetCommandLine", "str")
    if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
    {
        try
        {
            if A_IsCompiled
                Run *RunAs "%A_ScriptFullPath%" /restart
            else
                Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        }
        ExitApp
    }
}

GetFFXIVWindow()
{
    Pname := "ffxiv_dx11.exe"
    WinGet, WID,ID,ahk_exe %Pname%
    if (!WID){
        MsgBox, Can't find FFXIV window, please make sure you are using DX11 mode
        ExitApp
    }
    return WID
}


SelectMissions(){
    global Missions,Total,MFile,Running,Locking
    if (Locking) 
    {
        Return
    }
    Locking := true
    if (Running)
    {
        MsgBox, Running procedure stoped
        Running := false
    }
    FileSelectFile, MFile

    if (!MFile)
    {
        MsgBox, You have to select a procedure file
        ExitApp
    }
    Total := -1
    Missions := []
    Loop, read, %MFile%
    {
        if (A_Index == 1 && SubStr(A_LoopReadLine, 1, 1) == "#"){
            Total := SubStr(A_LoopReadLine,2)
        } else {
            Ma := StrSplit(A_LoopReadLine,"|"," `t")
            Missions.Push(Ma) 
        }
    }
    if (!Missions.Length()){
        MsgBox, Procedure can't be empty
        ExitApp
    }
    MsgBox, Procedure file installed
    Locking := false
    return Missions
}

ShowCurrentMFile()
{
    global MFile,Locking
    if (Locking){
        return
    }
    Locking := true
    if (Running)
    {
        MsgBox, Running procedure stoped
        Running := false
    }
    MsgBox, Current loading procedure file：%MFile%
    Locking := false
}

ProcessMissions()
{
    #MaxThreadsPerHotkey 1
    global Running,Missions,Total,Locking
    if Locking 
    {
        Return
    }
    if Running  ; This means an underlying thread is already running the loop below.
    {
        Locking := true
        Running := false  ; Signal that thread's loop to stop.
        MsgBox, End procedure
        Locking := false
        return  ; End this thread so that the one underneath will resume and see the change made by the line above.
    }
    
    Running := true
    MissionIndex := 0
    Sleeping := 0
    CountLoop := 0
    Loop
    {
        if not Running 
            break

        if (Sleeping > 0) {
            Sleeping--
            Sleep, 100
            Continue
        }
        Key := Missions[MissionIndex + 1][1]
        Sleeping := Missions[MissionIndex + 1][2] * 10
        SendBg(Key)
        MissionIndex := Mod(MissionIndex + 1,Missions.Length())
        if (MissionIndex == 0){
            CountLoop += 1
        }
        if (CountLoop == Total){
            Locking := true
            Running := false
            MsgBox, Done procedure
            Locking := false
            return
        }
    }
}


#MaxThreadsPerHotkey 3
$F4:: ProcessMissions()
$F11::ShowCurrentMFile()
$F12::SelectMissions()