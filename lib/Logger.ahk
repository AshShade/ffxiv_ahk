class MyLogger {
    __New(){
        ; Creates the overlay
        CoordMode, Pixel, Screen
        CoordMode, Mouse, Screen
        CustomColor = EEAA99  ; Can be any RGB color (it will be made transparent below).
        Gui, Color, %CustomColor%
        Gui, -caption +ToolWindow +AlwaysOnTop
        Gui,Font,s24 cwhite W700,Courier New
        width := 1000
        height := 200
        padding := 30
        Gui, Show, % "x" A_ScreenWidth - width - padding  "y" padding "w" width "h" height, "ahk debugger message show"
        Gui, +Lastfound
        WinSet, TransColor, %CustomColor% 255
        this.selectCanvas( "ahk debugger message show" )
        this.show("Hello World")
    }

    selectCanvas( Title := false )
    {
        static	HWcanvas

        if ( !Ttitle )
            return, HWcanvas
        
        Process, Exist
        WinGet, HWcanvas, ID, %Title% ahk_class AutoHotkeyGUI ahk_pid %ErrorLevel%
    }

    show(message){
        static Ptext
        if ( !Ptext ){
            Gui, Add, Text, % "HwndPtext w400 x0 y0", % message 
        } else {
            GuiControl, Text, % Ptext, % message 
        }
        hw_canvas := this.selectCanvas()
	    WinSet, Redraw,, ahk_id %hw_canvas%
    }

}
logger := new MyLogger()
log(message){
    global logger
    logger.show(message)
}