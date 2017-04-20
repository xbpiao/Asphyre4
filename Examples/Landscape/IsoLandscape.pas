unit IsoLandscape;
//---------------------------------------------------------------------------
// Isometric Landscape with "Wave" effect
// Written by Yuriy Kotsarenko (lifepower@mail333.com)
//
// This unit was taken from very old sources and I never got my hands on
// rewriting this. The current implementation is... let's say not very good.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
const
 Undefined= -1;
 TileWidth = 64;
 TileHeight = 32;

//---------------------------------------------------------------------------
type
 MapRec = record
  Heights: array[0..3] of Byte;
  Light  : array[0..3] of Byte;
 end;

//---------------------------------------------------------------------------
 TLand = class
 private
  Wave: array[0..63, 0..63] of Real;

  function Sine(Value: Real): Real;
  procedure CalculateWave();
  procedure CalculateHeights();
 public
  XView,
  YView,
  Width,
  Height: Integer;
  XViewFloat,
  YViewFloat,
  XViewVel,
  YViewVel: Real;
  Alpha,
  Beta,
  Gamma: Real;

  Grid: Boolean;

  Map: array[0..127, 0..63] of MapRec;

  constructor Create();
  function SquareHeight(Xp, Yp, Corner: Integer): Integer;
  function SquareLight(Xp, Yp, Corner: Integer): Integer;
  procedure Render();
  procedure Process();
 end;

//---------------------------------------------------------------------------
implementation
uses
 IsoUtil, AsphyreTypes, AsphyreDevices, AsphyreEffects;

//---------------------------------------------------------------------------
constructor TLand.Create();
begin
 inherited;

 FillChar(Map, SizeOf(Map), 0);
 Width:= 64;
 Height:= 128;
 XView:= 1280;
 YView:= 768;
 XViewFloat:= 1280;
 YViewFloat:= 768;
 XViewVel:= 0;
 YViewVel:= 0;
 Alpha:= 0;
 Beta:= 0;
 Gamma:= 0;

 CalculateWave();
 CalculateHeights();
end;

//---------------------------------------------------------------------------
function TLand.Sine(Value: Real): Real;
begin
 Result:= (Sin(Value * pi) + 1) / 2;
end;

//---------------------------------------------------------------------------
procedure TLand.CalculateWave();
var
 i, j: Integer;
begin
 for j:= 0 to 63 do
  for i:= 0 to 63 do
   Wave[j, i]:= Sine((i / 8) + Alpha) + (Sine((i / 4) + Beta) / 2) + (Sine((j / 16) + Gamma) / 2);
end;

//---------------------------------------------------------------------------
procedure TLand.CalculateHeights();
var
 i, j, DeltaX, Value, Light, x, y: Integer;
begin
 for j:= 1 to Height - 2 do
  for i:= 1 to Width - 2 do
   begin
    DeltaX:= 1 - (j and $01);

    Iso2Line(I, j + 64, x, y);
    x:= x - 64;
    if (x >= 0)and(y >= 0)and(x < 64)and(y < 64) then
     begin
      Value:= Round(Wave[y, x] * 96) + 32;
     end else Value:= 0;

    Light:= Value;
    if (Light > 255) then Light:= 255;
    Map[j, i].Heights[0]:= Value;
    Map[j, i].Light[0]:= Light;
    Map[j + 1, i - DeltaX].Heights[1]:= Value;
    Map[j + 1, i - DeltaX].Light[1]:= Light;
    Map[j - 1, i - DeltaX].Heights[2]:= Value;
    Map[j - 1, i - DeltaX].Light[2]:= Light;
    Map[j, i - 1].Heights[3]:= Value;
    Map[j, i - 1].Light[3]:= Light;
   end;
end;

//---------------------------------------------------------------------------
function TLand.SquareHeight(Xp, Yp, Corner: Integer): Integer;
begin
 if (Xp < 0) then Xp:= 0;
 if (Yp < 0) then Yp:= 0;
 if (Xp > Width - 1) then Xp:= Width - 1;
 if (Yp > Height - 1) then Yp:= Height - 1;
 Result:= Map[Yp,Xp].Heights[Corner];
end;

//---------------------------------------------------------------------------
function TLand.SquareLight(Xp, Yp, Corner: Integer): Integer;
begin
 if (Xp < 0) then Xp:=0;
 if (Yp < 0) then Yp:=0;
 if (Xp > Width - 1) then Xp:= Width - 1;
 if (Yp > Height - 1) then Yp:= Height - 1;
 Result:= Map[Yp, Xp].Light[Corner];
end;

//---------------------------------------------------------------------------
procedure TLand.Render();
var
 ImageIndex: Integer;
 x, y, Xpos, Ypos, XposAdd, XMap, YMap, TileHWidth, TileHHeight: Integer;
begin
 TileHWidth:= TileWidth div 2;
 TileHHeight:= TileHeight div 2;

 ImageIndex:= Devices[0].Images.Image['water'].ImageIndex;

 // render tiles
 for Y:= -1 to (Integer(Devices[0].Params.BackBufferHeight) div TileHHeight) + 14 do
  begin
   Ymap:= (YView div TileHHeight) + Y;
   Ypos:= (Ymap * TileHHeight) - YView - TileHHeight;
   XposAdd:= ((Ymap and $01) * TileHWidth) - XView - TileHWidth;

   for X:= -1 to (Devices[0].Params.BackBufferWidth div TileWidth) + 2 do
    begin
     Xmap:= (XView div TileWidth) + X;
     Xpos:= (Xmap * TileWidth) + XposAdd;

     if (Xmap >= 0)and(Ymap >= 0)and(Xmap < Width)and(Ymap < Height)and(Map[Ymap, Xmap].Light[0] > 0)
        and(Map[Ymap, Xmap].Light[1] > 0)and(Map[Ymap, Xmap].Light[2] > 0)and(Map[Ymap, Xmap].Light[3] > 0) then
      begin
       Devices[0].Canvas.UseImage(Devices[0].Images[ImageIndex], TexFull4);

       Devices[0].Canvas.TexMap(Point4(Xpos, (Ypos + TileHHeight) -
        SquareHeight(Xmap, Ymap,0), Xpos + TileHWidth, Ypos -
        SquareHeight(Xmap, Ymap, 1), Xpos + TileWidth, (Ypos + TileHHeight) -
        SquareHeight(Xmap,Ymap,3), Xpos + TileHWidth, (Ypos + TileHeight) -
        SquareHeight(Xmap,Ymap,2)), cGray4(SquareLight(Xmap,Ymap,0),
        SquareLight(Xmap,Ymap,1), SquareLight(Xmap,Ymap,3), SquareLight(Xmap,
        Ymap, 2)), fxuAdd or fxfDiffuse);

       // NOTE: if you render GRID *HERE*, it'll stall Asphyre buffering and
       // will reduce performance dramatically!
     end;
    end;{ for X:=-1 to ... }
  end;{ for Y:=-1 to ... }

 if (not Grid) then Exit;
 
 // render grid
 for Y:= -1 to (Integer(Devices[0].Params.BackBufferHeight) div TileHHeight) + 14 do
  begin
   Ymap:= (YView div TileHHeight) + Y;
   Ypos:= (Ymap * TileHHeight) - YView - TileHHeight;
   XposAdd:= ((Ymap and $01) * TileHWidth) - XView - TileHWidth;
   for X:= -1 to (Devices[0].Params.BackBufferWidth div TileWidth) + 2 do
    begin
     Xmap:= (XView div TileWidth) + X;
     Xpos:= (Xmap * TileWidth) + XposAdd;

     if (Xmap >= 0)and(Ymap >= 0)and(Xmap < Width)and(Ymap < Height)and(Map[Ymap, Xmap].Light[0] > 0)
        and(Map[Ymap, Xmap].Light[1] > 0)and(Map[Ymap, Xmap].Light[2] > 0)and(Map[Ymap, Xmap].Light[3] > 0) then
      begin
       Devices[0].Canvas.WireQuadHw(Point4(Xpos, (Ypos + TileHHeight) -
        SquareHeight(Xmap, Ymap,0) - 4, Xpos + TileHWidth, Ypos -
        SquareHeight(Xmap, Ymap, 1) - 4, Xpos + TileWidth, (Ypos +
         TileHHeight) - SquareHeight(Xmap,Ymap,3) - 4, Xpos + TileHWidth,
         (Ypos + TileHeight) - SquareHeight(Xmap,Ymap,2) - 4),
         cColor4($40FFFFFF), fxuBlend);
     end;
    end;{ for X:=-1 to ... }
  end;{ for Y:=-1 to ... }

end;

//---------------------------------------------------------------------------
procedure TLand.Process();
begin
 if (XViewVel > 8) then XViewVel:= 8;
 if (YViewVel > 8) then YViewVel:= 8;
 if (XViewVel < -8) then XViewVel:= -8;
 if (YViewVel < -8) then YViewVel:= -8;

 XViewFloat:= XViewFloat + XViewVel;
 YViewFloat:= YViewFloat + YViewVel;

 if (Abs(XViewVel) < 0.3) then XViewVel:= 0;
 if (Abs(YViewVel) < 0.3) then YViewVel:= 0;
 if (XViewVel > 0) then XViewVel:= XViewVel - 0.5;
 if (YViewVel > 0) then YViewVel:= YViewVel - 0.5;
 if (XViewVel < 0) then XViewVel:= XViewVel + 0.5;
 if (YViewVel < 0) then YViewVel:= YViewVel + 0.5;

 XView:= Round(XViewFloat);
 YView:= Round(YViewFloat);

 Alpha:= Alpha - 0.02;
 Beta:= Beta - 0.0257;
 Gamma:= Gamma - 0.033;

 CalculateWave();
 CalculateHeights();
end;

//---------------------------------------------------------------------------
end.
