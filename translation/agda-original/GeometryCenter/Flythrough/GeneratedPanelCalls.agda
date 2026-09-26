module GeometryCenter.Flythrough.GeneratedPanelCalls where

open import GeometryCenter.Prelude

record XFormsCall : Set where
  constructor xformsCall
  field
    creationFunction : String
    sourceCall : String
open XFormsCall public

-- Mechanically preserved from upstream/geometry-center/geomview/src/bin/flythrough/panel.c.
-- XForms itself is an external library; each call below is the exact generated
-- call text and the generated creation routine that contains it.
generatedCalls : List XFormsCall
generatedCalls =
  xformsCall "create_form_MainForm" "MainForm = fl_bgn_form(FL_NO_BOX,240,340);" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_box(FL_UP_BOX,0,0,240,340,\"\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "DodecScale = obj = fl_add_valslider(FL_HOR_SLIDER,10,313,226,22,\"Scale Dodecahedron\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lalign(obj,FL_ALIGN_TOP);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,ScaleProc,0);" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_text(FL_NORMAL_TEXT,0,25,245,20,\"Interactive Hyperbolic Flythrough\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lcolor(obj,FL_BLUE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_text(FL_NORMAL_TEXT,0,215,80,30,\"LAYERS\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_text(FL_NORMAL_TEXT,5,140,230,15,\"PATH\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "Quit = obj = fl_add_button(FL_NORMAL_BUTTON,190,50,40,30,\"Quit\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,QuitProc,0);" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_box(FL_SHADOW_BOX,0,285,245,5,\"\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_BLUE,FL_BLUE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_box(FL_SHADOW_BOX,0,210,245,5,\"\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_BLUE,FL_BLUE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "Info = obj = fl_add_button(FL_PUSH_BUTTON,10,50,170,30,\"What's going on?\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,InfoProc,0);" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_box(FL_SHADOW_BOX,0,130,245,5,\"\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_BLUE,FL_BLUE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "PathGroup = fl_bgn_group();" ∷
  xformsCall "create_form_MainForm" "Direct = obj = fl_add_roundbutton(FL_RADIO_BUTTON,125,150,30,30,\"Direct\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_YELLOW);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lcolor(obj,223);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,PathProc,DIRECT);" ∷
  xformsCall "create_form_MainForm" "Equi = obj = fl_add_roundbutton(FL_RADIO_BUTTON,125,175,30,30,\"Equidistant\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_YELLOW);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lcolor(obj,248);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,PathProc,EQUI);" ∷
  xformsCall "create_form_MainForm" "Quarter = obj = fl_add_roundbutton(FL_RADIO_BUTTON,5,175,30,30,\"Quarter Turn\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_YELLOW);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lcolor(obj,135);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,PathProc,QUARTER);" ∷
  xformsCall "create_form_MainForm" "Loop = obj = fl_add_roundbutton(FL_RADIO_BUTTON,5,150,30,30,\"Full Loop\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_YELLOW);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lcolor(obj,135);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,PathProc,LOOP);" ∷
  xformsCall "create_form_MainForm" "fl_end_group();" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_text(FL_NORMAL_TEXT,0,255,60,30,\"STEPS\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_box(FL_SHADOW_BOX,0,248,245,5,\"\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_BLUE,FL_BLUE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "GoGroup = fl_bgn_group();" ∷
  xformsCall "create_form_MainForm" "Go = obj = fl_add_roundbutton(FL_RADIO_BUTTON,20,88,55,45,\"GO\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_GREEN);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lcolor(obj,FL_GREEN);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,GoProc,1);" ∷
  xformsCall "create_form_MainForm" "Stop = obj = fl_add_roundbutton(FL_RADIO_BUTTON,110,88,55,45,\"STOP\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_RED);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lcolor(obj,FL_RED);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,GoProc,0);" ∷
  xformsCall "create_form_MainForm" "fl_end_group();" ∷
  xformsCall "create_form_MainForm" "TileGroup = fl_bgn_group();" ∷
  xformsCall "create_form_MainForm" "Level3 = obj = fl_add_roundbutton(FL_RADIO_BUTTON,195,215,30,30,\"3\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_YELLOW);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,TilingProc,3);" ∷
  xformsCall "create_form_MainForm" "Level2 = obj = fl_add_roundbutton(FL_RADIO_BUTTON,155,215,30,30,\"2\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_YELLOW);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,TilingProc,2);" ∷
  xformsCall "create_form_MainForm" "Level1 = obj = fl_add_roundbutton(FL_RADIO_BUTTON,115,215,30,30,\"1\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_YELLOW);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,TilingProc,1);" ∷
  xformsCall "create_form_MainForm" "Level0 = obj = fl_add_roundbutton(FL_RADIO_BUTTON,75,215,30,30,\"0\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_YELLOW);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,TilingProc,0);" ∷
  xformsCall "create_form_MainForm" "fl_end_group();" ∷
  xformsCall "create_form_MainForm" "SpeedGroup = fl_bgn_group();" ∷
  xformsCall "create_form_MainForm" "Speed2 = obj = fl_add_roundbutton(FL_RADIO_BUTTON,100,255,30,30,\"20\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_YELLOW);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,SpeedProc,2);" ∷
  xformsCall "create_form_MainForm" "Speed3 = obj = fl_add_roundbutton(FL_RADIO_BUTTON,145,255,30,30,\"40\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_YELLOW);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,SpeedProc,3);" ∷
  xformsCall "create_form_MainForm" "Speed4 = obj = fl_add_roundbutton(FL_RADIO_BUTTON,190,255,30,30,\"80\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_YELLOW);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,SpeedProc,4);" ∷
  xformsCall "create_form_MainForm" "Speed1 = obj = fl_add_roundbutton(FL_RADIO_BUTTON,55,255,30,30,\"10\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_YELLOW);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,SpeedProc,1);" ∷
  xformsCall "create_form_MainForm" "fl_end_group();" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_text(FL_NORMAL_TEXT,5,5,240,20,\"Not Knot: The Software\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lcolor(obj,FL_BLUE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_box(FL_SHADOW_BOX,0,84,245,5,\"\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_BLUE,FL_BLUE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_end_form();" ∷
  xformsCall "create_form_HelpForm" "HelpForm = fl_bgn_form(FL_NO_BOX,530,340);" ∷
  xformsCall "create_form_HelpForm" "obj = fl_add_box(FL_UP_BOX,0,0,530,340,\"\");" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_HelpForm" "HelpBrowser = obj = fl_add_browser(FL_NORMAL_BROWSER,10,35,510,275,\"\");" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_HelpForm" "obj = fl_add_text(FL_NORMAL_TEXT,10,10,435,20,\"Not Knot: The Software   Interactive Hyperbolic Flythrough\");" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lcolor(obj,FL_BLUE);" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lalign(obj,FL_ALIGN_LEFT|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_HelpForm" "Done = obj = fl_add_button(FL_NORMAL_BUTTON,455,10,60,20,\"Done\");" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_callback(obj,DoneProc,0);" ∷
  xformsCall "create_form_HelpForm" "DiagramGroup = fl_bgn_group();" ∷
  xformsCall "create_form_HelpForm" "EucDiag = obj = fl_add_button(FL_RADIO_BUTTON,95,310,140,25,\"Euclidean Diagram\");" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_callback(obj,DiagProc,EUC);" ∷
  xformsCall "create_form_HelpForm" "HypDiag = obj = fl_add_button(FL_RADIO_BUTTON,305,310,150,25,\"Hyperbolic Diagram\");" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_callback(obj,DiagProc,HYP);" ∷
  xformsCall "create_form_HelpForm" "fl_end_group();" ∷
  xformsCall "create_form_HelpForm" "fl_end_form();" ∷ []
