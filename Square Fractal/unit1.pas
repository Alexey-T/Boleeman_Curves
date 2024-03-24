unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnSavepic: TButton;
    cbBackcolor: TColorButton;
    cb_back_color: TCheckBox;
    color_filled_circles: TColorButton;
    color_circles: TColorButton;
    cb_show_right: TCheckBox;
    cb_show_left: TCheckBox;
    cb_fill_circles: TCheckBox;
    cb_show_circles: TCheckBox;
    cb_show_bottom: TCheckBox;
    cb_show_top: TCheckBox;
    color_right: TColorButton;
    color_left: TColorButton;
    color_top: TColorButton;
    color_bottom: TColorButton;
    Label1: TLabel;
    Label2: TLabel;
    lblCircborderNSize: TLabel;
    lblCircborderNSize1: TLabel;
    lblLinescolorBackcolor: TLabel;
    lblSizeNReclevel1: TLabel;
    PaintBox1: TPaintBox;
    Panel_left: TPanel;
    Panel_back_color: TPanel;
    Panel_circ_width_size: TPanel;
    Panel_line_width_back_color: TPanel;
    Panel_circ_width: TPanel;
    Panel_circ_size: TPanel;
    Panel_line_width: TPanel;
    Panel_rec_level: TPanel;
    Panel_show_right: TPanel;
    Panel_show_left: TPanel;
    Panel_fill_circles: TPanel;
    Panel_show_circles: TPanel;
    Panel_show_bottom: TPanel;
    Panel_show_top: TPanel;
    SaveDialog1: TSaveDialog;
    seCircborderwidth: TSpinEdit;
    seCirclesize: TSpinEdit;
    seLinewidth: TSpinEdit;
    seRecursionlevel: TSpinEdit;
    procedure btnSavepicClick(Sender: TObject);
    procedure change_setting(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    pattern_size : integer;

  public
    procedure MakePattern(acanvas : tcanvas);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.change_setting(Sender: TObject);
begin
  paintbox1.invalidate;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  pattern_size := min(PaintBox1.width,PaintBox1.height) -10;
  makepattern(paintbox1.Canvas);
end;

procedure TForm1.MakePattern(acanvas : tcanvas);

  procedure colored_line(x1,y1,x2,y2 : integer; c : tcolor);
  begin
    acanvas.Pen.Color := c;
    acanvas.Line(x1,y1, x2,y2);
  end;

  procedure SquarePrimitive(X, Y, SideLength: Integer);
  begin
    acanvas.Pen.Width := seLinewidth.Value;

    if cb_show_bottom.checked then
      colored_line(X - SideLength div 2, Y + SideLength div 2,
                   X + SideLength div 2, Y + SideLength div 2,
                   color_bottom.ButtonColor);

    if cb_show_right.checked then
      colored_line(X + SideLength div 2, Y + SideLength div 2,
                   X + SideLength div 2, Y - SideLength div 2,
                   color_right.ButtonColor);

    if cb_show_top.checked then
      colored_line(X + SideLength div 2, Y - SideLength div 2,
                   X - SideLength div 2, Y - SideLength div 2,
                   color_top.ButtonColor);

    if cb_show_left.checked then
      colored_line(X - SideLength div 2, Y - SideLength div 2,
                   X - SideLength div 2, Y + SideLength div 2,
                   color_left.ButtonColor);

    // Draw circles if the corresponding checkbox is checked
    with acanvas do
      if cb_show_circles.checked then
      begin
        Pen.Width := seCircborderwidth.Value;
        if cb_fill_circles.checked then
        begin
          Brush.Style := bsSolid;
          Brush.Color := color_filled_circles.ButtonColor;
        end
        else
          Brush.Style := bsClear;

        Pen.Color:= color_circles.ButtonColor;

        // Draw circles here...
        Ellipse(X - SideLength div 2 - seCirclesize.Value,
                Y + SideLength div 2 - seCirclesize.Value,
                X - SideLength div 2 + seCirclesize.Value,
                Y + SideLength div 2 + seCirclesize.Value);

        Ellipse(X + SideLength div 2 - seCirclesize.Value,
                Y + SideLength div 2 - seCirclesize.Value,
                X + SideLength div 2 + seCirclesize.Value,
                Y + SideLength div 2 + seCirclesize.Value);

        Ellipse(X + SideLength div 2 - seCirclesize.Value,
                Y - SideLength div 2 - seCirclesize.Value,
                X + SideLength div 2 + seCirclesize.Value,
                Y - SideLength div 2 + seCirclesize.Value);

        Ellipse(X - SideLength div 2 - seCirclesize.Value,
                Y - SideLength div 2 - seCirclesize.Value,
                X - SideLength div 2 + seCirclesize.Value,
                Y - SideLength div 2 + seCirclesize.Value);
      end;

    application.processmessages;
  end;

  procedure SquarePattern(X, Y, FirstSquareSideLength, RecursionDepth: Integer);
  begin
    if (FirstSquareSideLength <= 0) or (RecursionDepth < 1) then
      Exit
    else
    begin
      SquarePrimitive(X, Y, FirstSquareSideLength);

      Dec(RecursionDepth);

      if RecursionDepth > 0 then
      begin
        SquarePattern(X - FirstSquareSideLength div 2,
                      Y - FirstSquareSideLength div 2,
                      FirstSquareSideLength div 2,
                      RecursionDepth);
        SquarePattern(X - FirstSquareSideLength div 2,
                      Y + FirstSquareSideLength div 2,
                      FirstSquareSideLength div 2,
                      RecursionDepth);
        SquarePattern(X + FirstSquareSideLength div 2,
                      Y - FirstSquareSideLength div 2,
                      FirstSquareSideLength div 2,
                      RecursionDepth);
        SquarePattern(X + FirstSquareSideLength div 2,
                      Y + FirstSquareSideLength div 2,
                      FirstSquareSideLength div 2,
                      RecursionDepth);
      end;
    end;
  end;

begin
  acanvas.Pen.Width := seLinewidth.Value;
  if cb_back_color.checked then
  begin
    acanvas.Brush.Color := cbBackcolor.ButtonColor;
    acanvas.Rectangle(0, 0, PaintBox1.Width, PaintBox1.Height);
  end;
  SquarePattern(0, 0, pattern_size, seRecursionlevel.Value);
end;

procedure TForm1.btnSavepicClick(Sender: TObject);
var
  img : timage;
begin
  SaveDialog1.Filter := 'PNG Files|*.png';
  SaveDialog1.DefaultExt := 'png';
  SaveDialog1.Title := 'Save Image As';

  if SaveDialog1.Execute then
  begin
    img := TImage.create(form1);
    img.Width := Paintbox1.Width;
    img.Height := Paintbox1.Height;
    pattern_size := min(img.width,img.height) -10;
    MakePattern(img.canvas);
    img.picture.savetofile(SaveDialog1.FileName);
    img.Free;
  end;
end;

end.

