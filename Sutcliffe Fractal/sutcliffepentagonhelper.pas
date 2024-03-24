unit SutcliffePentagonHelper;

{$mode ObjFPC}{$H+}
{
  Name   : helper.fpcustoncanvas
  Desc   : class helper for TFPCustomCanvas that adds Sutcliffe Pentagon rendering
  by     : TRon 2023 (Pay It Forward)
  origin : code based on https://github.com/tex2e/p5js-pentagon
  thread : https://forum.lazarus.freepascal.org/index.php/topic,64632.0.html

  2023.09.24 - Initial class published @thread based on original js code.
  2023.09.25 - Conversion from class to procedural (internal release).
             - Conversion from procedural to class helper for TFPCustomcanvas.
             - Class helper published @thread.
  2023.09.26 - Bug report by Boleeman: missing nest drawing.
             - Fixed bug as reported by Boleeman.
               Createbranch was used the wrong points for drawing resulting in
               the perception that some (nesting) cycle was being omitted from
               drawing.
             - Excluded (commented) drawing root branch entirely.
             - reordered parameters for RenderSutcliffePentagon. Switched
               aNumsides with aNest.
             - Bugfix release published @thread.
}

interface

uses
  types, fpcanvas, math;

type
  TPoints = array of TPoint;

  TSutcliffePentagonHelper = class helper for TFPCustomCanvas
   protected
    procedure CreateBranch(const aLevel, aNum: integer; constref aPoints: TPoints;
              const aMaxLevel, aStrutTarget, aSubStrutTarget: integer; const aStrutFactor: Float);
    procedure DrawBranch(constref aOuterPoints: TPoints; const aLevel: integer);
    function  CalcStrutPoints(const aNum, aStrutTarget, aSubStrutTarget: integer;
              const aStrutFactor: Float; constref aMidPoints, aOuterPoints: TPoints): TPoints;
    function  CalcStrutPoint(constref mp, op: TPoint; const aStrutFactor: Float): TPoint;
    function  CalcMidPoints(constref aOuterPoints: TPoints): TPoints;
    function  CalcMidPoint(constref end1, end2: TPoint): TPoint;
   public
    procedure RenderSutcliffePentagon(const aNest, aRadius: integer; const aStrutFactor: Float;
              const aStrutTarget, aSubStrutTarget, aNumSides: integer);
  end;

implementation


procedure TSutcliffePentagonHelper.RenderSutcliffePentagon
    (
      const aNest, aRadius: integer;
      const aStrutFactor: Float;
      const aStrutTarget, aSubStrutTarget, aNumSides: integer
    );
var
  CenterX: integer;
  CenterY: integer;
  angleStep: Float;
  i: Float;
  Points: TPoints = nil;  // silence compiler

begin
  centerX := Self.Width div 2;
  centerY := (Self.Height - 77) div 2;
  angleStep := 360 / aNumSides;
  i := -90;
  while i < 270 do
  begin
    setlength(Points, Length(Points)+1);
    Points[High(Points)] := point
    (
      round(CenterX + (aRadius * cos(DegToRad(i)))),
      round(CenterY + (aRadius * sin(DegToRad(i))))
    );
    i := i + angleStep;
  end;

  // render root branch
  CreateBranch(0, 0, Points, aNest, aStrutTarget, aSubStrutTarget, aStrutFactor);
  // ??? is the following call really necessary ???
  //  DrawBranch(Points, aNest);
end;

procedure TSutcliffePentagonHelper.CreateBranch
    (
      const aLevel, aNum: integer;
      constref aPoints: TPoints;
      const aMaxLevel, aStrutTarget, aSubStrutTarget: integer;
      const aStrutFactor: Float
    );
var
  k, knext: integer;
  newPoints: TPoints;
  OuterPoints: TPoints;
  MidPoints: TPoints;
  ProjPoints: TPoints;
begin
  OuterPoints := aPoints;
  MidPoints := CalcMidPoints(OuterPoints);
  ProjPoints := calcStrutPoints(aNum, aStrutTarget, aSubStrutTarget, aStrutFactor, MidPoints, OuterPoints);

  if (aLevel + 1 < aMaxLevel) then
  begin
    // render child branch
    CreateBranch(aLevel + 1, 0, ProjPoints, aMaxLevel, aStrutTarget, aSubStrutTarget, aStrutFactor);
    DrawBranch(ProjPoints, aLevel);

    for k := Low(OuterPoints) to High(OuterPoints) do
    begin
      KNext := (k - 1 + Length(OuterPoints)) mod Length(OuterPoints);
      newpoints :=
      [
        ProjPoints[k], MidPoints[k], OuterPoints[k],
        MidPoints[kNext], ProjPoints[kNext]
      ];

      // render subchild branch
      CreateBranch(aLevel + 1, k + 1, NewPoints, aMaxLevel, aStrutTarget, aSubStrutTarget, aStrutFactor);
      DrawBranch(NewPoints, aLevel);
    end;
  end;
end;

procedure TSutcliffePentagonHelper.DrawBranch(constref aOuterPoints: TPoints; const aLevel: integer);
var
  weight: integer;
  i, iNext: integer;
begin
  if aLevel < 5 then weight := 5 - aLevel else weight := 1;
  Self.Pen.Width := weight; // set width of pen -> strokeWeight(weight)

  // draw outer shape
  for i := Low(aOuterPoints) to High(aOuterPoints) do
  begin
    iNext := (i + 1) mod length(aOuterPoints);
    Self.Line
    (
      aOuterPoints[i].x,     aOuterPoints[i].y,
      aOuterPoints[iNext].x, aOuterPoints[iNext].y
    );
  end;
end;

function  TSutcliffePentagonHelper.CalcStrutPoints(const aNum, aStrutTarget, aSubStrutTarget: integer; const aStrutFactor: Float; constref aMidPoints, aOuterPoints: TPoints): TPoints;
var
  strutPoints: TPoints absolute result;
  i, iNext, skipNum: integer;
begin
  strutPoints := [];  // silence compiler
  setLength(strutPoints, length(aMidPoints));
  for i := low(aMidPoints) to High(aMidPoints) do
  begin
    if aNum = 0
      then skipNum := aStrutTarget
      else skipNUm := aSubStrutTarget;

    iNext := (i + skipNum) mod Length(aOuterPoints);
    strutPoints[i] := calcStrutPoint(aMidPoints[i], aOuterPoints[iNext], aStrutFactor);
  end;
end;

function  TSutcliffePentagonHelper.CalcStrutPoint(constref mp, op: TPoint; const aStrutFactor: Float): TPoint;
var
  opp, adj: integer;
  px: integer absolute result.x;
  py: integer absolute result.y;
begin
  opp := abs(op.x - mp.x);
  adj := abs(op.y - mp.y);

  if op.x > mp.x
    then px := mp.x + round(opp * aStrutFactor)
    else px := mp.x - round(opp * aStrutFactor);

  if op.y > mp.y
    then py := mp.y + round(adj * aStrutFactor)
    else py := mp.y - round(adj * aStrutFactor);
end;

function  TSutcliffePentagonHelper.CalcMidPoints(constref aOuterPoints: TPoints): TPoints;
var
  midPoints: TPoints absolute result;
  i, iNext: integer;
begin
  midPoints := [];  // silence compiler
  setLength(midPoints, length(aOuterPoints));
  for i := Low(aOuterPoints) to High(aOuterPoints) do
  begin
    iNext := (i + 1) mod Length(aOuterPoints);
    midPoints[i] := calcMidPoint(aOuterPoints[i], aOuterPoints[iNext]);
  end;
end;

function  TSutcliffePentagonHelper.CalcMidPoint(constref end1, end2: TPoint): TPoint;
var
  mx: integer absolute result.x;
  my: integer absolute result.y;
begin
  if end1.x > end2.x
    then mx := end2.x + ((end1.x - end2.x) div 2)
    else mx := end1.x + ((end2.x - end1.x) div 2);

  if end1.y > end2.y
    then my := end2.y + ((end1.y - end2.y) div 2)
    else my := end1.y + ((end2.y - end1.y) div 2);
end;

end.

