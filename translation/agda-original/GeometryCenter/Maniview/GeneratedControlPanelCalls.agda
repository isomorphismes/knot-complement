module GeometryCenter.Maniview.GeneratedControlPanelCalls where

open import GeometryCenter.Prelude

record XFormsCall : Set where
  constructor xformsCall
  field
    creationFunction : String
    sourceCall : String
open XFormsCall public

-- Mechanically preserved from upstream/geometry-center/maniview/controlpanel.c.
-- XForms itself is an external library; each call below is the exact generated
-- call text and the generated creation routine that contains it.
generatedCalls : List XFormsCall
generatedCalls =
  xformsCall "create_form_MainForm" "MainForm = fl_bgn_form(FL_NO_BOX,250,460);" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_box(FL_UP_BOX,0,0,250,460,\"\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_text(FL_NORMAL_TEXT,60,10,130,50,\"Maniview\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_FRAME_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_WHITE,FL_COL1);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE+FL_ENGRAVED_STYLE);" ∷
  xformsCall "create_form_MainForm" "SaveButton = obj = fl_add_button(FL_PUSH_BUTTON,20,150,210,40,\"Save\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_SHADOW_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,SaveButtonProc,0);" ∷
  xformsCall "create_form_MainForm" "DisplayButton = obj = fl_add_button(FL_PUSH_BUTTON,20,190,210,40,\"Display\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_SHADOW_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,DisplayButtonProc,0);" ∷
  xformsCall "create_form_MainForm" "InfoButton = obj = fl_add_button(FL_PUSH_BUTTON,20,350,210,40,\"Info\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_SHADOW_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,InfoButtonProc,0);" ∷
  xformsCall "create_form_MainForm" "EnumerateButton = obj = fl_add_button(FL_PUSH_BUTTON,20,230,210,40,\"Enumerate\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_SHADOW_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,EnumerateButtonProc,0);" ∷
  xformsCall "create_form_MainForm" "TileFormButton = obj = fl_add_button(FL_PUSH_BUTTON,20,270,210,40,\"Basic Tile\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_SHADOW_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,TileButtonProc,0);" ∷
  xformsCall "create_form_MainForm" "HelpButton = obj = fl_add_button(FL_PUSH_BUTTON,20,310,210,40,\"Help\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_SHADOW_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,HelpButtonProc,0);" ∷
  xformsCall "create_form_MainForm" "QuitButton = obj = fl_add_button(FL_PUSH_BUTTON,20,390,210,40,\"Quit\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_SHADOW_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,QuitButtonProc,0);" ∷
  xformsCall "create_form_MainForm" "obj = fl_add_text(FL_NORMAL_TEXT,40,60,170,30,\"A 3-Manifold Viewer\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_FRAME_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "LoadButton = obj = fl_add_button(FL_PUSH_BUTTON,20,110,210,40,\"Load\");" ∷
  xformsCall "create_form_MainForm" "fl_set_object_boxtype(obj,FL_SHADOW_BOX);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_MainForm" "fl_set_object_callback(obj,LoadButtonProc,0);" ∷
  xformsCall "create_form_MainForm" "fl_end_form();" ∷
  xformsCall "create_form_DisplayForm" "DisplayForm = fl_bgn_form(FL_NO_BOX,320,380);" ∷
  xformsCall "create_form_DisplayForm" "obj = fl_add_box(FL_UP_BOX,0,0,320,380,\"\");" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_DisplayForm" "CullzButton = obj = fl_add_button(FL_PUSH_BUTTON,150,180,110,30,\"cull\");" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_callback(obj,DisplayProc,DG_ZCULL);" ∷
  xformsCall "create_form_DisplayForm" "CentercamButton = obj = fl_add_button(FL_PUSH_BUTTON,40,120,110,30,\"centercam\");" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_callback(obj,DisplayProc,DG_CENTERCAM);" ∷
  xformsCall "create_form_DisplayForm" "DirdomButton = obj = fl_add_button(FL_PUSH_BUTTON,150,120,110,30,\"draw dirdom\");" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_callback(obj,DisplayProc,DG_DRAWDIRDOM);" ∷
  xformsCall "create_form_DisplayForm" "ShowcamButton = obj = fl_add_button(FL_PUSH_BUTTON,40,150,110,30,\"showcam\");" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_callback(obj,DisplayProc,DG_DRAWCAM);" ∷
  xformsCall "create_form_DisplayForm" "obj = fl_add_text(FL_NORMAL_TEXT,90,80,120,40,\"Toggles\");" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_boxtype(obj,FL_FRAME_BOX);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lstyle(obj,FL_NORMAL_STYLE+FL_ENGRAVED_STYLE);" ∷
  xformsCall "create_form_DisplayForm" "DisplayOKButton = obj = fl_add_button(FL_NORMAL_BUTTON,250,25,50,45,\"OK\");" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_callback(obj,DisplayOKButtonProc,0);" ∷
  xformsCall "create_form_DisplayForm" "Attenuation2Slider = obj = fl_add_valslider(FL_HOR_SLIDER,60,280,230,30,\"fogfree\");" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lalign(obj,FL_ALIGN_LEFT);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_callback(obj,Attenuation2SliderProc,0);" ∷
  xformsCall "create_form_DisplayForm" "obj = fl_add_box(FL_FRAME_BOX,10,20,210,50,\"Display Settings\");" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_color(obj,FL_WHITE,FL_COL1);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_DisplayForm" "Attenuation3Slider = obj = fl_add_valslider(FL_HOR_SLIDER,60,330,230,30,\"fog\");" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lalign(obj,FL_ALIGN_LEFT);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_callback(obj,Attenuation3SliderProc,0);" ∷
  xformsCall "create_form_DisplayForm" "SoftshadeButton = obj = fl_add_button(FL_PUSH_BUTTON,40,180,110,30,\"software shading\");" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_callback(obj,SoftshadeProc,0);" ∷
  xformsCall "create_form_DisplayForm" "Attenuation1Slider = obj = fl_add_valslider(FL_HOR_SLIDER,60,230,230,30,\"atten1\");" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lalign(obj,FL_ALIGN_LEFT);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_callback(obj,Attenuation1SliderProc,0);" ∷
  xformsCall "create_form_DisplayForm" "DrawGeomButton = obj = fl_add_button(FL_PUSH_BUTTON,150,150,110,30,\"draw geom\");" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_DisplayForm" "fl_set_object_callback(obj,DisplayProc,DG_DRAWGEOM);" ∷
  xformsCall "create_form_DisplayForm" "fl_end_form();" ∷
  xformsCall "create_form_EnumForm" "EnumForm = fl_bgn_form(FL_NO_BOX,400,250);" ∷
  xformsCall "create_form_EnumForm" "obj = fl_add_box(FL_UP_BOX,0,0,400,250,\"\");" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_EnumForm" "WorddepthCounter = obj = fl_add_counter(FL_NORMAL_COUNTER,160,80,130,40,\"worddepth\");" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_lalign(obj,FL_ALIGN_LEFT);" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_callback(obj,WorddepthProc,0);" ∷
  xformsCall "create_form_EnumForm" "RadiusSlider = obj = fl_add_valslider(FL_HOR_SLIDER,130,140,240,30,\"tesselation radius\");" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_lalign(obj,FL_ALIGN_LEFT);" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_callback(obj,RadiusProc,0);" ∷
  xformsCall "create_form_EnumForm" "obj = fl_add_text(FL_NORMAL_TEXT,30,20,220,40,\"Enumerate Group\");" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_boxtype(obj,FL_FRAME_BOX);" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_color(obj,FL_WHITE,FL_COL1);" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_EnumForm" "EnumOKButton = obj = fl_add_button(FL_NORMAL_BUTTON,330,25,50,45,\"OK\");" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_callback(obj,EnumOKButtonProc,0);" ∷
  xformsCall "create_form_EnumForm" "DrawRadiusSlider = obj = fl_add_valslider(FL_HOR_SLIDER,130,190,240,30,\"draw radius\");" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_lalign(obj,FL_ALIGN_LEFT);" ∷
  xformsCall "create_form_EnumForm" "fl_set_object_callback(obj,DrawRadiusProc,0);" ∷
  xformsCall "create_form_EnumForm" "fl_end_form();" ∷
  xformsCall "create_form_TileForm" "TileForm = fl_bgn_form(FL_NO_BOX,400,320);" ∷
  xformsCall "create_form_TileForm" "obj = fl_add_box(FL_UP_BOX,0,0,400,320,\"\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_TileForm" "obj = fl_add_box(FL_BORDER_BOX,10,140,380,170,\"\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_TileForm" "DDZDial = obj = fl_add_dial(FL_LINE_DIAL,310,160,70,70,\"z\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_boxtype(obj,FL_BORDER_BOX);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lalign(obj,FL_ALIGN_LEFT);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_callback(obj,DDZProc,0);" ∷
  xformsCall "create_form_TileForm" "obj = fl_add_text(FL_NORMAL_TEXT,30,160,100,20,\"Center Point\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lcolor(obj,137);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lalign(obj,FL_ALIGN_LEFT|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_TileForm" "obj = fl_add_text(FL_NORMAL_TEXT,40,180,90,20,\"Chooser\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lcolor(obj,137);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lalign(obj,FL_ALIGN_LEFT|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_TileForm" "DDXYPositioner = obj = fl_add_positioner(FL_NORMAL_POSITIONER,190,160,80,70,\"(x,y)\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lalign(obj,FL_ALIGN_LEFT);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_callback(obj,DDXYProc,0);" ∷
  xformsCall "create_form_TileForm" "DDResetButton = obj = fl_add_button(FL_NORMAL_BUTTON,40,200,90,30,\"Reset\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_callback(obj,DDResetProc,0);" ∷
  xformsCall "create_form_TileForm" "obj = fl_add_text(FL_NORMAL_TEXT,20,20,130,40,\"Basic Tile\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_boxtype(obj,FL_FRAME_BOX);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_color(obj,FL_WHITE,FL_COL1);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_TileForm" "DDScaleSlider = obj = fl_add_valslider(FL_HOR_SLIDER,120,260,240,30,\"scale factor\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lalign(obj,FL_ALIGN_LEFT);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_callback(obj,DDScaleProc,0);" ∷
  xformsCall "create_form_TileForm" "TileOKButton = obj = fl_add_button(FL_NORMAL_BUTTON,330,15,50,45,\"OK\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_callback(obj,TileOKButtonProc,0);" ∷
  xformsCall "create_form_TileForm" "obj = fl_add_box(FL_BORDER_BOX,20,80,360,50,\"\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_TileForm" "obj = fl_add_text(FL_NORMAL_TEXT,30,90,60,30,\"MODE:\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lalign(obj,FL_ALIGN_LEFT|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_TileForm" "DirichletDomainButton = obj = fl_add_button(FL_NORMAL_BUTTON,110,90,120,30,\"Dirichlet domain\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_callback(obj,TileModeProc,DIRDOM_MODE);" ∷
  xformsCall "create_form_TileForm" "UsergeometryButton = obj = fl_add_button(FL_NORMAL_BUTTON,260,90,110,30,\"User geometry\");" ∷
  xformsCall "create_form_TileForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_TileForm" "fl_set_object_callback(obj,TileModeProc,USER_GEOM);" ∷
  xformsCall "create_form_TileForm" "fl_end_form();" ∷
  xformsCall "create_form_InfoForm" "InfoForm = fl_bgn_form(FL_NO_BOX,330,310);" ∷
  xformsCall "create_form_InfoForm" "obj = fl_add_box(FL_UP_BOX,0,0,330,310,\"\");" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_InfoForm" "InfoFormLabel = obj = fl_add_text(FL_NORMAL_TEXT,80,30,150,40,\"Maniview\");" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_InfoForm" "obj = fl_add_text(FL_NORMAL_TEXT,11,66,300,30,\"by\");" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_InfoForm" "obj = fl_add_text(FL_NORMAL_TEXT,11,96,300,30,\"Charlie Gunn\");" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_InfoForm" "obj = fl_add_text(FL_NORMAL_TEXT,11,126,300,30,\"The Geometry Center\");" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_InfoForm" "InfoOKButton = obj = fl_add_button(FL_NORMAL_BUTTON,260,65,50,45,\"OK\");" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_callback(obj,InfoOKButtonProc,0);" ∷
  xformsCall "create_form_InfoForm" "obj = fl_add_text(FL_NORMAL_TEXT,11,172,300,30,\"Maniview and Geomview are \");" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_InfoForm" "obj = fl_add_text(FL_NORMAL_TEXT,10,190,300,30,\"available from\");" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_InfoForm" "obj = fl_add_text(FL_NORMAL_TEXT,12,208,300,30,\"www.geomview.org\");" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_InfoForm" "obj = fl_add_text(FL_NORMAL_TEXT,12,270,300,30,\"For usage instructions hit the ``Help'' button.\");" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_boxtype(obj,FL_NO_BOX);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_color(obj,FL_COL1,FL_COL1);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_InfoForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_InfoForm" "fl_end_form();" ∷
  xformsCall "create_form_LoadForm" "LoadForm = fl_bgn_form(FL_NO_BOX,470,200);" ∷
  xformsCall "create_form_LoadForm" "obj = fl_add_box(FL_UP_BOX,0,0,470,200,\"\");" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_LoadForm" "LoadInput = obj = fl_add_input(FL_NORMAL_INPUT,10,150,440,40,\"\");" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_color(obj,FL_INDIANRED,FL_INDIANRED);" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_LoadForm" "LoadOKButton = obj = fl_add_button(FL_RETURN_BUTTON,360,105,95,35,\"OK\");" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_callback(obj,LoadOKButtonProc,0);" ∷
  xformsCall "create_form_LoadForm" "LoadCancelButton = obj = fl_add_button(FL_NORMAL_BUTTON,250,105,100,35,\"Cancel\");" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_callback(obj,LoadCancelButtonProc,0);" ∷
  xformsCall "create_form_LoadForm" "obj = fl_add_box(FL_FRAME_BOX,205,10,160,40,\"Load Panel\");" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_color(obj,FL_WHITE,FL_COL1);" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_LoadForm" "obj = fl_add_box(FL_FRAME_BOX,30,20,160,30,\"LOAD TYPE:\");" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_LoadForm" "loadtypegroup = fl_bgn_group();" ∷
  xformsCall "create_form_LoadForm" "LoadGeomButton = obj = fl_add_button(FL_RADIO_BUTTON,30,80,160,30,\"Load Geom\");" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_callback(obj,LoadProc,LOAD_GEOM);" ∷
  xformsCall "create_form_LoadForm" "LoadCameraGeomButton = obj = fl_add_button(FL_RADIO_BUTTON,30,110,160,30,\"Load Camera Geom\");" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_callback(obj,LoadProc,LOAD_CAMGEOM);" ∷
  xformsCall "create_form_LoadForm" "LoadGroupButton = obj = fl_add_button(FL_RADIO_BUTTON,30,50,160,30,\"Load Group\");" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_callback(obj,LoadProc,LOAD_GROUP);" ∷
  xformsCall "create_form_LoadForm" "fl_end_group();" ∷
  xformsCall "create_form_LoadForm" "LoadShowBrowser = obj = fl_add_button(FL_NORMAL_BUTTON,250,60,205,35,\"Show Files\");" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_LoadForm" "fl_set_object_callback(obj,LoadShowBrowserProc,0);" ∷
  xformsCall "create_form_LoadForm" "fl_end_form();" ∷
  xformsCall "create_form_HelpForm" "HelpForm = fl_bgn_form(FL_NO_BOX,470,350);" ∷
  xformsCall "create_form_HelpForm" "obj = fl_add_box(FL_UP_BOX,0,0,470,350,\"\");" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_HelpForm" "obj = fl_add_text(FL_NORMAL_TEXT,20,20,200,40,\"Maniview Help\");" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_boxtype(obj,FL_FRAME_BOX);" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_color(obj,FL_WHITE,FL_COL1);" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lalign(obj,FL_ALIGN_CENTER|FL_ALIGN_INSIDE);" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_HelpForm" "HelpBrowser = obj = fl_add_browser(FL_NORMAL_BROWSER,10,70,450,270,\"\");" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_HelpForm" "HelpOKButton = obj = fl_add_button(FL_NORMAL_BUTTON,410,20,50,40,\"OK\");" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_HelpForm" "fl_set_object_callback(obj,HelpOKButtonProc,0);" ∷
  xformsCall "create_form_HelpForm" "fl_end_form();" ∷
  xformsCall "create_form_SaveForm" "SaveForm = fl_bgn_form(FL_NO_BOX,490,180);" ∷
  xformsCall "create_form_SaveForm" "obj = fl_add_box(FL_UP_BOX,0,0,490,180,\"\");" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_SaveForm" "SaveInput = obj = fl_add_input(FL_NORMAL_INPUT,30,120,440,40,\"\");" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_color(obj,FL_INDIANRED,FL_INDIANRED);" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_lsize(obj,FL_MEDIUM_SIZE);" ∷
  xformsCall "create_form_SaveForm" "SaveOKButton = obj = fl_add_button(FL_RETURN_BUTTON,360,75,95,35,\"OK\");" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_callback(obj,SaveOKButtonProc,0);" ∷
  xformsCall "create_form_SaveForm" "SaveCancelButton = obj = fl_add_button(FL_NORMAL_BUTTON,240,75,100,35,\"Cancel\");" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_callback(obj,SaveCancelButtonProc,0);" ∷
  xformsCall "create_form_SaveForm" "obj = fl_add_box(FL_FRAME_BOX,270,15,150,40,\"Save Panel\");" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_color(obj,FL_WHITE,FL_COL1);" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_lsize(obj,FL_LARGE_SIZE);" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_SaveForm" "obj = fl_add_box(FL_FRAME_BOX,40,20,110,30,\"Options:\");" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_SaveForm" "savetypegroup = fl_bgn_group();" ∷
  xformsCall "create_form_SaveForm" "SaveGeomButton = obj = fl_add_button(FL_RADIO_BUTTON,40,50,110,30,\"Save Geom\");" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_callback(obj,SaveGeomButtonProc,0);" ∷
  xformsCall "create_form_SaveForm" "SaveGroupButton = obj = fl_add_button(FL_RADIO_BUTTON,40,80,110,30,\"Save Matrices\");" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_lsize(obj,FL_NORMAL_SIZE);" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_lstyle(obj,FL_BOLD_STYLE);" ∷
  xformsCall "create_form_SaveForm" "fl_set_object_callback(obj,SaveGroupButtonProc,0);" ∷
  xformsCall "create_form_SaveForm" "fl_end_group();" ∷
  xformsCall "create_form_SaveForm" "fl_end_form();" ∷ []
