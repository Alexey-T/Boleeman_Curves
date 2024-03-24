unit dav7components;

{ 2 - 07 - 2014  added property: colormixer.showcolor }

interface

uses windows,extctrls,messages,controls,classes,graphics,forms;

{  dav7ELBox
   ---------
   add onEnter and onLeave events to a paintbox

   davArrayBtn
   ------------
   columns and rows of buttons, 0..47 maximal, for menu's and controls
   common properties:
   - button width,height
   - button edge 1..2 , borderwidth
   - shape: - flat, corners rounded
            - raised, 3D, sharp corners
   - colortable for alternate colors of edges/background

   per button:
   - button belongs to group 0..15
     only -1- button of a group can be down at the time
   - button operating mode
   - mom : released on mouse-up
   - press : user press down, released by other button
   - toggle: additional user 2 ND press Up action

   - button status:
   - hidden
   - flat    (inactive)
   - down    (activated)

   component:
   - paints edges and backgrounds
   - triggers onBtnPaint event if button foreground needs painting
   - triggers onBtnChange event when button pressed or released

   application:
   - paints foreground when triggered by event
   - responds to button pressed/released, Enter/Leave

   controlbyte per Button:
   bit 0..3 : group code 0..15
   bit 4,5 : action : 00:mom  01:press  10:toggle
   bit 6,7 : status : 00:hidden  01:flat  10:down

   dav7ColorMixer
   ---------------
   simple color mixer component for use on custom dialog form

   mix r,g,b selection
   property : - color
              - history
              - showcolor
   methods  : - create
              - updatehistory
   events   : - OnSelect : mouse-move or mouse-down
                           over a color slide supplies selected color

   dav7ColorPicker
   ---------------
   supply rectangle with selectable colors

   properties:

   - direction : cbHor, cbVert for horizontal or vertical orientation
   - colordepth : cb8, cb64 , cb512 for amount of colors
   - Csquare : 5 .. 40, edge of each colored square
   - border : 0..10 , the width of the border
   - borderlight : color of left and top of border
   - borderdark : color of bottom and right side of border

   methods:
   - create
   events:
   - OnSelect : mouse-up over a color supplies selected color
   properties:
   - direction   : TColorBoxdir =  cbHor,cbVert
   - colorDepth  : TColorDepth  =  cb8,cb64,cb512
   - csquare     : byte                             dimension of colorsquare
   - border      : byte;
   - borderlight : longInt;
   - borderdark  : longInt;
   - palette     : PColorByteTable;                 array[0..7] of byte
                                                    color conversion per color
}

const davmaxBtn = 48;//buttons 0..47; btn 48 = no button

//----ELBox

type Tdav7ELBox = class(TPaintbox)
     private
      FonEnter : TNotifyEvent;
      FonLeave : TNotifyEvent;
      procedure CMmouseEnter(var message : Tmessage); message CM_MOUSEENTER;
      procedure CMmouseLeave(var message : Tmessage); message CM_MOUSELEAVE;
     published
      property onEnter : TNotifyEvent read FonEnter write FonEnter;
      property onLeave : TNotifyEvent read FonLeave write FonLeave;
     end;

//-- arrayBtn

     TBtnShape = (bsFlat,bs3D);
     TBtnStatus = (stHidden,stFlat,stDown,stHI);
     TBtnOpmode = (omMom,omPress,omToggle);
     TBtnColorIndex = (bcInactBG,bcActiveBG,bcFlat,bcHI,bcLO);
     TBtnChangeProc = procedure(sender : TObject; BtnNr : byte;
                      status : TBtnStatus; button : TmouseButton) of object;
     TBtnPaintProc = procedure(sender : TObject; BtnNr : byte;
                               status : TBtnStatus) of object;
     TColorTable = array[bcInactBG..bcLO] of LongInt;
     TPColorTable = ^TColorTable;

     TDavArrayBtn = class(TGraphicControl)
     private
      FonBtnchange : TBtnChangeProc;
      FonBtnPaint : TBtnPaintProc;
      FonEnter : TNotifyEvent;
      FonLeave : TNotifyEvent;
      FHiBtn : byte;            //mouse over this button
      Frows : byte;             //rows
      Fcolumns : byte;          //columns
      FbtnWidth : byte;         //button width
      FbtnHeight : byte;        //button height
      FBtnEdge : byte;          //button edge
      FBtnSpacing : byte;       //space between buttons
      FBorder : byte;           //border
      FBtnShape : TBtnShape;    //rounded flat, 3D
      FPcolorTable : TPColorTable;
      FBtnControl : array[0..davmaxBtn] of byte;
      FNextRelease : byte;
      procedure setRows(n : byte);
      procedure setColumns(n : byte);
      procedure setBtnWidth(n : byte);
      procedure setBtnHeight(n : byte);
      procedure setBtnshape(bs : TBtnShape);
      procedure setBorder(b : byte);
      procedure setSpacing(b : byte);
      procedure setBtnEdge(edge : byte);
      procedure repaintBtns;
      procedure fixdimensions;
      procedure BtnPaint(BtnNr : byte; bst : TBtnStatus);
      procedure CMmouseLeave(var message : Tmessage); message CM_MOUSELEAVE;
      procedure CMmouseEnter(var message : Tmessage); message CM_MOUSEENTER;
      procedure InitBtns;
      procedure SetBtnStatus(BtnNr : byte; status : TBtnStatus);
      function GetBtnGroup(BtnNr : byte) : byte;
      function GetBtnOpMode(BtnNr : byte) : TBtnOpMode;
     protected
      procedure paint; override;
      procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
                          X, Y: Integer); override;
      procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
                        X, Y: Integer); override;
      procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
      procedure AssignColorTable(p : TPcolorTable);
      procedure TestReleaseBtn(downBtn : byte);
     public
      constructor Create(AOwner: TComponent); override;
      function GetBtnRect(btnNr : byte) : TRect;
      function GetBtnStatus(btnNr : byte) : TBtnStatus;
      procedure setBtnOpmode(BtnNr : byte; opMode: TBtnOpmode);
      procedure BtnHide(btnNr : byte);
      procedure BtnShow(btnNr : byte);
      procedure BtnDown(btnNr : byte);
      procedure BtnRelease(btnNr : byte);
      procedure setBtnGroup(btnNr,group : byte);
      property canvas;
      property PColorTable : TPColorTable read FPColorTable
               write AssignColorTable;
     published
      property Border : byte read FBorder write setBorder;
      property BtnHeight : byte read FBtnHeight write setBtnHeight;
      property BtnSpacing : byte read FBtnSpacing write setSpacing;
      property BtnShape : TBtnShape read FBtnShape write setBtnShape;
      property BtnWidth : byte read FBtnWidth write setbtnwidth;
      property BtnEdge : byte read FBtnEdge write SetBtnEdge;
      property Color;
      property Columns : byte read Fcolumns write setcolumns;
      property Enabled;
      property Font;
      property onBtnChange : TBtnChangeProc read FonBtnChange write FonBtnChange;
      property onBtnPaint : TBtnPaintProc read FonBtnPaint write FonBtnPaint;
      property OnEnter : TNotifyEvent read FOnEnter write FOnEnter;
      property OnLeave : TNotifyEvent read FonLeave write FOnLeave;
      property Rows : byte read Frows write setRows;
      property Visible;
     end;

//-- colormixer

     TColorSelect = procedure(sender : TObject; color : LongInt) of object;

     Tdav7Colormixer = class(TGraphicControl)
     private
       Fred        : byte;    //0..63  color code cc
       Fgreen      : byte;
       Fblue       : byte;
       FColor      : longInt;
       FOnSelect   : TColorSelect;
       FHistory    : boolean;
       FShowcolor  : boolean;
       Fcolors     : array[1..9] of longInt;//history colors[1..8],[9] = new
       Fcolorcount : byte;
       FChanged    : boolean;
       procedure sethistory(b : boolean);
       procedure setShowColor(b : boolean);
     protected
       procedure paint; override;
       procedure mousemove(Shift : Tshiftstate; x,y : integer); override;
       procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
                           X, Y: Integer); override;
       procedure selColor(color : LongInt);
       procedure clearSlide(nr : byte);
       procedure setslide(nr : byte);
       procedure packRGB;
       procedure change(x,y : integer);
       procedure painthistory;
       procedure paintShowcolor;
     public
       constructor create(AOwner:TComponent); override;
       property color : longInt read FColor write selcolor;
       procedure updatehistory;
     published
       property OnSelect : TcolorSelect read FOnSelect write FOnSelect;
       property history : boolean read FHistory write sethistory;
       property showcolor : boolean read FShowcolor write setShowColor;
       property visible;
       property enabled;
  end;

//---- colorpicker

     TcolorDepth = (cb8,cb64,cb512);
     Tcolorboxdir = (cbHor,cbVert);
     TColorSquare = record
                     x1 : integer;
                     y1 : integer;
                  color : LongInt;
                    end;
     TcolorBytetable = array[0..7] of byte;
     PcolorByteTable = ^Tcolorbytetable;
     Tdav7ColorPicker = class(TGraphicControl)
     private
       FColorDepth : TColorDepth;
       FDirection  : Tcolorboxdir;
       FColor      : LongInt;
       FOnSelect   : TColorSelect;
       FBorderwidth: byte;
       FBorderlight: LongInt;
       FBorderdark : LongInt;
       FCsquare : byte;
       FPalette : PColorByteTable;
       FInternalPalette : boolean;
       procedure setDirection(cbDir : TcolorBoxdir);
       procedure setColorDepth(cbDepth : TColorDepth);
       procedure setDimensions;
       function number2color(w : word) : TColorSquare;
       procedure defpalette(p : PcolorByteTable);
     protected
       procedure paint; override;
       procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
                         X, Y: Integer); override;
       procedure setSquare(edge : byte);
       procedure setBorderwidth(w : byte);
       procedure setBorderlight(c : longInt);
       procedure setBorderdark(c : longInt);
       procedure select(sender : TObject; selcolor : LongInt);
     public
       constructor create(AOwner:TComponent); override;
       property palette : PcolorByteTable write defpalette;
     published
       property OnSelect : TcolorSelect read FOnSelect write FOnSelect;
       property direction: TColorboxdir read FDirection write setDirection;
       property colordepth: Tcolordepth read Fcolordepth write setcolordepth;
       property Csquare : byte read FCsquare write setSquare;
       property border : byte read Fborderwidth write setborderwidth;
       property borderlight : longInt read Fborderlight write setborderLight;
       property borderdark  : LongInt read Fborderdark write setBorderdark;
       property visible;
       property enabled;
  end;

procedure Register;

implementation

const defaultColors : TColorTable = ($c0c0c0,$f0f0f0,$808080,$ffffff,$202020);

      palette8   : Tcolorbytetable = ($00,$ff,$00,$00,$00,$00,$00,$00);
      palette64  : TcolorbyteTable = ($00,$70,$d0,$ff,$00,$00,$00,$00);
      palette512 : Tcolorbytetable = ($00,$50,$80,$a0,$c0,$d8,$f0,$ff);

procedure Register;
begin
 RegisterComponents('system',[TdavArrayBtn]);
 RegisterComponents('system',[TDav7ELbox]);
 RegisterComponents('system',[TDav7ColorMixer]);
 RegisterComponents('system',[TDav7ColorPicker]);
end;

//---------------ELbox

procedure Tdav7ELBox.CMMouseEnter(var Message: TMessage);
begin
 if assigned(onEnter) then OnEnter(self);
end;

procedure Tdav7ELBox.CMMouseLeave(var Message: TMessage);
begin
 if assigned(onLeave) then onLeave(self);
end;

//-----------------davArrayBtn

procedure TdavArrayBtn.SetBtnOpMode(BtnNr : byte; Opmode : TBtnOpMode);
var cb : byte;
begin
 cb := FBtnControl[BtnNr] and $cf;
 FBtnControl[BtnNr] := cb or (byte(OpMode) shl 4);
end;

function TdavArrayBtn.GetBtnOpMode(BtnNr : byte) : TbtnOpMode;
begin
 result := TBtnOpMode((FBtnControl[BtnNr] shr 4) and $3);
end;

procedure TdavArrayBtn.setBtnStatus(BtnNr : byte; status : TBtnStatus);
var bc : byte;
begin
 bc := FBtnControl[BtnNr] and $3f;
 FBtnControl[BtnNr] := bc or (byte(status) shl 6);
end;

function TdavArrayBtn.GetBtnGroup(BtnNr : byte) : byte;
begin
 result := FBtnControl[BtnNr] and $f;
end;

procedure TdavArrayBtn.setBtnGroup(btnNr,group : byte);
//add button to group
var bc : byte;
begin
 bc := FBtnControl[BtnNr] and $f0;
 FBtnControl[BtnNr] := bc or group;
end;

procedure TdavArrayBtn.initBtns;
//alle buttons group -0-, press
var i,top : byte;
    control : byte;
begin
 top := FRows*Fcolumns-1;
 control := (byte(stFlat) shl 6) or (byte(omPress) shl 4);
 for i := 0 to davmaxBtn do
  if i <= top then FBtnControl[i] := control
   else FBtnControl[i] := 0;
end;

function TdavarrayBtn.GetBtnStatus(btnNr : byte) : TBtnStatus;
begin
 result := TBtnStatus((FBtnControl[btnNr] shr 6) and $3);
end;

procedure TdavArrayBtn.BtnHide(btnNr : byte);
//hide button
begin
 if GetBtnStatus(btnNr) <> stHidden then
  begin
   SetBtnStatus(btnNr,stHidden);
   if FHiBtn = btnNr then FHiBtn := davmaxBtn;
   BtnPaint(btnNr,stHidden);
  end;
end;

procedure TdavarrayBtn.BtnShow(btnNr : byte);
//show a hidden button, set flat
begin
 if GetBtnStatus(btnNr) = stHidden then
  begin
   SetBtnStatus(btnNr,stFlat);
   BtnPaint(BtnNr,stFlat);
  end;
end;

procedure TdavArrayBtn.BtnRelease(btnNr : byte);
//set button from DOWN to Flat
begin
 if GetBtnStatus(btnNr) = stDown then
  begin
   SetBtnStatus(btnNr,stFlat);
   BtnPaint(btnNr,stFlat);
  end;
end;

procedure TdavArrayBtn.BtnDown(btnNr : byte);
begin
 if GetBtnStatus(btnNr) = stFlat then
  begin
   SetBtnStatus(btnNr,stDown);
   BtnPaint(btnNr,stDown);
   TestReleaseBtn(btnNr);//to release other buttons
  end;
end;

procedure TdavArrayBtn.TestReleaseBtn(downBtn : byte);
//downBtn was pressed down, test to release buttons of same group
var groupNr,i : byte;
begin
 groupNr := GetBtnGroup(downBtn);
 for i := 0 to Frows*Fcolumns-1 do
  if (i <> downBtn) and (GetBtnGroup(i) = groupNr)
                    and (GetBtnStatus(i)  = stDown) then
   begin
    SetBtnStatus(i,stFlat);
    btnPaint(i,stFlat);
   end;
end;

procedure TdavArrayBtn.BtnPaint(btnNr : byte; bst : TBtnStatus);
//if button hidden: erase
var r : Trect;
    radius : byte;
    k1,k2 : LongInt;
    i : byte;
begin
 k1 := 0; k2 := 0;
 r := GetBtnRect(btnNr);
 with canvas do
  begin
   pen.Width := 1;
   brush.style := bssolid;
    case bst of
     stHidden  : begin
                  brush.color := color;
                  brush.style := bsSolid;
                  fillrect(r);
                  exit;
                 end;
     stFlat    : begin
                  brush.color := PColorTable^[bcInactBG];
                  k1 := PColorTable^[bcFlat]; k2 := k1;
                 end;
     stHI      : begin
                  brush.color := PColorTable^[bcInactBG];
                  k1 := PColorTable^[bcHI]; k2 := PColorTable^[bcLO];
                 end;
     stDown    : begin
                  brush.color := PColorTable^[bcActiveBG];
                  k1 := PColorTable^[bcLO]; k2 := PColorTable^[bcHI];
                 end;
    end;//case
    if FBtnShape = bsFlat then    //vlak,ronde hoeken
     begin
      radius := FBtnHeight div 2;
      if radius > 40 then radius := 40;
      if radius < 10 then radius := 10;
      pen.Width := FbtnEdge;
      pen.color := k1;
      roundrect(r.left+1,r.top+1,r.right,r.bottom,radius,radius);
     end
    else
     begin
      fillrect(r);
      for i := 0 to FbtnEdge-1 do
       begin
        pen.color := k1;
        moveto(r.right-1-i,r.top+i);
        lineto(r.left+i,r.top+i);
        lineto(r.left+i,r.bottom-1-i);
        pen.color := k2;
        lineto(r.right-1-i,r.bottom-1-i);
        lineto(r.right-1-i,r.top+i);
       end;//for
     end;//else
  end;//with canvas
  if not (csDesigning in componentstate) and assigned(onBtnPaint) then
   onBtnPaint(self,btnNr,bst);
end;

procedure TdavArrayBtn.RepaintBtns;
//na initialiseren hele paintbox
var i : byte;
begin
 for i := 0 to FRows*Fcolumns-1 do BtnPaint(i,GetBtnStatus(i));
end;

procedure TdavArrayBtn.FixDimensions;
//adjust width,height na verandering van knop of spacing
//generates onPaint event
begin
 if FRows = 0 then FRows := 1;
 if FColumns = 0 then FColumns := 1;
 width := FColumns*(FBtnWidth + FBtnSpacing) - FBtnSpacing + 2*Fborder;
 height := FRows*(FBtnHeight + FBtnspacing) - FBtnSpacing + 2*Fborder;
end;

constructor TdavArrayBtn.Create(AOwner: TComponent);
begin
 inherited create(Aowner);
 canvas.font := font;
 FHiBtn := davmaxBtn;//=off
 FBtnShape := bs3D;
 FbtnEdge := 1;
 FPColorTable := @defaultColors;
 Frows := 2;
 Fcolumns := 2;
 InitBtns;
 FbtnWidth := 40;
 FbtnHeight := 30;
 FBtnSpacing := 5;
 FBorder := 10;
 fixDimensions;//set width , height
end;

procedure TdavArrayBtn.AssignColorTable(p : TPcolorTable);
begin
 FPcolorTable := p;
 invalidate;
end;

procedure TdavArrayBtn.MouseDown(Button: TMouseButton; Shift: TShiftState;
                    X, Y: Integer);
var status : TBtnStatus;
begin
 FNextRelease := davmaxBtn;
 if (FHiBtn = davmaxBtn) then exit; //no button selected
//----
 status := GetBtnstatus(FHIbtn);
 if status = stFlat then
  begin
   SetBtnStatus(FHIbtn,stDown);
   BtnPaint(FHIbtn,stDown);
   TestReleaseBtn(FHIbtn);
   if assigned(FonBtnChange) and (not (csDesigning in componentstate)) then
    onBtnChange(self,FHiBtn,stDown,button);
  end;
 case GetBtnOpMode(FHIbtn) of
  omMom    : FNextRelease := FHIbtn;
  omToggle : if status = stDown then FNextrelease := FHIbtn;
 end;//case
end;

procedure TdavArrayBtn.MouseUp(Button: TMouseButton; Shift: TShiftState;
                        X, Y: Integer);
begin
 if FNextRelease <> davmaxBtn then
  begin
   SetBtnStatus(FNextRelease,stFlat);
   BtnPaint(FNextRelease,stFlat);
   if (not (csDesigning in componentstate)) and assigned(FonBtnChange) then
      onBtnChange(self,FNextRelease,stFlat,button);
  end;
end;

procedure TdavArrayBtn.MouseMove(Shift: TShiftState; X, Y: Integer);
var dx,maxX,maxY,dy : integer;
    button : byte;
    px,py : integer;
    status : TBtnStatus;
begin
 x := x - FBorder; y := y - FBorder;
 dx := FBtnSpacing + FBtnWidth;
 dy := FBtnSpacing + FBtnHeight;
 maxX := FColumns * dx; maxY := FRows * dy;
 px := x mod dx; py := y mod dy;
 if (x < maxX) and (y < maxY) and
    (px > FBtnEdge) and (px < dx-FBtnEdge-FBtnSpacing) and
    (py > FBtnEdge) and (py < dy-FBtnEdge-FBtnSpacing) then
  begin
   button := x div dx + FColumns*(y div dy);
  end
 else button := davmaxBtn;
 status := GetBtnStatus(button);
 if (status = stHidden) then button := davmaxBtn;
 if button = FHiBtn then exit;//if no change

//---process Btn change
 if button <> davmaxBtn then cursor := crhandpoint
  else cursor := crArrow;

 if (FHIbtn <> davmaxBtn) and (GetBtnStatus(FHIbtn) <> stDown) then
     BtnPaint(FHIbtn,stFlat);//remove HI edge
 if (button <> davmaxBtn) and (GetBtnStatus(button) <> stDown) then
     BtnPaint(button,stHI);//paint HI
 FHIbtn := button;
end;

procedure TdavarrayBtn.Paint;
//teken de paintbox
//teken alle buttons
var i : byte;
    k1,k2 : LongInt;
begin
 FHiBtn := davmaxBtn;
  with canvas do
   begin
    brush.color := color;
    pen.Width := 1;
    pen.color := PcolorTable^[bcFlat];
    fillrect(rect(0,0,width,height));
    if FBorder > 0 then
     begin
      if FBtnShape = bs3D then
       begin
        k1 := PcolorTable^[bcHI]; k2 := PcolorTable^[bcFlat];
       end
      else begin
            k1 := Pcolortable^[bcFlat]; k2 := k1;
           end;
      pen.color := k1;
      moveto(width-1,0);
      lineto(0,0); lineto(0,height-1);
      pen.color := k2;
      lineto(width-1,height-1); lineto(width-1,0);
    end;//if border
   end;//with
 for i := 0 to FColumns*Frows-1 do
  if GetBtnStatus(i) <> stHidden then Btnpaint(i,GetBtnStatus(i));
end;

function TdavArrayBtn.GetBtnRect(btnNr : byte) : TRect;
//geef rectangle waarin button getekend moet worden
var x,y : integer;
begin
 x := btnNr mod Fcolumns;
 y := btnNr div FColumns;
 with result do
  begin
   left := Fborder + (FBtnWidth + FBtnspacing)*x;
   right := left + FBtnWidth;
   top := Fborder + (FBtnHeight + FBtnspacing)*y;
   bottom := top + FbtnHeight;
  end;
end;

procedure TdavArrayBtn.setRows(n : byte);
begin
 if n = 0 then n := 1;
 if n > davmaxBtn then n := davmaxBtn;
 if n * Fcolumns > davMaxBtn then Fcolumns := 1;
 Frows := n;
 initBtns;
 FixDimensions;
end;

procedure TdavArrayBtn.setColumns(n : byte);
begin
 if n = 0 then n := 1;
 if n > davMaxBtn then n := davMaxbtn;
 if n * Frows > davMaxBtn then Frows := 1;
 Fcolumns := n;
 initBtns;
 FixDimensions;
end;

procedure TdavArrayBtn.setBtnWidth(n : byte);
begin
 if n < 10 then n := 10;
 FBtnWidth := n;
 FixDimensions;
end;

procedure TdavarrayBtn.setBtnHeight(n : byte);
begin
 if n < 10 then n := 10;
 FBtnHeight := n;
 FixDimensions;
end;

procedure TdavArrayBtn.setBtnShape(bs : TBtnShape);
begin
 FBtnShape := bs;
 invalidate;
end;

procedure TdavArrayBtn.setBtnEdge(edge : byte);
begin
 if edge = 0 then edge := 1
  else if edge > 2 then edge := 2;
 FBtnEdge := edge;
 repaintBtns;
end;

procedure TdavArrayBtn.setBorder(b : byte);
begin
 Fborder := b;
 FixDimensions;
end;

procedure TdavarrayBtn.setSpacing(b : byte);
begin
 FBtnSpacing := b;
 FixDimensions;
end;

procedure TdavArrayBtn.CMmouseLeave(var message : Tmessage);
begin
 if (FHiBtn <> davmaxbtn) then
  begin
   if GetBtnStatus(FHIbtn) <> stDown then BtnPaint(FHIbtn,stFlat);
   FHIbtn := davMaxBtn;
  end;
 if not (csDesigning in componentstate) and assigned(FOnLeave) then
    onLeave(self);
end;

procedure TdavarrayBtn.CMmouseEnter(var message : Tmessage);
begin
 if not (csDesigning in componentstate) and assigned(FOnEnter) then
    onEnter(self);
end;

//-----------dav7Colormixer

function y2color(y,nr : byte) : longInt;
//convert y slide top position to color
begin
 result := ((y shl 1) and $fc) shl ((nr-1) shl 3);
end;

procedure TDav7ColorMixer.sethistory(b : boolean);
//set,clear history
begin
 FHistory := b;
 Fcolorcount := 0;
 if FHistory then width := 170 else width := 120;
end;

procedure TDav7ColorMixer.setShowcolor(b : boolean);
begin
 FShowcolor := b;
 if FShowcolor then height := 180 else height := 140;
end;

procedure Tdav7ColorMixer.packRGB;
//make Fcolor from Fred,Fgreen,Fblue
begin
 Fcolor := (Fred shl 2);
 Fcolor := Fcolor or (Fgreen shl 10);
 Fcolor := Fcolor or (Fblue shl 18);
end;

constructor Tdav7Colormixer.create(AOwner: TComponent);
var i : byte;
begin
 inherited create(Aowner);
 Fred := 0;
 Fgreen := 0;
 Fblue := 0;
 Fcolor := $0;
 width := 120;
 height := 140;
 FHistory := false;
 FShowcolor := false;
 for i := 1 to 9 do FColors[i] := 0;
 Fcolorcount := 0;
 Fchanged := false;
end;

procedure TDav7ColorMixer.selcolor(color : LongInt);
//external call sets color of mixer
const msk = $3f;
var i : byte;
begin
 if (enabled = false) then exit;

 Fcolor := color;
 for i := 1 to 3 do
  begin
   if visible then clearslide(i);
   case i of
    1 : Fred := (color shr 2) and msk;
    2 : Fgreen := (color shr 10) and msk;
    3 : Fblue := (color shr 18) and msk;
   end;
   if visible then
    begin
     setslide(i);
     if FShowcolor then paintShowcolor;
    end; 
  end;
end;

procedure TDav7ColorMixer.clearSlide(nr : byte);
//erase slide nr
var x,y1,y2 : byte;
    i,cc : byte;
begin
 with self do with canvas do
  begin
   brush.color := getparentform(self).color;
   x := (nr - 1)*40;
   cc := 0;
   case nr of
    1 : cc := Fred;
    2 : cc := Fgreen;
    3 : cc := Fblue;
   end;
   y1 := cc shl 1;
   y2 := y1 + 11;
   pen.Width := 1;
   pen.Color := 0;
   brush.style := bsSolid;
   fillrect(rect(x,y1,x+40,y2));
   if y1 < 5 then y1 := 5;
   if y2 > 133 then y2 := 134;
   moveto(x+10,y1);
   lineto(x+10,y2);
   moveto(x+30,y1);
   lineto(x+30,y2);
   for i := 0 to 11 do
    if (y1+i >= 5) and (y1+i <= 133) then
     begin
      if y1 + i = 133 then pen.Color := 0
       else pen.Color := y2color(y1+i-5,nr);
      moveto(x+11,y1+i);
      lineto(x+30,y1+i);
    end;//for i
  end;//with
end;

procedure Tdav7ColorMixer.setslide(nr : byte);
//set slide nr acc. to bc
var x,y : byte;
    i,cc : byte;
begin
 cc := 0;
 case nr of
  1 : cc := Fred;
  2 : cc := Fgreen;
  3 : cc := Fblue;
 end;
 x := (nr-1)*40;
 y := cc shl 1;
 with self do with canvas do
  begin
   brush.style := bsClear;
   pen.width := 1;
   pen.color := 0;
   rectangle(x+4,y,x+37,y+11);
   for i := 0 to 5 do
    begin
     moveto(x+4+i,y+i);
     lineto(x+4+i,y+11-i);
    end;
   x := x+36;
   for i := 0 to 5 do
    begin
     moveto(x-i,y+i);
     lineto(x-i,y+11-i);
    end;
  end;
end;

procedure TDav7ColorMixer.paintShowcolor;
begin
 with self do with canvas do
  begin
   pen.color := $000000;
   pen.width := 1;
   brush.color := Fcolor;
   brush.Style := bsSolid;
   rectangle(0,145,119,179);
  end;
end;

procedure TDav7ColorMixer.painthistory;
var i : byte;
    y : word;
begin
 with self do
  with canvas do
   begin
    for i := 0 to 1 do
     begin
      pen.Color := $000000;
      moveto(width-1-i,i);
      lineto(130+i,i);
      lineto(130+i,138-i);
      pen.Color := $808080;
      lineto(width-1-i,138-i);
      lineto(width-1-i,i);
     end;
    pen.color := $000000;
    for i := 1 to 8 do
     begin
      y := 2 + (i-1)* 17;
      if i <= Fcolorcount then
       begin
        brush.Color := Fcolors[i];
        fillrect(rect(132,y,168,y+16));
       end;
      y := y + 16;
      if i < 8 then
       begin
        moveto(132,y);
        lineto(168,y);
       end;
     end;//for i
   end;//with canvas
end;

procedure Tdav7Colormixer.Paint;
var i,j,x1,x2,y,k : byte;
begin
 with self do
  with canvas do
   begin
    brush.color := getparentform(self).color;
    pen.color := $000000;
    pen.Width := 1;
    brush.style := bsSolid;
    fillrect(rect(0,0,width,height));
    brush.Style := bsClear;
    for i := 0 to 2 do
     begin
      x1 := 10+40*i;
      x2 := x1+21;
      for j := 0 to 63 do
       begin
        y := 5 + 2*j;
        pen.color := y2color(y-5,i+1);
        for k := 0 to 1 do
         begin
          moveto(x1,y+k);
          lineto(x2,y+k);
         end;//for k
       end;
      pen.color := $0;
      rectangle(x1,5,x2,133);
      setslide(i+1);
     end;//for i
    if Fhistory then  painthistory;
    if FShowcolor then paintShowcolor;
   end;//with canvas
end;

procedure Tdav7ColorMixer.change(x,y: integer);
//process change
var modx,slide : byte;
    proc : boolean;
begin
 if (x > 0) and (x < 120) and (y > 0) and (y < 133) then
  begin
   modx := x mod 40;
   if (modx > 5) and (modx < 35) then
    begin
     slide := x div 40 + 1;
     y := (y - 5);
     if y < 0 then y := 0
      else y := y shr 1;
     proc := false;
     case slide of
      1 : proc := Fred <> y;
      2 : proc := Fgreen <> y;
      3 : proc := Fblue <> y;
     end;
     if proc then
      begin
       clearslide(slide);
       case slide of
        1 : Fred := y;
        2 : Fgreen := y;
        3 : Fblue := y;
       end;
       setslide(slide);
       packRGB;
       if FShowcolor then paintShowcolor;
       if componentstate * [csDesigning] = [] then
        if assigned(FOnSelect) then
         begin
          FonSelect(self,Fcolor);
          Fchanged := true;
         end;
      end;//if proc
    end;//if modx
  end;//if x > 0
end;

procedure Tdav7colormixer.updatehistory;
//update color history , Fcolor is "new" color
var i,k : byte;
    hit: boolean;
begin
 if Fhistory = false then exit;
//
 i := 1;
 hit := false;
 while (hit = false) and (i <= Fcolorcount) do
  if Fcolor = Fcolors[i] then hit := true else inc(i);
 if hit = false then inc(Fcolorcount);
 for k := i downto 2 do Fcolors[k] := Fcolors[k-1];
 Fcolors[1] := Fcolor;
 if Fcolorcount > 8 then Fcolorcount := 8;
 painthistory;
end;

procedure Tdav7colormixer.MouseDown(Button: TMouseButton; Shift: TShiftState;
                                    X, Y: Integer);
var ym17,yd17 : byte;
begin
 if x < 120 then change(x,y);
 if (x > 130) and (x < 170) then
  begin
   ym17 := (y - 2) mod 17;
   yd17 := (y - 2) div 17;
   if (ym17 > 2) and (ym17 < 15) then
    if yd17 < Fcolorcount then
     begin
      selcolor(Fcolors[yd17+1]);
      if componentstate * [csDesigning] = [] then
       if assigned(FOnSelect) then
        begin
         FonSelect(self,FColor);
         Fchanged := true;
        end;
     end;
  end;
end;  

procedure Tdav7ColorMixer.mousemove(Shift : Tshiftstate; x,y : integer);
begin
 if shift = [] then exit;
 if x < 120 then change(x,y);
end;

//---------------dav7colorpicker

procedure Tdav7ColorPicker.defpalette(p : PcolorByteTable);
begin
 if assigned(p) then
  begin
   Fpalette := p;
   Finternalpalette := false;
  end
 else
  begin
   FInternalpalette := true;
   case colorDepth of
    cb8   : Fpalette := @palette8;
    cb64  : Fpalette := @palette64;
    cb512 : Fpalette := @palette512;
   end;
  end;
 paint;
end;

procedure Tdav7ColorPicker.setDimensions;
const dimlist : array[cb8..cb512] of byte = (2,4,8);
var xx,yy : integer;
begin
 yy := dimlist[FcolorDepth]*FCsquare;
 xx := yy * dimlist[FColorDepth] + 2*border + 1;
 yy := yy + 2*border + 1;
 if Fdirection = cbHor then
  begin
   width := xx; height := yy;
  end
  else
   begin
    height := xx; width := yy;
   end;
end;

constructor Tdav7ColorPicker.create(AOwner: TComponent);
begin
 inherited create(Aowner);
 FCSquare := 10;
 FBorderwidth := 4;
 FColorDepth := cb512;
 FDirection := cbHor;
 FBorderLight := $ffffff;
 FBorderdark := $0;
 FColor := $0;
 setdimensions;
 Fpalette := @palette512;   //use internal palette
 FInternalpalette := true;
end;

procedure Tdav7ColorPicker.setdirection(cbdir : Tcolorboxdir);
begin
 Fdirection := cbdir;
 setdimensions;
end;

procedure Tdav7ColorPicker.setColorDepth(cbdepth : TColorDepth);
begin
 FColorDepth := cbdepth;
 if Finternalpalette then
  case Fcolordepth of
   cb8   : Fpalette := @palette8;
   cb64  : Fpalette := @palette64;
   cb512 : Fpalette := @palette512;
  end;
 setSquare(FCSquare);
 setdimensions;
end;

function Tdav7ColorPicker.number2color(w : word) : TColorSquare;
var r,g,b : byte;
begin
 r := 0; g := 0; b:= 0;
 case FColorDepth of
       cb8   : begin
                r := w and $1;
                g := (w shr 1) and 1;
                b := (w shr 2) and $1;
                result.x1 := border + (r + 2*g) * FCSquare;
                result.y1 := border + b * FCSquare;
               end;
       cb64  : begin
                r := (w and $3);
                g := (w shr 2) and $3;
                b := (w shr 4) and $3;
                result.x1 := border + (r + 4*g) * FCSquare;
                result.y1 := border + b * FCSquare;
               end;
       cb512 : begin
                r := (w and $7);
                g := (w shr 3) and $7;
                b := (w shr 6) and $7;
                result.x1 := border + (r + 8*g) * FCSquare;
                result.y1 := border + b * FCSquare;
               end;
      end;//case
 r := Fpalette^[r];
 g := Fpalette^[g];
 b := Fpalette^[b];
 result.color := RGB(r,g,b);
end;

procedure Tdav7ColorPicker.Paint;
const Cmaxcolor : array[cb8..cb512] of word = (7,63,511);
var h,i,x1,y1 : integer;
    cs : TColorSquare;
begin
 with self do
  with canvas do
   begin
    pen.color := $0;
    pen.width := 1;
    for i := 0 to border-1 do                  //borderpaint
     begin
      pen.color := Fborderlight;
      moveto(width-1-i,i);
      lineto(i,i);
      lineto(i,height-1-i);
      pen.color := FborderDark;
      lineto(width-1-i,height-1-i);
      lineto(width-1-i,i);
     end;
//--
    for i := 0 to Cmaxcolor[FColorDepth] do
     begin
      cs := number2color(i);
      if FDirection = cbVert then     //trade x,y positions for vertical
       begin
        h := cs.x1; cs.x1 := cs.y1; cs.y1 := h;
       end;
      brush.color := cs.color;
      fillrect(rect(cs.x1,cs.y1,cs.x1+FCSquare,cs.y1+FCSquare));
     end;//for i
//--     
    pen.color := $0;
    for i := 0 to ((width-2*border) div FCSquare) do //sep. lines
     begin
      x1 := border + i * FCSquare;
      moveto(x1,border);
      lineto(x1,height - border);
     end;
    for i := 0 to ((height-2*border) div FCSquare) do
     begin
      y1 := border+ i * FCSquare;
      moveto(border,y1);
      lineto(width-border,y1);
     end;
   end;
end;

procedure Tdav7ColorPicker.MouseUp(Button: TMouseButton; Shift: TShiftState;
                          X, Y: Integer);
var h,v,temp : byte;
    colornumber : word;
begin
 if (x > Fborderwidth) and (x < width-Fborderwidth-1)
    and (y > Fborderwidth) and (y < height-Fborderwidth-1) then
  begin
   h := (x - Fborderwidth) div FCsquare;
   v := (y - Fborderwidth) div FCSquare;
  end
 else exit;
//--
 if FDirection = cbVert then
  begin
   temp := h; h := v; v:= temp;
  end;
 case FColorDepth of
  cb8 : colornumber := h + v * 4;
  cb64 : colornumber := h + v * 16;
  cb512 : colornumber := h + v * 64;
  else colornumber := 0;
 end;
 Fcolor := number2color(colornumber).color;
 if assigned(FOnSelect) then FonSelect(self,FColor);
end;

procedure Tdav7ColorPicker.Select(sender : TObject; selcolor : LongInt);
begin
 if assigned(FOnSelect) then FonSelect(self,Fcolor);
end;

procedure Tdav7ColorPicker.setSquare(edge : byte);
begin
 case FColorDepth of
  cb8   : if edge > 40 then edge := 40;
  cb64  : if edge > 20 then edge := 20;
  cb512 : if edge > 10 then edge := 10;
 end;
 if edge < 5 then edge := 5; 
 FCSquare := edge;
 setdimensions;
end;

procedure Tdav7ColorPicker.setBorderwidth(w : byte);
begin
 if w > 10 then w := 10;
 FBorderwidth := w;
 setdimensions;
end;

procedure Tdav7ColorPicker.setBorderlight(c : longInt);
begin
 FBorderlight := c;
 paint;
end;

procedure Tdav7ColorPicker.setBorderdark(c : longInt);
begin
 FBorderdark := c;
 paint;
end;

end.

