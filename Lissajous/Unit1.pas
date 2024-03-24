unit Unit1;

{$MODE Delphi}

{
   painting of Lissajous 3D figures
   menu selections, controls, events
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, dav7components,shellApi;

type
  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    SpeedButton1: TSpeedButton;
    Timer1: TTimer;
    PaintBox2: TPaintBox;
    DavArrayBtn1: TDavArrayBtn;
    Label12: TLabel;
    clearBtn: TSpeedButton;
    paintBtn: TSpeedButton;
    PaintBox3: TPaintBox;
    StaticText6: TStaticText;
    Label13: TLabel;
    openBtn: TImage;
    saveBtn: TImage;
    saveImageBtn: TImage;
    helpBtn: TImage;
    davdataBtn: TImage;
    smoothbox: TCheckBox;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    PaintBox4: TPaintBox;
    PaintBox5: TPaintBox;
    msglabel: TLabel;
    Panel3: TPanel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    RadioButton3: TRadioButton;
    RadioButton2: TRadioButton;
    radiobutton1: TRadioButton;
    Label14: TLabel;
    gridbox: TCheckBox;
    Label18: TLabel;
    procedure FormPaint(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StaticText1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StaticText1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure DavArrayBtn1BtnPaint(sender: TObject; BtnNr: Byte;
      status: TBtnStatus);
    procedure PaintBox2Paint(Sender: TObject);
    procedure DavArrayBtn1BtnChange(sender: TObject; BtnNr: Byte;
      status: TBtnStatus; button: TMouseButton);
    procedure clearBtnClick(Sender: TObject);
    procedure paintBtnClick(Sender: TObject);
    procedure PaintBox2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure openBtnClick(Sender: TObject);
    procedure saveBtnClick(Sender: TObject);
    procedure saveImageBtnClick(Sender: TObject);
    procedure helpBtnClick(Sender: TObject);
    procedure davdataBtnClick(Sender: TObject);
    procedure smoothboxClick(Sender: TObject);
    procedure openBtnMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure radiobutton1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure gridboxClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses Unit2;

type TLoadSave = array[0..15] of dword;

const IncValues:array[1..13] of single =
                (0.001,0.002,0.005,0.01,0.02,0.05,0.1,0.2,0.5,1,2,5,10);
      fstring = '#0.0###';
      colorList : array[0..6] of dword =
                  ($ffffff,$ff0000,$00ff00,$0000ff,$ffff00,$ff00ff,$00ffff);
      txt = 'lissa';

var IncIx : byte = 10;  //index into IncValues
    IncVal : single;   //selected IncValue
    constval : array[1..4] of single = (0,0,0,0); //a,b,c,d
    colorNr : byte;
    penNr : byte = 1;
    pencolor : dword;
    smooth : boolean;
    grid : boolean;
    timercode : byte;
    timerplus : boolean = true;
    activemenu : byte = 0;
    busy : boolean = false;
    loadsave : TloadSave;
    formNr : byte = 1;
    stepcount : word = 400;
    formula : byte = 1;

function Boolean2Int(b : boolean) : byte;
begin
 if b then result := 1 else result := 0;
end;

procedure boxedge(pb : TControl; c1,c2 : dword);
//paint colors c1,c2 around control
var i : byte;
    x1,y1,x2,y2 : word;
    comp : TControl;
begin
 comp := getparentform(pb);
 with pb do
  begin
   x1 := left-2;
   x2 := left + width + 1;
   y1 := top - 2;
   y2 := top + height + 1;
  end;
 with TForm(comp) do with canvas do
  begin
   pen.width := 1;
   for i := 0 to 1 do
    begin
     pen.color := c1;
     moveto(x2-i,y1+i);
     lineto(x1+i,y1+i);
     lineto(x1+i,y2-i);
     pen.color := c2;
     lineto(x2-i,y2-i);
     lineto(x2-i,y1+i);
    end;
  end;
end;

procedure showconstant(n : byte);
var s : string;
    i,pp : byte;
begin
 case n of
  0    : s := formatfloat(fstring,incVal);
  1..4 : begin
          s := formatfloat(fstring,constVal[n]);
          pp := length(s) - pos('.',s);
          for i := pp to 2 do s := s + ' ';
         end;
  5    : s := inttostr(stepcount);
 end;//case

 with form1 do
 case n of
  0 : StaticText1.Caption := s;
  1 : StaticText2.Caption := s;
  2 : StaticText3.Caption := s;
  3 : StaticText4.Caption := s;
  4 : StaticText5.Caption := s;
  5 : statictext6.Caption := s;
 end;//case
end;

function menuNr2component(nr : byte) : TControl;
begin
 with form1 do
 case nr of
  1 : result := openBtn;
  2 : result := saveBtn;
  3 : result := saveImageBtn;
  4 : result := helpBtn;
  else result := nil;
 end;
end;

procedure deselectmenu;
const c = $c0c0c0;
begin
 if activemenu > 0 then
  begin
   boxedge(menuNr2component(activemenu),c,c);
   activemenu := 0;
  end;
end;

procedure selectmenu(nr : byte);
const c1 = $0;
      c2 = $ff0000;
begin
 if activemenu > 0 then deselectmenu;
 activemenu := nr;
 boxedge(menuNr2component(nr),c1,c2);
end;

procedure updatevalues;
//update increment and constansts
//timercode selects variable
var d : double;
begin
 case timercode of
  0   : begin
         if timerplus then
          begin
           if incIX < 13 then inc(incIX);
         end
         else if incIX > 1 then dec(incIX);
         incVal := incValues[incIX];
        end;
 1..4 : begin
         d := constVal[timercode];
         d := int(d / incVal + 0.5*FSign(d));
         d := d * incVal;
         if timerplus then
          begin
           if d < 1000 then  d := d + incVal;
          end
          else
           if d > -1000 then  d := d - incVal;
         constVal[timercode] := d;
        end;
   5 :  begin
         if timerplus then
          begin
           if stepcount < 1000 then stepcount := stepcount + 50;
          end
          else if stepcount > 100 then stepcount := stepcount - 50;
        end;
 end;//case
 showconstant(timercode);
end;

procedure paintedges2345;
//pen selection paintboxes
var c1,c2 : dword;
    i : byte;
    pb : Tpaintbox;
begin
 pb := nil;
 with form1 do
  for i := 1 to 4 do
    begin
     case i of
      1 : pb := paintbox2;
      2 : pb := paintbox3;
      3 : pb := paintbox4;
      4 : pb := paintbox5;
     end;
    if pb.Tag = penNr then begin
                            c1 := $000000; c2 := $ff0000;
                           end
     else begin
           c1 := $c0c0c0; c2 := $c0c0c0;
          end;
   boxedge(pb,c1,c2);
  end;
end;

procedure GoDraw;
begin
 form1.msglabel.caption := 'busy...';
 application.ProcessMessages;
 busy := true;
 setconstants(constval[1],constval[2],constval[3],constval[4]);
 setsmooth(smooth);
 setgrid(grid);
 setstepcount(stepcount);
 makepen(penNr,penColor);
 makeDrawing(formula);
 busy := false;
 form1.paintbox1.Canvas.draw(0,0,map);
 form1.msglabel.caption := 'done';
end;

procedure unpackfile;
//array loadsave was read
type PS = ^single;
var s : string;
    OK : boolean;
    i : byte;
begin
 s := '';
 for i := 0 to 4 do s := s + chr(loadsave[i]);
 OK := s = txt;
 if OK then
  begin
   formula := loadsave[5];
   penNr := loadsave[6];
   pencolor := loadsave[7];
   smooth := loadsave[8] = 1;
   grid := loadsave[9] = 1;
   stepcount := loadsave[10];
   incIX := loadsave[11];
   incVal := incValues[incIX];
   for i := 1 to 4 do constval[i] := PS(@loadsave[11+i])^;
   for i := 0 to 5 do showconstant(i);
   with form1 do
    begin
     DavArrayBtn1.BtnDown(colorNr);
     smoothbox.Checked := smooth;
     gridbox.Checked := grid;
     for i := 1 to 3 do
      case i of
       1 : with radiobutton1 do checked := formula = i;
       2 : with radiobutton2 do checked := formula = i;
       3 : with radiobutton3 do checked := formula = i;
      end;//case
     paintbox2.invalidate;
     paintbox3.invalidate;
     paintbox4.invalidate;
     paintbox5.invalidate;
    end;//with form1
   paintedges2345;
   GoDraw;
  end;
end;

//-- form create

procedure TForm1.FormCreate(Sender: TObject);
var i : byte; DecimalSeparator:Char;
begin
 decimalseparator := '.';
 incVal := incValues[incIX];
 for i := 0 to 5 do showconstant(i);
 with davarrayBtn1.canvas do
  begin
   font.Name := 'arial';
   font.height := 18;
  end;

 pencolor := colorList[0];
 davarrayBtn1.btnDown(0);
 davarraybtn1.ShowHint := true;
 clearmap;
end;

//-- events

procedure TForm1.radiobutton1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var i : byte;
begin
 with TRadioButton(sender) do formula := tag;
 for i := 1 to 3 do
  if i <> formula then
   case i of
    1 : radiobutton1.Checked := false;
    2 : radiobutton2.Checked := false;
    3 : radiobutton3.Checked := false;
   end;
end;

procedure TForm1.StaticText1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if busy then exit;
 with TStatictext(sender) do
  begin
   timercode := tag;
   timerplus := button = mbLeft;
   updatevalues;
  end;
 GoDraw;
 with timer1 do
  begin
   interval := 500;
   enabled := true;
  end;
end;

procedure TForm1.StaticText1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 timercode := 0;
end;

procedure TForm1.PaintBox2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
//paintbox2,3,4,5
begin
 with TPaintbox(sender) do
  begin
   penNr := tag;
   paintedges2345;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
 if busy then exit;

 if timercode > 0 then
  begin
   updatevalues;
   with timer1 do if interval > 300 then interval := interval - 50;
   GoDraw;
  end else timer1.enabled := false;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
//clear displays, reset values
var i : byte;
begin
 busy := false;
 incIX := 10;
 incVal := incValues[incIX];
 showconstant(0);
 for i := 1 to 4 do
  begin
   constVal[i] := 0;
   showconstant(i);
  end;
end;

//-- paint events

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
 paintbox1.Canvas.Draw(0,0,map);
end;

procedure TForm1.FormPaint(Sender: TObject);
var i : byte;
begin
 boxedge(paintbox1,$0,$808080);
 paintedges2345;
 for i := 1 to 4 do
  begin
   activemenu := i;
   deselectmenu;     //paint menu button edges
  end;
end;

procedure TForm1.DavArrayBtn1BtnPaint(sender: TObject; BtnNr: Byte;
  status: TBtnStatus);
var r : Trect;
begin
 with davarraybtn1 do with canvas do
  begin
   r := getBtnRect(btnNr);
   r.Left := r.left + 2;
   r.Top := r.Top + 2;
   r.Right := r.Right - 2;
   r.Bottom := r.Bottom - 2;
   brush.Color := swapRB(colorList[btnNr]);
   fillrect(r);
  end;
end;

procedure TForm1.PaintBox2Paint(Sender: TObject);
//paintbox2,3,4,5
var n : byte;
    pb: TPaintbox;
begin
 n := TPaintbox(sender).tag;
 makePen(n,penColor);
 case n of
  1 : Pb := paintbox2;
  2 : Pb := paintbox3;
  3 : Pb := paintbox4;
  4 : Pb := paintbox5;
  else pb := nil;
 end;
 drawpen(pb);
end;

procedure TForm1.DavArrayBtn1BtnChange(sender: TObject; BtnNr: Byte;
  status: TBtnStatus; button: TMouseButton);
begin
 colorNr := BtnNr;
 penColor := ColorList[btnNr];
 paintbox2.Invalidate;
 paintbox3.invalidate;
 paintbox4.invalidate;
 paintbox5.invalidate;
end;

procedure TForm1.clearBtnClick(Sender: TObject);
begin
 busy := false;
 clearmap;
 paintbox1.Invalidate;
end;

procedure TForm1.paintBtnClick(Sender: TObject);
begin
 if busy then exit;
 
 GoDraw;
end;

procedure TForm1.smoothboxClick(Sender: TObject);
begin
 smooth := smoothbox.Checked;
end;

//--- main menu buttons

procedure TForm1.openBtnClick(Sender: TObject);
var OK : boolean;
    f : file of TloadSave;
begin
 OK := false;
 deselectmenu;
 with opendialog1 do
  if execute then
   try
    assignfile(f,filename);
    reset(f);
    read(f,loadsave);
    OK := true;
   finally
    closefile(f);
   end;
 if OK then unpackfile;
end;

procedure TForm1.saveBtnClick(Sender: TObject);
//save settings of drawing
type PDW=^dword;
var f : file of TLoadSave;
    i : byte;
begin
 deselectmenu;
 for i := 0 to 15 do loadsave[i] := 0;
 for i := 0 to 4 do loadsave[i] := byte(txt[i+1]);
 loadsave[5] := formula;
 loadsave[6] := penNr;
 loadsave[7] := pencolor;
 loadsave[8] := Boolean2Int(smooth);
 loadsave[9] := Boolean2Int(grid);
 loadsave[10] := stepcount;
 loadsave[11] := incIX;
 for i := 1 to 4 do loadsave[11+i] := PDW(@constval[i])^;
 with savedialog1 do
  if execute then
   try
    assignfile(f,filename);
    rewrite(f);
    write(f,loadsave);
   finally
    closefile(f);
   end;
end;

procedure TForm1.saveImageBtnClick(Sender: TObject);
begin
 deselectmenu;
 with savedialog2 do
  if execute then
   begin
    map.SaveToFile(filename);
   end;
end;

procedure TForm1.helpBtnClick(Sender: TObject);
begin
 deselectmenu;
 ShellExecute(0,'open','http://www.davdata.nl/math/lissajous3d.html', nil, nil, SW_SHOWNORMAL);
end;

procedure TForm1.davdataBtnClick(Sender: TObject);
//davdata website
begin
 ShellExecute(0,'open','http://www.davdata.nl', nil, nil, SW_SHOWNORMAL);
end;

procedure TForm1.openBtnMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
//all  menu buttons
begin
 with Tcontrol(sender)do
  if activemenu <> tag then selectmenu(tag);
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 deselectmenu;
end;


procedure TForm1.gridboxClick(Sender: TObject);
begin
 grid := gridbox.checked;
end;

end.
