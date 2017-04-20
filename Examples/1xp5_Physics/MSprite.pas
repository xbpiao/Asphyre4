unit MSprite;
//------------------------------------------------------------------------------
//    行走精灵的定义与实现
//    WalkSprite  implementation
//-------------------------------------------------------------------------------
//    huaosft(http://www.huosoft.com)               Modified:25-Jan-2007
//------------------------------------------------------------------------------

interface
uses
  Controls,AsphyreSprite, SysUtils, AsphyreTypes, Math, Classes, windows,
  AsphyreSpriteUtils, AsphyreEffects,AsphyreSpriteEffects;

type
  TSpritePos = record
    X, Y, Angle, ScaleX, ScaleY: Single;
    Z, Alpha, Red, Green, Blue: Integer; //
  end;

  TGameSprite = class(TAnimatedSprite)
  Private
    DoChanging: Boolean;
    Dest_Pos, Delta_pos: TSpritePos;
    curStep: Integer;
  Public
    ChangeSpeed: Single;
    procedure SetSpriteDestPos(DestPos: TSpritePos);
    procedure SetImageByDirect(Directions: Integer);
    procedure DoMove(const MoveCount: Single); Override;
  end;

function cSpritePos(X, Y: Single; Z: Integer = -1; Angle: Single = 0; ScaleX: Single = 1; ScaleY:
  Single = 1; Alpha: Integer = 255;
  Red: Integer = 255; Green: Integer = 255; Blue: Integer = 255; PatternIndex: Integer = -1):
  TSpritePos;

//------------------------------------------------------------------
implementation
function cSpritePos(X, Y: Single; Z: Integer = -1; Angle: Single = 0; ScaleX: Single = 1; ScaleY:
  Single = 1; Alpha: Integer = 255;
  Red: Integer = 255; Green: Integer = 255; Blue: Integer = 255; PatternIndex: Integer = -1):
  TSpritePos;
begin
  result.X := X;
  result.Y := Y;
  result.Z := Z;
  result.Angle := Angle;
  result.ScaleX := ScaleX;
  result.ScaleY := ScaleY;
  result.Alpha := Alpha;
  result.Red := Red;
  result.Green := Green;
  result.Blue := Blue;
end;
//------------------------------------------------------------------
{ TGameSprite }
procedure TGameSprite.DoMove(const MoveCount: Single);
begin
  inherited;
//  if Collisioned then
//    Drawfx := fxuBright
//  else
//    Drawfx := fxuBlend;
//  if Selected then  Drawfx := fxBright;

  if not DoChanging then  Exit;
  
  Dec(curStep);

  X := dest_Pos.X - delta_Pos.X * curStep;
  Y := dest_Pos.Y - delta_Pos.Y * curStep;
  Angle := dest_Pos.Angle - delta_Pos.Angle * curStep;
  Alpha := dest_Pos.Alpha - delta_Pos.Alpha * curStep;
  ScaleX := dest_Pos.ScaleX - delta_Pos.ScaleX * curStep;
  ScaleY := dest_Pos.ScaleY - delta_Pos.ScaleY * curStep;

  red := dest_Pos.red - delta_Pos.red * curStep;
  green := dest_Pos.green - delta_Pos.green * curStep;
  blue := dest_Pos.blue - delta_Pos.blue * curStep;

  if curStep <= 0 then
  begin
    Z := dest_Pos.Z;
    DoChanging := false;
    Angle := 0;
//    DoAnimate:=false;
  end;
end;


procedure TGameSprite.SetImageByDirect(Directions: Integer);
var
  FramePerDir, Direction: integer;
begin
  FramePerDir := 12;
  case Directions of
    240..255,
      0..15: Direction := 0;
    16..47: Direction := 1;
    48..79: Direction := 2;
    80..111: Direction := 3;
    112..143: Direction := 4;
    144..175: Direction := 5;
    176..207: Direction := 6;
    208..239: Direction := 7;
  end;
  case Direction of
    0:
      begin
        AnimStart := 0 * FramePerDir; MirrorX := False;
      end;
    1:
      begin
        AnimStart := 1 * FramePerDir; MirrorX := False;
      end;
    2:
      begin
        AnimStart := 2 * FramePerDir; MirrorX := False;
      end;
    3:
      begin
        AnimStart := 3 * FramePerDir; MirrorX := False;
      end;
    4:
      begin
        AnimStart := 4 * FramePerDir; MirrorX := False;
      end;
        //5,6,7 use image mirror
    5:
      begin
        AnimStart := 3 * FramePerDir; MirrorX := True;
      end;
    6:
      begin
        AnimStart := (3 - 1) * FramePerDir; MirrorX := True;
      end;
    7:
      begin
        AnimStart := (3 - 2) * FramePerDir; MirrorX := True;
      end;
  end;
end;

procedure TGameSprite.SetSpriteDestPos(DestPos: TSpritePos);
var
  Direction: Integer;
begin
  //-1表示状态不变
  Dest_Pos := DestPos;
  if Dest_Pos.X = -1 then Dest_Pos.X := X;
  if Dest_Pos.Y = -1 then Dest_Pos.Y := Y;
  if Dest_Pos.Z = -1 then Dest_Pos.Z := Z;
  if Dest_Pos.Alpha = -1 then  Dest_Pos.Alpha := Alpha;
  if Dest_Pos.Red = -1 then  Dest_Pos.Red := Red;
  if Dest_Pos.Green = -1 then  Dest_Pos.Green := Green;
  if Dest_Pos.Blue = -1 then  Dest_Pos.Blue := Blue;
  if Dest_Pos.Angle = -1 then   Dest_Pos.Angle := Angle;
  if Dest_Pos.ScaleX = -1 then  Dest_Pos.ScaleX := ScaleX;
  if Dest_Pos.ScaleY = -1 then  Dest_Pos.ScaleY := ScaleY;


  DoChanging := false;
  curStep := trunc(ChangeSpeed * Sqrt((Dest_Pos.X - X) * (Dest_Pos.X - X) + (Dest_Pos.Y - Y) *
    (Dest_Pos.Y - Y)));
  Direction := Round(Abs(((Arctan2(Dest_Pos.X - X, Dest_Pos.Y - Y) * 40.5)) - 128));
  SetImageByDirect(Direction);
  if curStep > 0 then
  begin
    DoChanging := true;
    DoAnimate := true;
    delta_Pos.X := (Dest_Pos.X - X) / curStep;
    delta_Pos.Y := (Dest_Pos.Y - Y) / curStep;
    delta_Pos.Alpha := (Dest_Pos.Alpha - Alpha) div curStep;
    delta_Pos.Red := (Dest_Pos.Red - Red) div curStep;
    delta_Pos.Green := (Dest_Pos.Green - Green) div curStep;
    delta_Pos.Blue := (Dest_Pos.Blue - Blue) div curStep;
    delta_Pos.Angle := (Dest_Pos.Angle - Angle) / curStep;
    delta_Pos.ScaleX := (Dest_Pos.ScaleX - ScaleX) / curStep;
    delta_Pos.ScaleY := (Dest_Pos.ScaleY - ScaleY) / curStep;
  end;

end;


end.

