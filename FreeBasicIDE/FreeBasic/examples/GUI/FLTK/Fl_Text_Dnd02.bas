#include once "fltk-c.bi"

sub EnableCB cdecl (byval self as Fl_Widget ptr)
  Fl_SetDndTextOps 1
end sub

sub DisableCB cdecl (byval self as Fl_Widget ptr)
  Fl_SetDndTextOps 0
end sub

var win  = Fl_WindowNew(640,146,"Fl_Text_Dnd02.bas")

var inp1 = Fl_InputNew(10,10,620,24)
Fl_Input_SetValue(inp1,"drag and drop text to the other text field.")
var inp2 = Fl_InputNew(10,44,620,24)

var btn1 = Fl_Radio_ButtonNew(10,78,620,24,"Fl_SetDndTextOps 0")
Fl_WidgetSetCallback0 btn1,@DisableCB

var btn2 = Fl_Radio_ButtonNew(10,112,620,24,"Fl_SetDndTextOps 1")
Fl_WidgetSetCallback0 btn2,@EnableCB
Fl_ButtonSetValue btn2,1

Fl_WindowShow win
Fl_Run