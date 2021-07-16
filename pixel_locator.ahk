#Include, lib/Admin.ahk
#Include, lib/pix.ahk


; Creates the overlay
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
CustomColor = EEAA99  ; Can be any RGB color (it will be made transparent below).
Gui, Color, %CustomColor%
Gui, -caption +ToolWindow +AlwaysOnTop
Gui,Font,s24 cwhite W700,Courier New
Gui, Show, % "x0 y0 w" A_ScreenWidth "h" A_ScreenHeight, "pixel locator overlay"
Gui, +Lastfound
WinSet, TransColor, %CustomColor% 255
SelectCanvas( "pixel locator overlay" )

X := 0
Y := 0

SetPixel(109,345)
return

GuiClose:
ExitApp

Numpad0::
    MouseGetPos, Px,Py
    SetPixel(Px,Py)
    return


SelectCanvas( Title=false )
{
	static	HWcanvas

	if ( !Ttitle )
		return, HWcanvas
	
	Process, Exist
	WinGet, HWcanvas, ID, %Title% ahk_class AutoHotkeyGUI ahk_pid %ErrorLevel%
}

Numpad8::SetPixel(X,Y-1)
Numpad4::SetPixel(X-1,Y)
Numpad6::SetPixel(X+1,Y)
Numpad2::SetPixel(X,Y+1)
Numpad5::
    Clipboard := SetPixel(X,Y)
    return
NumLock::CutScreen()

CutScreen(){
    gui,Hide
    pixScreenSave("screencuts/" A_Now ".png")
    gui,Show
}



SetPixel(Px,Py)
{
    static Pdot,Ptext,Psquare
    global X,Y
    X := Px
    Y := Py
    scale := 1.5
    c := pixGet(Px,Py)
    cr := c >> 16 & 0xFF
    cg := c >> 8 & 0xFF
    cb := c & 0xFF
    colorHex := Format("{:06X}", c)
    guiText := Format("0x{}({: 3u},{: 3u},{: 3u})|{: 4u},{: 4u}",colorHex,cr,cg,cb,Px,Py)
    if ( !Pdot ){
        Gui, Add, Progress, % "x" ( Px/scale +1) " y" ( Py/scale +1) " w5 h5 backgroundred HwndPdot"
        Gui, Add, Progress, % "x" ((A_ScreenWidth - 1000)/scale) " y" ((A_ScreenHeight - 200)/scale) " w" ( 30 ) " h" ( 30 ) " background" (colorHex) " HwndPsquare"
        Gui, Add, Text, % "HwndPtext w900 x" ((A_ScreenWidth - 930)/scale) " y" ((A_ScreenHeight - 200)/scale), % guiText
    } else {
        GuiControl, Move, % Pdot, % "x" (Px/scale +1) " y" (Py/scale +1)
        GuiControl, Text, % Ptext, % guiText
        GuiControl, % "+background" (colorHex) ,% Psquare
    }
	hw_canvas := SelectCanvas()
	WinSet, Redraw,, ahk_id %hw_canvas%
    return "0x" . colorHex
}
