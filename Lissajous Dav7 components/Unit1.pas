unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure selectcolor1(sender : TObject; color : LongInt);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses dav7components;

var mixer : Tdav7ColorMixer;
    color : longInt = $000000;

procedure TForm1.Button1Click(Sender: TObject);
begin
 mixer := TDav7Colormixer.create(form1);
 with mixer do
  begin
   parent := form1;
   top := 10;
   left := 100;
   onselect := selectcolor1;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
 mixer.Free;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 mixer.history := true;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
 mixer.history := false;
end;

procedure TForm1.selectcolor1(sender : Tobject; color : longInt);
begin
//==
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
 mixer.showcolor := true;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
 mixer.showcolor := false;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
 mixer.updatehistory;
end;

end.
