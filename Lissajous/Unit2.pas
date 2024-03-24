unit Unit2;

{$MODE Delphi}

{
  3D Lissajous graphics
  jan. 2015, version 1.1
  - changed angles to degreesw (was radians)
  - added simple grid
  
  data, procedures for 3D Lissajous painting

  painting in map [x,y] dimensions 800 * 800
  coordinates (0,0,0) at [385,385]
  pen dimensions 31*31 pixels
  pen position (0,0) at left top
  z axis at 45 degrees, scale 0.7:1  positive towards front
  Xpix = X - 0.5Z
  Ypix = Y + 0.5Z
}  

interface

uses windows,extctrls,graphics,types;

procedure setconstants(a,b,c,d : single);
procedure setsmooth(sm : boolean);
procedure setgrid(gr : boolean);
procedure setstepcount(sc : word);
procedure makepen(pNr:byte; col:dword);
procedure drawPen(pb:Tpaintbox);
procedure makedrawing(formula : byte);
function FSign(v : single) : single;
function Isign(a : smallInt) : smallInt;
procedure clearmap;
function swapRB(c : dword) : dword;

var map : TBitmap;       //global map for image
    p0,pstep : dword;    //p0:scanline[0] pstep:line step pointer difference

implementation

type Tpixels = array[0..30,0..30] of dword; //pen image
     TZ = array[0..30,0..30] of smallInt;   //pixel Z height
     PDW = ^dword;

const center = 385;

var Zbuffer : array[0..799,0..799] of smallInt;
    SPixels : TPixels;
    SZ : TZ;
    pencolor : dword;
    penNr :byte;
    smooth : boolean;
    grid : boolean;
    stepcount : word;
    ca,cb,cc,cd : single;   //formula constants

procedure setconstants(a,b,c,d : single);
const f = pi/180;
begin
 ca := a*f;
 cb := b*f;
 cc := c*f;
 cd := d*f;
end;

procedure setsmooth(sm : boolean);
begin
 smooth := sm;
end;

procedure setgrid(gr : boolean);
begin
 grid := gr;
end;

procedure setstepcount(sc : word);
begin
 stepcount := sc;
end;

procedure drawPen(pb : Tpaintbox);
//copy pen in paintbox pb 31*31
var i,j : byte;
begin
 for j := 0 to 30 do
  for i := 0 to 30 do pb.Canvas.Pixels[i,j] := swapRB(Spixels[i,j]);
end;

function swapRB(c : dword) : dword;
//swap red & blue fields
begin
 result := (c and $0000ff00) or (c shr 16) or ((c and $ff) shl 16);
end;

function FSign(v : single) : single;
//return 1 for +, -1 for -
begin
 result := 0;
 if v > 0 then result := 1;
 if v < 0 then result := -1;
end;

function Isign(a : smallInt) : smallInt;
begin
 if a < 0 then result := -1
  else if a > 0 then result:= 1
   else result := 0;
end;

function Strunc(f : single) : smallInt;
//round f to nearest integer
begin
 if f >= 0 then result := trunc(f+0.5)
  else result := trunc(f-0.5);
end;

procedure clearPen;
var i,j : byte;
begin
  for j := 0 to 30 do         //clear all
   for i := 0 to 30 do
    begin
     SZ[i,j] := -1000;
     SPixels[i,j] := $ffffff;
    end;
end;

procedure makeSPHcolors;
//make sphere pen
var i,j : byte;
    r,g,b : byte;
    vr,vg,vb : byte;
    d : single;
begin
  clearPen;
  vb := pencolor shr 16;
  vg := pencolor shr 8 and $ff;
  vr := pencolor and $ff;
  for j := 0 to 30 do
   for i := 0 to 30 do
    begin
     d := 229 - sqr(j-15) - sqr(i-15);
     if d >= 0 then
      begin
       SZ[i,j] := trunc(0.5*sqrt(d)+0.5);
       if (abs(i) < 4) and (abs(j) < 4) then d := 1
        else d := 1 - sqrt(sqr(i-10) + sqr(j-10)+0.5)*0.04;
       r := trunc(vr*d);
       g := trunc(vg*d);
       b := trunc(vb*d);
       Spixels[i,j] := r + (g shl 8) + (b shl 16);
      end;
    end;
end;

procedure makeSQRcolors;
//make cube pen
var i,j : byte;
    d : dword;
begin
  d := pencolor;
  clearPen;
  for j := 10 to 30 do       //front edge
   for i := 0 to 20 do
    begin
     SZ[i,j] := 10;
     SPixels[i,j] := d;
    end;
  d := d and $b0b0b0;
  for j := 0 to 9 do       //top edge
   for i := 10-j to 30-j do
    begin
     SZ[i,j] := trunc(0.88*j + 1);
     SPixels[i,j] := d;
    end;
  d := d and $707070;
  for i := 21 to 30 do       //right edge
   for j := 31-i  to 50-i do
    begin
     SZ[i,j] := trunc(0.88*(31.5-i));
     SPixels[i,j] := d;
    end;
end;

procedure makeRectColors;
//flat square pen
var i,j : byte;
    d,d1,d2,d3 : dword;
begin
 clearPen;
 d := pencolor;
 d1 := d and $c0c0c0;
 d2 := d and $808080;
 d3 := d and $606060;
 for i := 0 to 1 do
  for j := i to 30-i do     //left
  begin
   SPixels[i,j] := d;
   SZ[i,j] := 0;
  end;
 for i := 29 to 30 do      //right
  for j := 31-i to i do
   begin
    Spixels[i,j] := d3;
    SZ[i,j] := 0;
   end;
 for j := 0 to 1 do        //top
  for i := j to 30-j do
   begin
    Spixels[i,j] := d1;
    SZ[i,j] := 0;
   end;
 for j := 29 to 30 do       //bottom
  for i := 31-j to j-1 do
   begin
    SPixels[i,j] := d2;
    SZ[i,j] := 0;
   end;
end;

procedure makeCircle;
//make circle pen
var i,j : byte;
    r,g,b : byte;
    vr,vg,vb : byte;
    w : word;
    d : single;
begin
 clearPen;
 vb := pencolor shr 16;
 vg := pencolor shr 8 and $ff;
 vr := pencolor and $ff;
 for j := 0 to 30 do
  for i := 0to 30 do
   begin
    w := sqr(j-15) + sqr(i-15);
    if (w < 240) and (w > 170) then
     begin
      SZ[i,j] := trunc(sqrt(240-sqr(15-i)-sqr(15-j)));
      d := 1 - sqrt(sqr(i-10) + sqr(j-10)+0.5)*0.04;
      r := trunc(vr*d);
      g := trunc(vg*d);
      b := trunc(vb*d);
      Spixels[i,j] := r + (g shl 8) + (b shl 16);
      SZ[i,j] := 0;
     end;
   end;//for
end;

procedure makePen(pNr : byte; col:dword);
begin
 if (pencolor <> col) or (penNr <> pNr) then
  begin
   pencolor := col;
   penNr := pNr;
   case pNr of
    1 : makeSPHcolors;
    2 : makeSQRcolors;
    3 : makeRectColors;
    4 : makeCircle;
   end;
  end;
end;

procedure clearmap;
var i,j : word;
begin
 with map do with canvas do
  begin
   brush.Color := $ffffff;
   brush.Style := bsSolid;
   fillrect(rect(0,0,width,height));
  end;
 for j := 0 to 799 do
  for i := 0 to 799 do Zbuffer[i,j] := -400;
end;

//-- helpers for grid drawing --

procedure Xline(x1,x2,y,z : smallInt);
var n,dx,i : smallInt;
    delta : byte;
    color,p,p1 : dword;
    px,py : word;
begin
 dx := x2-x1;
 px := x1 - z + 400;
 py := y + z + 400;
 n := abs(dx);
 dx := Isign(dx);
 delta := $80 - trunc(0.5*z);
 color := RGB($ff,delta,delta);
 p1 := p0 - py*pstep;
 for i := 0 to n do
  begin
   if Zbuffer[px,py] < z then
    begin
     p := p1 + (px shl 2);
     PDW(p)^ := color;
     Zbuffer[px,py] := z;
    end;
   px := px + dx;
  end;
end;

procedure Yline(x,y1,y2,z : smallInt) ;
var n,dy,i : smallInt;
    delta : byte;
    color,p : dword;
    px,py : word;
begin
 dy := y2-y1;
 py := y1 + z + 400;
 px := x - z + 400;
 n := abs(dy);
 dy := Isign(dy);
 delta := $80 - trunc(0.5*z);
 color := RGB($ff,delta,delta);
 for i := 0 to n do
  begin
   if Zbuffer[px,py] < z then
    begin
     p := p0 -py*pstep + (px shl 2);
     PDW(p)^ := color;
     Zbuffer[px,py] := z;
    end;
   py := py + dy;
  end;
end;

procedure Zline(x,y,z1,z2 : smallInt);
//only lines in z direction
var i,n,dx,dy,z : smallInt;
    dz : single;
    p : dword;
    delta : byte;
    px,py : word;
begin
 dy := z2 - z1;
 dx := z1 - z2;
 px := x - z1 + 400;
 py := y + z1 + 400;
 if dx >= dy then n := abs(dx) else n := abs(dy);
 dy := Isign(dy);
 dx := Isign(dx);
 dz := (z2-z1)/n;
 for i := 0 to n do
  begin
   z := z1 + Strunc(i*dz);
   delta := $80 - trunc(0.5*z);
   p := p0 - py*pstep + (px shl 2);
   if Zbuffer[px,py] < z then PDW(p)^ := RGB($ff,delta,delta);
   px := px + dx;
   py := py + dy;
  end;
end;

procedure paintgrid;
var i,k : smallInt;
begin
 for i := -1 to 1 do
  begin
   k := i*250;
   Xline(-250,250,k,0);
   Yline(k,-250,250,0);
   Yline(0,-250,250,k shr 1);
   Zline(0,k,-125,125);
  end;
end;

procedure paintImage(x,y,z : smallInt);
//x,y are left-top coordinates of pen
//paint pen at x,y,z
var p,p1 : dword;
    px,py : word;
    Zsph : smallInt;
    i,j : byte;
begin
 with map do
  begin
   for j := 0 to 30 do
    begin
     py := y + j;
     p1 := p0 - py*pStep;
     for i := 0 to 30 do
      begin
       px := x + i;
       Zsph := z + SZ[i,j];
       if (Zsph > ZBuffer[px,py]) then
        begin
         p := p1 + (px shl 2);
         ZBuffer[px,py] := Zsph;
         PDW(p)^ := SPixels[i,j];
        end;
      end;//for i
    end;//for j
  end;//with
end;

procedure makeDrawing(formula:byte);
//fm:formula#
var i,n,t : word;
    x,y,z : single;                           //calculated
    px1,py1,pz1,px2,py2,pz2 : smallInt;       //integer positions
    dx,dy,dz : single;                        //differences
    sx,sy,sz : smallInt;                      //screen coordinates
    code : byte;
begin
 clearmap;
 if grid then paintgrid;
 n := 0;
 px1 := 0; py1 := 0; pz1 := 0;
 for t := 0 to stepcount do
  begin
   case formula of
    1 : begin
         x := 250*cos(ca*t);
         y := 250*sin(cb*t);
         z := 125*sin(cc*t);
        end;
    2 : begin
         x := 125*(cos(ca*t) + cos(cb*t));
         y := 125*(sin(ca*t) + sin(cc*t));
         z := 125*sin(cd*t);
        end;
    3 : begin
         x := 125*sin(ca*t)*(1+cos(cb*t));
         y := 125*sin(ca*t)*(1+sin(cc*t));
         z := 125*sin(cd*t);
        end;
    else begin x:=0; y:=0; z:=0; end;
   end;//case
   if (t = 0) or (smooth=false) then
    begin
     pz1 := Strunc(z);
     px1 := Strunc(x) - pz1 + center;   //3D & screen corrections
     py1 := Strunc(y) + pz1 + center;
     paintImage(px1,py1,pz1);
    end
    else
     begin
      pz2 := Strunc(z);
      px2 := Strunc(x) - pz2 + center;
      py2 := Strunc(y) + pz2 + center;
      dx := px2 - px1;
      dy := py2 - py1;
      dz := pz2 - pz1;
      if abs(dx) < 0.5 then code := 0 else code := 1;
      if abs(dy) >= 0.5 then code := code or $2;
      case code of
       0 : begin
            if dz  <= 0 then n := 0 else n := 1;
            dx := 0;
            dy := 0;
           end;
       1 : begin
            n := abs(trunc(dx));
            dx := Fsign(dx);
            dz := dz/n;
           end;
       2 : begin
            n := abs(trunc(dy));
            dy := Fsign(dy);
            dz := dz/n;
           end;
       3 : begin
            if abs(dx) >= abs(dy) then
             begin
              n := abs(trunc(dx));
              dx := Fsign(dx);
              dy := dy/n;
              dz := dz/n;
             end
             else
              begin
               n := abs(trunc(dy));
               dy := Fsign(dy);
               dx := dx/n;
               dz := dz/n;
              end;
           end;
      end;//case
      if code <> 0 then
       for i := 1 to n do
        begin
         sx := Strunc(px1+i*dx);
         sy := Strunc(py1+i*dy);
         sz := Strunc(pz1+i*dz);
         paintimage(sx,sy,sz);
        end;
      px1 := px2;
      py1 := py2;
      pz1 := pz2;
     end;//else
  end;//for t
end;

initialization

 map := TBitmap.Create;
 with map do
  begin
   width := 800;
   height := 800;
   pixelformat := pf32bit;
   p0 := dword(scanline[0]);
   pstep := p0 - dword(scanline[1]);
  end;

finalization

 map.Free;

end.
