#Include, lib/Admin.ahk
#Include, lib/Logger.ahk
#Include, lib/pix.ahk

matcher := new PixRGBMatcher({r_max : 100, g_max : 100, b_max : 100})
cond_gp_empty := new PixCond(773,1495,matcher)
p = [773,1495]
Loop {
    c := pixGet(p)
    cr := c >> 16 & 0xFF
    cg := c >> 8 & 0xFF
    cb := c & 0xFF
    colorHex := Format("{:06X}", c)
    guiText := Format("0x{}(111{: 3u},{: 3u},{: 3u})",colorHex,cr,cg,cb)
    if (cond_gp_empty.meet()){
        log(1 . " " . guiText)
    } else {
        log(0 . " " . guiText)
    }
    Sleep, 100
}



; wid := findFishingGauge()
; if (!wid){
;     MsgBox, 找不到渔捞
; }

; findFishingGauge(){
;     WinGet, lst, List, ahk_exe 鱼糕.exe
;     Loop %lst% {
;         var = lst%A_Index%
;         wid := %var%
;         WinGetTitle, title, ahk_id %wid%
;         if (title == "渔捞"){
;             return wid
;         }
;     }
;     return 0
; }



; maxdiff := 0

; Loop  {
;     tick := A_TickCount
;     PixelGetColor, c, 1815, 1710, RGB
;     diff := A_TickCount - tick
;     log(diff)

;     slp := 100 > diff ? 100 - diff : diff
;     Sleep, slp
; }


; #Include, lib/pix.ahk

; _x := DllCall( "GetSystemMetrics", "Int", 76 )
; _y := DllCall( "GetSystemMetrics", "Int", 77 )
; _w := DllCall( "GetSystemMetrics", "Int", 78 )
; _h := DllCall( "GetSystemMetrics", "Int", 79 )
; m := GetMonitorInfo(2)
; msgbox, % m.Right


; ; Start gdi+
; If !pToken := Gdip_Startup()
; {
;    MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
;    ExitApp
; }



; pBitmap := Gdip_BitmapFromScreen(1)
; If !pBitmap
; {
; 	MsgBox "Could not load the image 'MJ.jpg' "
; 	ExitApp
; }

; tick := A_TickCount
; color := ""
; Loop 50
; {
; 	i:=A_Index
; 	Loop 50
; 	{
;         color .= Gdip_GetPixel(pBitmap,A_Index,i)        
; 	}
; }


; Gdip_SaveBitmapToFile(pBitmap,"test.jpg")
; CoordMode, Pixel, Screen
; CoordMode, Mouse, Screen
; PixelGetColor, c1, 3704, 675, RGB
; c2 := Gdip_GetPixel(pBitmap,3704,675)  
; c2 := c2 & 16777215   
; MsgBox, % c1 " " c2


; MsgBox, % (A_TickCount - tick) / 1000
; MsgBox, % color

; static class Pix {
; 	static x := 1
; }

; a  := new Pix()
; a.x := 2
; b := new Pix()
; msgbox, % b.x

; #Include, lib/screen.ahk
; n := 5
; tick := A_TickCount
; screen_batch()
; Loop % n {
; 	screen_get(n,n)
; }
; diff1 := A_TickCount - tick


; CoordMode, Pixel, Screen
; CoordMode, Mouse, Screen
; tick := A_TickCount
; Loop % n {
; 	PixelGetColor,c, n, n, RGB 
; }
; diff2 := A_TickCount - tick

; MsgBox, % diff1 " | " diff2




; a := "0x2F3437"
; b := 0xFFFFFF & a
; Msgbox, % b

; a := true
; if (a == 1) {
; 	msgbox, 1
; } else {
; 	MsgBox, 0
; }

; class C {
; 	__New(){
; 		this.a := 1
; 	}
; 	match(){

; 	}
; }

; a := new C()
; if (a.match){
; 	MsgBox, Matcher
; } else if (IsObject(a)){
; 	Msgbox, Array
; } else {
; 	Msgbox, Number
; }