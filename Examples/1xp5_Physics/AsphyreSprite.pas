//---------------------------------------------------------------------------
// AsphyreSprite.pas                                    Modified: 22-Jan-2007
// Asphyre Sprite Engine
//---------------------------------------------------------------------------
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//---------------------------------------------------------------------------
// Polygon Collision detection added by M.Bansaeid
unit AsphyreSprite;

interface
uses
   Windows, Types, Classes, SysUtils, Math, AsphyreTypes, AsphyreDevices, AsphyreCanvas,
   AsphyreImages, Vectors2, AsphyreEffects, Controls, Messages, Forms, AsphyreSpriteDef,
   AsphyreSpriteUtils,AsphyreUtils;

type
 TCollideMode = (cmCircle, cmRect, cmQuadrangle, cmPolygon);
 TAnimPlayMode = (pmForward, pmBackward, pmPingPong);
 TJumpState = (jsNone, jsJumping, jsFalling);
 TImageType = (itSingleImage, itSpriteSheet);

  {  ESpriteError  }

 ESpriteError = class(Exception);

 TSpriteEngine = class;
 TSpriteClass = class of TSprite;

 TSprite = class
 private
      FEngine: TSpriteEngine;
      FParent: TSprite;
      FList: TList;
      FDrawList: TList;
      FDeaded: Boolean;
      FWidth: Integer;
      FHeight: Integer;
      FName: string;
      FX, FY: Single;
      FZ: Integer;
      FWorldX, FWorldY: Single;
      FVisible: Boolean;
      FDrawFx: Integer;
//      FDoCollision: Boolean;
      FCollisioned: Boolean;
      FImageName: string;
      FPatternIndex: Integer;
      FImageIndex: Integer;
      FMoved: Boolean;
      FCollidePos: TPoint2;
      FCollideRadius: Integer;
      FCollideRect: TRect;
      FTag: Integer;
      FCollideQuadrangle: TPoint4;
      FCollidePolygon : TAsphyrePolygon;
      FCollideMode: TCollideMode;
      procedure Add(Sprite: TSprite);
      procedure Remove(Sprite: TSprite);
      procedure AddDrawList(Sprite: TSprite);
      procedure Draw; virtual;
      function GetCount: Integer;
      function GetItem(Index: Integer): TSprite;
      function GetImageWidth: Integer;
      function GetImageHeight: Integer;
      function GetPatternWidth: Integer;
      function GetPatternHeight: Integer;
      function GetPatternCount: Integer;
 protected
      procedure DoDraw; virtual;
      procedure DoMove(const MoveCount: Single); virtual;
      procedure DoCollision(const Sprite: TSprite); virtual;
      procedure SetName(const Value: string); virtual;
      procedure SetImageName(const Value: string); virtual;
      procedure SetPatternIndex(const Value: Integer); virtual;
      procedure SetX(const Value: Single); virtual;
      procedure SetY(const Value: Single); virtual;
      procedure SetZ(const Value: Integer); virtual;
 public
      constructor Create(const AParent: TSprite); virtual;
      destructor Destroy; override;
      procedure Assign(const Value: TSprite); virtual;
      procedure Clear;
      procedure Move(const MoveCount: Single);
      procedure SetPos(X, Y: Single); overload;
      procedure SetPos(X, Y: Single; Z: Integer); overload;
      procedure Collision(const Other: TSprite); overload; virtual;
      procedure Collision; overload; virtual;
      procedure Dead;
      property Visible: Boolean read FVisible write FVisible;
      property X: Single read FX write SetX;
      property Y: Single read FY write SetY;
      property Z: Integer read FZ write SetZ;
      property ImageName: string read FImageName write SetImageName;
      property PatternIndex: Integer read FPatternIndex write SetPatternIndex;
      property ImageIndex : Integer read FImageIndex write FImageIndex;
      property ImageWidth: Integer read GetImageWidth;
      property ImageHeight: Integer read GetImageHeight;
      property PatternWidth: Integer read GetPatternWidth;
      property PatternHeight: Integer read GetPatternHeight;
      property Width: Integer read FWidth write FWidth ;
      property Height:Integer read FHeight write FHeight ;
      property PatternCount: Integer read GetPatternCount;
      property WorldX: Single read FWorldX write FWorldX;
      property WorldY: Single read FWorldY write FWorldY;
      property DrawFx: Integer read FDrawFx write FDrawFx;
      property Name: string read FName write SetName;
      property Moved: Boolean read FMoved write FMoved;
      property CollidePos: TPoint2 read FCollidePos write FCollidePos;
      property CollideRadius: Integer read FCollideRadius write FCollideRadius;
      property CollideRect: TRect read FCollideRect write FCollideRect;
      property CollideQuadrangle: TPoint4 read FCollideQuadrangle write FCollideQuadrangle;
      property CollidePolygon : TAsphyrePolygon read FCollidePolygon write FCollidePolygon;
      property CollideMode: TCollideMode read FCollideMode write FCollideMode;
      property Collisioned: Boolean read FCollisioned write FCollisioned;
      property Items[Index: Integer]: TSprite read GetItem; default;
      property Count: Integer read GetCount;
      property Engine: TSpriteEngine read FEngine write FEngine;
      property Parent: TSprite read FParent;
      property Tag: Integer read FTag write FTag;
 end;

 TSpriteEx=class(TSprite)
 private
      FX1, FY1, FX2, FY2, FX3, FY3, FX4, FY4: Single;
      FMirrorX, FMirrorY: Boolean;
      FCenterX, FCenterY: Single;
      FDoCenter: Boolean;
      FColor1, FColor2, FColor3, FColor4: Cardinal;
      FRed, FGreen, FBlue: Integer;
      FAlpha: Integer;
      FAngle: Single;
      FAngle360: Integer;
      FScaleX, FScaleY: Single;
      FOffsetX, FOffsetY: Single;
      FDrawMode: Integer;
      FImageType: TImageType;
      FSelected : Boolean;
      FGroupNumber : Integer;
      FMouseEnterFlag: Boolean;
      FMouseDownFlag: Boolean;
      FActiveRect : TRect;
 protected
      procedure SetRed(const Value: Integer); virtual;
      procedure SetGreen(const Value: Integer); virtual;
      procedure SetBlue(const Value: Integer); virtual;
      procedure SetAlpha(const Value: Integer); virtual;
      procedure SetDrawMode(const Value: Integer); virtual;
      procedure SetAngle360(Value: Integer);
      Procedure SetGroupNumber(AGroupNumber : Integer); virtual;
      Procedure SetSelected(ASelected : Boolean); virtual;
      function GetBoundsRect: TRect; virtual;
 public
      constructor Create(const AParent: TSprite); override;
      destructor Destroy; override;
      procedure Assign(const Value: TSprite); override;
      procedure DoDraw; override;
      procedure SetColor(const Color: TColor4); overload;
      procedure SetColor(Red, Green, Blue: Cardinal; Alpha: Cardinal=255); overload;
      function GetSpriteAt(X, Y: Integer): TSprite;
      function MouseInRect: Boolean;
      function SpriteInRect1(InArea: TRect): Boolean;
      function SpriteInRect2(InArea: TRect): Boolean;
      procedure DoMouseDrag;
      procedure OnMouseEnter; virtual;
      procedure OnMouseLeave; virtual;
      procedure OnMouseMove; virtual;
      procedure OnMouseClick(MX,MY:Integer); virtual;
      procedure OnMouseUp; virtual;
      procedure OnMouseDbClick; virtual;
      procedure OnMouseWheel; virtual;
      procedure OnMouseRClick; virtual;
      procedure OnMouseRUp; virtual;
      procedure OnMouseDrag(MX,MY:Integer); virtual;
      property  ActiveRect:TRect read FActiveRect write FActiveRect; //for mouse event
      property X1: Single read FX1 write FX1;
      property Y1: Single read FY1 write FY1;
      property X2: Single read FX2 write FX2;
      property Y2: Single read FY2 write FY2;
      property X3: Single read FX3 write FX3;
      property Y3: Single read FY3 write FY3;
      property X4: Single read FX4 write FX4;
      property Y4: Single read FY4 write FY4;
      property Red: Integer read FRed write SetRed default 255;
      property Green: Integer read FGreen write SetGreen default 255;
      property Blue: Integer read FBlue write SetBlue default 255;
      property Alpha: Integer read FAlpha write SetAlpha default 255;
      property Color1: Cardinal read FColor1 write FColor1;
      property Color2: Cardinal read FColor2 write FColor2;
      property Color3: Cardinal read FColor3 write FColor3;
      property Color4: Cardinal read FColor4 write FColor4;
      property Angle: Single read FAngle write FAngle;
      property Angle360: Integer  read FAngle360 write SetAngle360;
      property CenterX: Single read FCenterX write FCenterX;
      property CenterY: Single read FCenterY write FCenterY;
      property ScaleX: Single read FScaleX write FScaleX;
      property ScaleY: Single read FScaleY write FScaleY;
      property OffsetX: Single read FOffsetX write FOffsetX;
      property OffsetY: Single read FOffsetY write FOffsetY;
      property DoCenter: Boolean read FDoCenter write FDoCenter;
      property MirrorX: Boolean read FMirrorX write FMirrorX;
      property MirrorY: Boolean read FMirrorY write FMirrorY;
      property DrawMode: Integer read FDrawMode write SetDrawMode;
      property ImageType: TImageType read FImageType write FImageType;
      property BoundsRect: TRect read GetBoundsRect;
      property GroupNumber : Integer read FGroupNumber write SetGroupNumber;
      property Selected : Boolean read FSelected write SetSelected;
 end;

 TAnimatedSprite = class(TSpriteEx)
 private
      FDoAnimate: Boolean;
      FAnimLooped: Boolean;
      FAnimStart: Integer;
      FAnimCount: Integer;
      FAnimSpeed: Single;
      FAnimPos: Single;
      FAnimEnded: Boolean;
      FDoFlag1, FDoFlag2: Boolean;
      FAnimPlayMode: TAnimPlayMode;
      procedure SetAnimStart(Value: Integer);
 public
      constructor Create(const AParent: TSprite); override;
      procedure Assign(const Value: TSprite); override;
      procedure DoMove(const MoveCount: Single); override;
      procedure SetAnim(AniImageName: string; AniStart, AniCount: Integer; AniSpeed: Single; AniLooped, DoMirror, DoAnimate: Boolean; PlayMode: TAnimPlayMode=pmForward); overload; virtual;
      procedure SetAnim(AniImageName: string; AniStart, AniCount: Integer; AniSpeed: Single; AniLooped: Boolean;  PlayMode: TAnimPlayMode=pmForward); overload; virtual;
      procedure OnAnimStart; virtual;
      procedure OnAnimEnd; virtual;
      property AnimPos: Single read FAnimPos write FAnimPos;
      property AnimStart: Integer read FAnimStart write SetAnimStart;
      property AnimCount: Integer read FAnimCount write FAnimCount;
      property AnimSpeed: Single read FAnimSpeed write FAnimSpeed;
      property AnimLooped: Boolean read FAnimLooped write FAnimLooped;
      property DoAnimate: Boolean read FDoAnimate write FDoAnimate;
      property AnimEnded: Boolean read FAnimEnded;
      property AnimPlayMode: TAnimPlayMode read FAnimPlayMode write FAnimPlayMode;
 end;

 TParticleSprite = class(TAnimatedSprite)
 private
      FAccelX: Real;
      FAccelY: Real;
      FVelocityX: Real;
      FVelocityY: Real;
      FUpdateSpeed : Single;
      FDecay: Real;
      FLifeTime: Real;
 public
      constructor Create(const AParent: TSprite); override;
      procedure DoMove(const MoveCount: Single); override;
      property AccelX: Real read FAccelX write FAccelX;
      property AccelY: Real read FAccelY write FAccelY;
      property VelocityX: Real read FVelocityX write FVelocityX;
      property VelocityY: Real read FVelocityY write FVelocityY;
      property UpdateSpeed : Single read FUpdateSpeed write FUpdateSpeed;
      property Decay: Real read FDecay write FDecay;
      property LifeTime: Real read FLifeTime write FLifeTime;
 end;

 TPlayerSprite = class(TAnimatedSprite)
 private
      FSpeed: Single;
      FAcc: Single;
      FDcc: Single;
      FMinSpeed: Single;
      FMaxSpeed: Single;
      FVelocityX: Single;
      FVelocityY: Single;
      FDirection: Integer;
      procedure SetSpeed(Value: Single);
      procedure SetDirection(Value: Integer);
 public
      constructor Create(const AParent: TSprite); override;
      procedure UpdatePos;
      procedure FlipXDirection;
      procedure FlipYDirection;
      procedure Accelerate; virtual;
      procedure Deccelerate; virtual;
      property Speed: Single read FSpeed write SetSpeed;
      property MinSpeed: Single read FMinSpeed write FMinSpeed;
      property MaxSpeed: Single read FMaxSpeed write FMaxSpeed;
      property VelocityX: Single read FVelocityX write FVelocityX;
      property VelocityY: Single read FVelocityY write FVelocityY;
      property Acceleration: Single read FAcc write FAcc;
      property Decceleration: Single read FDcc write FDcc;
      property Direction: Integer read FDirection write SetDirection;
 end;

 TFaderSprite=class(TAnimatedSprite)
 private
      FMirrorCount, FCurrentColorCount, FNumColors: Integer;
      FCurCol, FMultiCols: ^TColor4;
      FMulti: Boolean;
      Counter: Single;
      FSpeed: Single;
      FLooped, FMultiFade, FMirrorFade, FFadeEnded: Boolean;
      FSrcR, FSrcG, FSrcB, FSrcA,
      FDestR, FDestG, FDestB, FDestA,
      FCurR, FCurG, FCurB, FCurA: Byte;
      procedure SetFadeSpeed(Speed: Single);
 public
      constructor Create(const AParent: TSprite); override;
      destructor Destroy; override;
      procedure DoMove(const MoveCount: Single); override;
      procedure MultiFade(Colors: array of TColor4);
      procedure SetSourceColor(Red, Green, Blue, Alpha: Byte); overload;
      procedure SetSourceColor(Color: TColor4); overload;
      procedure SetDestinationColor(Red, Green, Blue, Alpha: Byte); overload;
      procedure SetDestinationColor(Color: TColor4); overload;
      procedure FadeIn(Red, Green, Blue: Byte; Speed: Single);
      procedure FadeOut(Red, Green, Blue: Byte; Speed: Single);
      procedure SwapColors;
      procedure Reset;
      procedure Stop;
      property FadeEnded: Boolean read FFadeEnded;
      property FadeSpeed: Single read FSpeed write SetFadeSpeed;
      property MirrorFade: Boolean read FMirrorFade write FMirrorFade;
      property LoopFade: Boolean read FLooped write FLooped;
 end;

 TJumperSprite = class(TPlayerSprite)
 private
      FJumpCount: Integer;
      FJumpSpeed: Single;
      FJumpHeight: Single;
      FMaxFallSpeed: Single;
      FDoJump: Boolean;
      FJumpState: TJumpState;
      procedure SetJumpState(Value: TJumpState);
 public
      constructor Create(const AParent: TSprite); override;
      procedure DoMove(const MoveCount: Single); override;
      procedure Accelerate; override;
      procedure Deccelerate; override;
      property JumpCount: Integer read FJumpCount write FJumpCount;
      property JumpState: TJumpState read FJumpState write SetJumpState;
      property JumpSpeed: Single read FJumpSpeed write FJumpSpeed;
      property JumpHeight: Single read FJumpHeight write FJumpHeight;
      property MaxFallSpeed: Single read FMaxFallSpeed write FMaxFallSpeed;
      property DoJump: Boolean read  FDoJump write FDoJump;
 end;

 TJumperSpriteEx = class(TPlayerSprite)
 private
     FJumpCount: Integer;
     FJumpSpeed: Single;
     FJumpStartSpeed: Single;
     FJumpHeight: Single;
     FLowJumpSpeed: Single;
     FLowJumpGravity: Single;
     FHighJumpValue: Integer;
     FHighJumpSpeed: Single;
     FFallingSpeed: Single;
     FMaxFallSpeed: Single;
     FDoJump: Boolean;
     FJumpState: TJumpState;
     FHoldKey: Boolean;
     FOffset:Single;
     procedure SetJumpState(Value: TJumpState);
 public
     constructor Create(const AParent: TSprite); override;
     procedure DoMove(const MoveCount: Single); override;
     procedure Accelerate; override;
     procedure Deccelerate; override;
     property JumpStartSpeed: Single read FJumpStartSpeed write FJumpStartSpeed;
     property LowJumpSpeed: Single read FLowJumpSpeed write FLowJumpSpeed;
     property LowJumpGravity: Single read FLowJumpGravity write FLowJumpgravity;
     property HighJumpValue: Integer read  FHighJumpValue write FHighJumpValue;
     property HighJumpSpeed: Single read  FHighJumpSpeed write FHighJumpSpeed;
     property FallingSpeed: single read FFallingSpeed write FFallingSpeed;
     property HoldKey: Boolean read FHoldKey write FHoldKey;
     property JumpCount: Integer read FJumpCount write FJumpCount;
     property JumpState: TJumpState read FJumpState write SetJumpState;
     property JumpSpeed: Single read FJumpSpeed write FJumpSpeed;
     property JumpHeight: Single read FJumpHeight write FJumpHeight;
     property MaxFallSpeed: Single read FMaxFallSpeed write FMaxFallSpeed;
     property DoJump: Boolean read  FDoJump write FDoJump;
 end;

 TTileMapSprite = class(TSpriteEx)
 private
      FCollisionMap: Pointer;
      FMap: Pointer;
      FMapW :Integer;
      FMapH : Integer;
      FMapWidth: Integer;
      FMapHeight: Integer;
      FDoTile: Boolean;
      function GetCollisionMapItem(X, Y: Integer): Boolean;
      function GetCell(X, Y: Integer): Integer;
      procedure Draw; override;
      procedure SetCell(X, Y: Integer; Value: Integer);
      procedure SetCollisionMapItem(X, Y: Integer; Value: Boolean);
      procedure SetMapHeight(Value: Integer);
      procedure SetMapWidth(Value: Integer);
 protected
      procedure DoDraw; override;
      function GetBoundsRect: TRect; override;
      function TestCollision(Sprite: TSprite): Boolean;
 public
      constructor Create(const AParent: TSprite); override;
      destructor Destroy; override;
      property BoundsRect: TRect read GetBoundsRect;
      procedure SetMapSize(AMapWidth, AMapHeight: Integer);
      property Cells[X, Y: Integer]: Integer read GetCell write SetCell;
      property CollisionMap[X, Y: Integer]: Boolean read GetCollisionMapItem write SetCollisionMapItem;
      property MapHeight: Integer read FMapHeight write SetMapHeight;
      property MapWidth: Integer read FMapWidth write SetMapWidth;
      property DoTile: Boolean read FDoTile write FDoTile;
 end;

 TSpriteEngine = class(TSprite)
 private
      FAllCount: Integer;
      FDeadList: TList;
      FDrawCount: Integer;
      FWorldX, FWorldY: Single;
      FObjectsSelected : Boolean;
      FGroupCount : Integer;
      FGroups : array of TList;
      FCurrentSelected : TList;
      FCanvas: TAsphyreCanvas;
      FImage: TAsphyreImages;
      FDevice: TAsphyreDevice;
      FVisibleWidth:Integer;
      FVisibleHeight:Integer;
      FDoMouseEvent: Boolean;
      FSender: TAsphyreDevices;
      MousePoint:Tpoint;
      procedure MouseMessage(var Msg: TMsg;var Handled: Boolean);
 protected
      procedure SetGroupCount(AGroupCount : Integer); virtual;
      Function GetGroup(Index : Integer) : TList; virtual;
 public
      constructor Create(const AParent: TSprite); override;
      destructor Destroy; override;
      procedure Draw; override;
      procedure Dead;
      function Select(Point : TPoint; Filter : array of TSpriteClass;Add: Boolean = False) : TSprite; overload;
      function Select(Point : TPoint;Add: Boolean = False) : TSprite; overload;
      procedure ClearCurrent;
      procedure ClearGroup(GroupNumber : Integer);
      procedure GroupToCurrent(GroupNumber : Integer; Add: Boolean = False);
      procedure CurrentToGroup(GroupNumber : Integer; Add: Boolean = False);
      procedure GroupSelect(const Area : TRect; Filter : array of TSpriteClass; Add: Boolean = False); overload;
      procedure GroupSelect(const Area : TRect; Add: Boolean = False); overload;
      property AllCount: Integer read FAllCount;
      property DrawCount: Integer read FDrawCount;
      property Canvas: TAsphyreCanvas read FCanvas write FCanvas;
      property Image: TAsphyreImages read FImage write FImage;
      property Device: TAsphyreDevice read FDevice write FDevice;
      property VisibleWidth:Integer read FVisibleWidth write FVisibleWidth;
      property VisibleHeight: Integer read FVisibleHeight write FVisibleHeight;
      property WorldX: Single read FWorldX write FWorldX;
      property WorldY: Single read FWorldY write FWorldY;
      property CurrentSelected : TList  read FCurrentSelected;
      property ObjectsSelected : Boolean read FObjectsSelected;
      property Groups[index : Integer] : Tlist read GetGroup;
      property GroupCount : Integer read FGroupCount write SetGroupCount;
      property DoMouseEvent: Boolean read FDoMouseEvent  write FDoMouseEvent;
      property Sender: TAsphyreDevices read FSender write FSender;
 end;

implementation

{  TSprite }
constructor TSprite.Create(const AParent: TSprite);
begin
     inherited Create;

     FParent := AParent;
     if FParent<>nil then
     begin
          FParent.Add(Self);
          if FParent is TSpriteEngine then
              FEngine := TSpriteEngine(FParent)
          else
              FEngine := FParent.Engine;
          Inc(FEngine.FAllCount);
     end;
     FX := 200;
     FY := 200;
     FZ := 0;
     FWidth := 64;
     FHeight:= 64;
     FName := '';
     FZ := 0;
     FPatternIndex := 0;
//     FDoCollision := False;
     FMoved := True;
     FDrawFx := FxuBlend;
     FVisible := True;
     FTag := 0;
end;

destructor TSprite.Destroy;
begin

     Clear;
     if FParent<>nil then
     begin
          Dec(FEngine.FAllCount);
          FParent.Remove(Self);
          FEngine.FDeadList.Remove(Self);
     end;
     FList.Free;
     FDrawList.Free;
     inherited Destroy;
end;

procedure TSprite.Assign(const Value: TSprite);
begin
     FName := Value.Name;
     FImageName := Value.ImageName;
     FX  := Value.X;
     FY  := Value.Y;
     FZ  := Value.Z;
     FWorldX  := Value.WorldX;
     FWorldY  := Value.WorldY;
     FPatternIndex := Value.PatternIndex;
     FImageIndex := Value.ImageIndex;
     FCollideMode := Value.CollideMode;
     FCollisioned := Value.Collisioned;
     FCollidePos := Value.CollidePos;
     FCollideRadius := Value.CollideRadius;
     FCollideRect := Value.CollideRect;
     FCollideQuadrangle := Value.CollideQuadrangle;
     FMoved := Value.Moved;
     FDrawFx := Value.DrawFx;
     FVisible := Value.Visible;
     FTag := Value.Tag;
end;

procedure TSprite.Add(Sprite: TSprite);
begin
     if FList=nil then
     begin
          FList := TList.Create;
          FDrawList := TList.Create;
     end;
     FList.Add(Sprite);
     AddDrawList(Sprite);
end;

procedure TSprite.Remove(Sprite: TSprite);
begin
     FList.Remove(Sprite);
     FDrawList.Remove(Sprite);
     if FList.Count=0 then
     begin
          FList.Free;
          FList := nil;
          FDrawList.Free;
          FDrawList := nil;
     end;
end;

procedure TSprite.AddDrawList(Sprite: TSprite);
var
  L, H, I, C: Integer;
begin
     L := 0;
     H := FDrawList.Count - 1;
     while L <= H do
     begin
          I := (L + H) div 2;
          C := TSprite(FDrawList[I]).Z-Sprite.Z;
          if C < 0 then
              L := I + 1
          else
              H := I - 1;
     end;
     FDrawList.Insert(L, Sprite);
end;

procedure TSprite.Clear;
begin
     while Count>0 do
         Items[Count-1].Free;
end;

procedure TSprite.Dead;
begin
     if (FEngine<>nil) and (not FDeaded) then
     begin
          FDeaded := True;
          FEngine.FDeadList.Add(Self);
    end;
end;

procedure TSprite.DoMove;
begin
end;

procedure TSprite.Move(const MoveCount: Single);
var
  i: Integer;
begin
     if FMoved then
     begin
          DoMove(MoveCount);
          for i:=0 to Count-1 do
              Items[i].Move(MoveCount);
     end;
end;

procedure TSprite.Draw;
var
  i: Integer;
begin
     if FVisible then
     begin
          if FEngine<>nil then
          begin
               if (X > FEngine.WorldX-Width ) and
               (Y > FEngine.WorldY-Height)    and
               (X < FEngine.WorldX +FEngine.VisibleWidth)  and
               (Y < FEngine.WorldY +FEngine.VisibleHeight) then
               begin
                    DoDraw;
                    Inc(FEngine.FDrawCount);
               end;
          end;
          if FDrawList<>nil then
          begin
               for i:=0 to FDrawList.Count-1 do
                   TSprite(FDrawList[i]).Draw;
          end;
     end;
end;


function TSprite.GetCount: Integer;
begin
     if FList<>nil then
         Result := FList.Count
     else
         Result := 0;
end;

function TSprite.GetItem(Index: Integer): TSprite;
begin
     if FList<>nil then
         Result := FList[Index]
     else
         raise ESpriteError.CreateFmt('Index of the list exceeds the range. (%d)', [Index]);
end;

function TSprite.GetImageWidth: Integer;
begin
     Result := TAsphyreImage(FEngine.Image.Image[FImageName]).PatternSize.X;
end;

function TSprite.GetImageHeight: Integer;
begin
     Result := TAsphyreImage(FEngine.Image.Image[FImageName]).PatternSize.Y;
end;

function TSprite.GetPatternWidth: Integer;
begin
     Result := TAsphyreImage(FEngine.Image.Image[FImageName]).PatternSize.X;
end;

function TSprite.GetPatternHeight: Integer;
begin
     Result := TAsphyreImage(FEngine.Image.Image[FImageName]).PatternSize.Y;
end;

function TSprite.GetPatternCount: Integer;
begin
     Result := TAsphyreImage(FEngine.Image.Image[FImageName]).PatternCount;
end;

procedure TSprite.DoDraw;
begin
     if not FVisible then Exit;
     DrawEx(FEngine.FCanvas,
            FEngine.FImage.Image[ImageName],
                           FPatternIndex,
                           (FX + FWorldX - (FEngine.FWorldX)),
                           (FY + FWorldY - (FEngine.FWorldY)),
                           clWhite4,
                           FDrawFx);
end;


procedure TSprite.SetPos(X, Y: Single);
begin
     FX := X;
     FY := Y;
end;

procedure TSprite.SetPos(X, Y: Single; Z: Integer);
begin
     FX := X;
     FY := Y;
     FZ := Z;
end;


procedure TSprite.SetName(const Value: string);
begin
     Self.FName := Value;
end;

procedure TSprite.SetPatternIndex(const Value: Integer);
begin
     Self.FPatternIndex := Value;
     if FImageName = ' ' then Exit;
end;

procedure TSprite.SetImageName(const Value: string);
begin
     Self.FImageName := Value;
end;

procedure TSprite.SetX(const Value: Single);
begin
     Self.FX := Value;
end;

procedure TSprite.SetY(const Value: Single);
begin
     Self.FY := Value;
end;

procedure TSprite.SetZ(const Value: Integer);
begin
     if FZ<>Value then
     begin
          FZ := Value;
          if Parent<>nil then
          begin
               Parent.FDrawList.Remove(Self);
               Parent.AddDrawList(Self);
          end;
     end;
end;

procedure TSprite.Collision(const Other: TSprite);
var
     Delta: Real;
     IsCollide: Boolean;
begin
     IsCollide := False;

     if (FCollisioned) and (Other.FCollisioned) and (not FDeaded)and (not Other.FDeaded) then
     begin
          case FCollideMode of
               cmCircle:
               begin
                    Delta := Sqrt(Sqr(Self.CollidePos.X - Other.CollidePos.X) +
                             Sqr(Self.CollidePos.Y - Other.CollidePos.Y));
                    IsCollide := (Delta < (Self.CollideRadius + Other.CollideRadius));
               end;
               cmRect:
               begin
                    IsCollide := OverlapRect(Self.CollideRect, Other.CollideRect);
               end;
               cmQuadrangle:
               begin
                    IsCollide := OverlapQuadrangle(Self.CollideQuadrangle, Other.CollideQuadrangle);
               end;
               cmPolygon:
               begin
                    IsCollide := OverlapPolygon(Self.CollidePolygon, Other.CollidePolygon);
               end;
          end;

          if IsCollide then
          begin
               DoCollision(Other);
               Other.DoCollision(Self);
          end;
     end;
end;

procedure TSprite.Collision;
var
   i: Integer;
begin
     if (FEngine<>nil) and (not FDeaded) and (Collisioned) then
     begin
          for i:=0 to Engine.Count-1 do
              Self.Collision(Engine.Items[i]);
     end;
end;

procedure TSprite.DoCollision(const Sprite: TSprite);
begin
end;

{TSpriteEx}
constructor TSpriteEx.Create(const AParent: TSprite);
begin
     inherited;
     FGroupNumber := -1;
     FImageType := itSpriteSheet;
     FColor1 := $FFFFFFFF;
     FColor2 := $FFFFFFFF;
     FColor3 := $FFFFFFFF;
     FColor4 := $FFFFFFFF;
     FCenterX := 0;
     FCenterY := 0;
     FX1 := 0;
     FY1 := 0;
     FX2 := 10;
     FY2 := 0;
     FX3 := 10;
     FY3 := 10;
     FX4 := 0;
     FY4 := 10;
     FRed := 255;
     FGreen := 255;
     FBlue := 255;
     FAlpha := 255;
     FAngle := 0;
     FScaleX := 1;
     FScaleY := 1;
     FDoCenter := False;
     FOffsetX := 0;
     FOffsetY := 0;
     FMirrorX := False;
     FMirrorY := False;
     FDrawMode := 0;
     FMouseEnterFlag := False;
     FMouseDownFlag:= False;
end;

destructor TSpriteEx.Destroy;
begin
     GroupNumber := -1;
     Selected := False;
     inherited Destroy;
end;

procedure TSpriteEx.Assign(const Value: TSprite);
begin
     FImageType := TSpriteEx(Value).ImageType;
     FX1 := TSpriteEx(Value).X1;
     FY1 := TSpriteEx(Value).Y1;
     FX2 := TSpriteEx(Value).X2;
     FY2 := TSpriteEx(Value).Y2;
     FX3 := TSpriteEx(Value).X3;
     FY3 := TSpriteEx(Value).Y3;
     FX4 := TSpriteEx(Value).X4;
     FY4 := TSpriteEx(Value).Y4;
     FOffsetX := TSpriteEx(Value).OffsetX;
     FOffsetY := TSpriteEx(Value).OffsetY;
     FCenterX := TSpriteEx(Value).CenterX;
     FCenterY := TSpriteEx(Value).CenterY;
     FMirrorX := TSpriteEx(Value).MirrorX;
     FMirrorY := TSpriteEx(Value).MirrorY;
     FScaleX := TSpriteEx(Value).ScaleX;
     FScaleY := TSpriteEx(Value).ScaleY;
     FDoCenter := TSpriteEx(Value).DoCenter;
     FRed := TSpriteEx(Value).Red;
     FGreen := TSpriteEx(Value).Green;
     FBlue := TSpriteEx(Value).Blue;
     FAlpha := TSpriteEx(Value).Alpha;
     FColor1 := TSpriteEx(Value).Color1;
     FColor2 := TSpriteEx(Value).Color2;
     FColor3 := TSpriteEx(Value).Color3;
     FColor4 := TSpriteEx(Value).Color4;
     Angle := TSpriteEx(Value).Angle;
     FDrawMode := TSpriteEx(Value).DrawMode;
end;

function TSpriteEx.GetSpriteAt(X, Y: Integer): TSprite;

  procedure Collision_GetSpriteAt(X, Y: Double; Sprite: TSprite);
  var
    i: Integer;
    X2, Y2: Double;
  begin
    if Sprite.Visible and PointInRect(Point(Round(X), Round(Y))
       ,Bounds(Round(Sprite.X), Round(Sprite.Y), Sprite.Width, Sprite.Height)) then
       begin
            if (Result=nil) or (Sprite.Z>Result.Z) then
               Result := Sprite;
       end;

       X2 := X-Sprite.X;
       Y2 := Y-Sprite.Y;
       for i:=0 to Sprite.Count-1 do
          Collision_GetSpriteAt(X2, Y2, Sprite.Items[i]);
  end;

var
  i: Integer;
  X2, Y2: Double;
begin
     Result := nil;
     X2 := X-Self.X;
     Y2 := Y-Self.Y;
     for i:=0 to Count-1 do
        Collision_GetSpriteAt(X2, Y2, Items[i]);
end;

procedure TSpriteEx.DoDraw;
var
     ImgName: string;
begin
     if not FVisible then Exit;
     case ImageType of
          itSingleImage: ImgName := FImageName + IntToStr(FImageIndex);
          itSpriteSheet: ImgName := FImageName;
     end;
     
     case FDrawMode of
          //1 color mode
          0: DrawColor1( FEngine.FCanvas,
                         FEngine.Image.Image[ImgName],
                         FPatternIndex,
                         Trunc(FX + FWorldX + FOffsetX - Trunc(FEngine.FWorldX)),
                         Trunc(FY + FWorldY + FOffsetY - Trunc(FEngine.FWorldY)),
                         FScaleX, FScaleY, FDoCenter,
                         FMirrorX, FMirrorY,
                         FRed, FGreen, FBlue, FAlpha, FDrawFx);

           // 1 color mode +Rotaton,  no CenterX,CenterY
           1:            DrawRotateC(
                         FEngine.FCanvas,
                         FEngine.Image.Image[ImgName],
                         FPatternIndex,
                         Trunc(FX + FWorldX + FOffsetX - Trunc(FEngine.FWorldX)),
                         Trunc(FY + FWorldY + FOffsetY - Trunc(FEngine.FWorldY)),
                         FAngle, FScaleX, FScaleY,
                         FMirrorX, FMirrorY,
                         cRGB4(FRed, FGreen, FBlue, FAlpha), FDrawFx);

               //4 color mode
            2:           DrawColor4(
                         FEngine.FCanvas,
                         FEngine.Image.Image[ImgName],
                         FPatternIndex,
                         Trunc(FX + FWorldX + FOffsetX - Trunc(FEngine.FWorldX)),
                         Trunc(FY + FWorldY + FOffsetY - Trunc(FEngine.FWorldY)),
                         FScaleX, FScaleY, FDoCenter,
                         FMirrorX, FMirrorY,
                         Color1, Color2, Color3, Color4, FDrawFx);

            //1 color  mode+transform
            3:           DrawTransForm(
                         FEngine.FCanvas,
                         FEngine.Image.Image[ImgName],
                         FPatternIndex,
                         Trunc(FX1 + FWorldX + FOffsetX - Trunc(FEngine.FWorldX)), Trunc(FY1 + FWorldY + FOffsetY - Trunc(FEngine.FWorldY)),
                         Trunc(FX2 + FWorldX + FOffsetX - Trunc(FEngine.FWorldX)), Trunc(FY2 + FWorldY + FOffsetY - Trunc(FEngine.FWorldY)),
                         Trunc(FX3 + FWorldX + FOffsetX - Trunc(FEngine.FWorldX)), Trunc(FY3 + FWorldY + FOffsetY - Trunc(FEngine.FWorldY)),
                         Trunc(FX4 + FWorldX + FOffsetX - Trunc(FEngine.FWorldX)), Trunc(FY4 + FWorldY + FOffsetY - Trunc(FEngine.FWorldY)),
                         FMirrorX, FMirrorY,
                         cRGB4(FRed, FGreen, FBlue, FAlpha), FDrawFx);

            //4 color mode+transform
            4:           DrawTransForm(
                         FEngine.FCanvas,
                         FEngine.Image.Image[ImgName],
                         FPatternIndex,
                         Trunc(FX1 + FWorldX + FOffsetX - Trunc(FEngine.FWorldX)), Trunc(FY1 + FWorldY + FOffsetY - Trunc(FEngine.FWorldY)),
                         Trunc(FX2 + FWorldX + FOffsetX - Trunc(FEngine.FWorldX)), Trunc(FY2 + FWorldY + FOffsetY - Trunc(FEngine.FWorldY)),
                         Trunc(FX3 + FWorldX + FOffsetX - Trunc(FEngine.FWorldX)), Trunc(FY3 + FWorldY + FOffsetY - Trunc(FEngine.FWorldY)),
                         Trunc(FX4 + FWorldX + FOffsetX - Trunc(FEngine.FWorldX)), Trunc(FY4 + FWorldY + FOffsetY - Trunc(FEngine.FWorldY)),
                         FMirrorX, FMirrorY,
                         cColor4(Color1, Color2, Color3, Color4), FDrawFx);
     end;
end;

procedure TSpriteEx.SetColor(const Color: TColor4);
begin
    //
end;

procedure TSpriteEx.SetColor(Red, Green, Blue: Cardinal; Alpha: Cardinal=255);
begin
     FRed := Red;
     FGreen := Green;
     FBlue := Blue;
     FAlpha := Alpha;
end;

procedure TSpriteEx.SetRed(const Value: Integer);
begin
     inherited;
     Self.FRed := Value;
     SetColor(cRGB4(FRed, FGreen, FBlue, FAlpha));
end;

procedure TSpriteEx.SetGreen(const Value: Integer);
begin
     inherited;
     Self.FGreen := Value;
     SetColor(cRGB4(FRed, FGreen, FBlue, FAlpha));
end;

procedure TSpriteEx.SetBlue(const Value: Integer);
begin
     inherited;
     Self.FBlue := Value;
     SetColor(cRGB4(FRed, FGreen, FBlue, FAlpha));
end;

procedure TSpriteEx.SetAlpha(const Value: Integer);
begin
     inherited;
     Self.FAlpha := Value;
     SetColor(cRGB4(FRed, FGreen, FBlue, FAlpha));
end;

procedure TSpriteEx.SetAngle360(Value: Integer);
begin
     if FAngle360 <> Value then
         FAngle:= DegToRad(Value);
end;

procedure TSpriteEx.SetDrawMode(const Value: Integer);
begin
     Self.FDrawMode := Value;
     if FDrawMode > 4 then FDrawMode := 0;
end;

procedure TSpriteEx.SetGroupNumber(AGroupNumber : Integer);
begin
     if (AGroupNumber <> GroupNumber) and  (Engine <> nil) then
     begin
          if Groupnumber >= 0 then
              Engine.Groups[GroupNumber].Remove(Self);
          if AGroupNumber >= 0 then
              Engine.Groups[AGroupNumber].Add(Self);
     end;
end;

procedure TSpriteEx.SetSelected(ASelected : Boolean);
begin
     if (ASelected <> FSelected) and  (Engine <> nil) then
     begin
          FSelected := ASelected;
          if Selected then
              Engine.CurrentSelected.Add(Self)
          else
              Engine.CurrentSelected.Remove(Self);
              Engine.FObjectsSelected := Engine.CurrentSelected.Count <> 0;
     end;
end;

function TSpriteEx.GetBoundsRect: TRect;
begin
     Result := Bounds(Round(FX), Round(FY), Round(FX+Width), Round(FY+Height));
end;

function TSpriteEx.MouseInRect: Boolean;
var
pt:TPoint;
begin
     Result:= PtInRect(Rect(FActiveRect.Left-Trunc(FEngine.WorldX),
                            FActiveRect.Top -Trunc(FEngine.WorldY),
                            FActiveRect.Right -Trunc(FEngine.WorldX),
                            FActiveRect.Bottom-Trunc(FEngine.WorldY)),
                            Engine.MousePoint);

end;

function TSpriteEx.SpriteInRect1(InArea: TRect): Boolean;
begin
     Result := RectInRect(FActiveRect, InArea);
end;

function TSpriteEx.SpriteInRect2(InArea: TRect): Boolean;
begin
     Result := RectInRect(Rect(FActiveRect.Left-Trunc(FEngine.WorldX),
                               FActiveRect.Top -Trunc(FEngine.WorldY),
                               FActiveRect.Right -Trunc(FEngine.WorldX),
                               FActiveRect.Bottom-Trunc(FEngine.WorldY)),
                               InArea);
end;

procedure TSpriteEx.DoMouseDrag;
begin
     if FMouseDownFlag=True then
       OnMouseDrag(Engine.MousePoint.x,Engine.MousePoint.Y);
end;

procedure TSpriteEx.OnMouseEnter;
begin
    //
end;

procedure TSpriteEx.OnMouseLeave;
begin
    //
end;

procedure TSpriteEx.OnMouseMove;
begin
    //
end;

procedure TSpriteEx.OnMouseClick(MX,MY:Integer);
begin
   //
end;

procedure TSpriteEx.OnMouseUp;
begin
    //
end;

procedure TSpriteEx.OnMouseDbClick;
begin
    //
end;

procedure TSpriteEx.OnMouseRClick;
begin
    //
end;

procedure TSpriteEx.OnMouseRUp;
begin
    //
end;

procedure TSpriteEx.OnMouseWheel;
begin
    //
end;

procedure TSpriteEx.OnMouseDrag(MX,MY:Integer);
begin
   //
end;


{  TAnimatedSprite  }
constructor TAnimatedSprite.Create(const AParent: TSprite);
begin
     inherited;
     FDoAnimate := False;
     FAnimLooped := True;
     FAnimStart := 0;
     FAnimCount := 0;
     FAnimSpeed := 0;
     FAnimPos := 0;
     FAnimPlayMode := pmForward;
     FDoFlag1 := False;
     FDoFlag2 := False;
end;

procedure TAnimatedSprite.Assign(const Value: TSprite);
begin
     if (Value is TAnimatedSprite) then
     begin
          DoAnimate := TAnimatedSprite(Value).DoAnimate;
          AnimStart := TAnimatedSprite(Value).AnimStart;
          AnimCount := TAnimatedSprite(Value).AnimCount;
          AnimSpeed := TAnimatedSprite(Value).AnimSpeed;
          AnimLooped := TAnimatedSprite(Value).AnimLooped;
     end;
     inherited;
end;

procedure TAnimatedSprite.SetAnimStart(Value: Integer);
begin
     if FAnimStart <> Value then
     begin
          FAnimStart := Value;
          FAnimPos := Value;
     end;
end;

procedure TAnimatedSprite.DoMove(const MoveCount: Single);
begin
     if not FDoAnimate then Exit;
     case FAnimPlayMode of
          pmForward: //12345 12345  12345
          begin
               FAnimPos := FAnimPos + FAnimSpeed * MoveCount;
               if (FAnimPos >= FAnimStart + FAnimCount ) then
               begin
                    if (Trunc(AnimPos))= FAnimStart then OnAnimStart;
                    if (Trunc(FAnimPos)) = FAnimStart + FAnimCount then
                    begin
                         FAnimEnded := True;
                         OnAnimEnd;
                    end;

                    if FAnimLooped then
                       FAnimPos := FAnimStart
                    else
                    begin
                         FAnimPos := FAnimStart + FAnimCount-1 ;
                         FDoAnimate := False;
                    end;
               end;
          end;
          pmBackward: //54321 54321 54321
          begin
               FAnimPos := FAnimPos - FAnimSpeed * MoveCount;
               if (FAnimPos < FAnimStart) then
                   if FAnimLooped then
                        FAnimPos := FAnimStart + FAnimCount - 1
               else
               begin
                    FAnimPos := FAnimStart;
                    FDoAnimate := False;
               end;
          end;
          pmPingPong: // 12345432123454321
          begin
               FAnimPos := FAnimPos + FAnimSpeed * MoveCount;
               if FAnimLooped then
               begin
                    if (FAnimPos > FAnimStart + FAnimCount - 1) or (FAnimPos < FAnimStart) then
                        FAnimSpeed := -FAnimSpeed;
               end
               else
               begin
                    if (FAnimPos > FAnimStart + FAnimCount) or (FAnimPos < FAnimStart) then
                         FAnimSpeed := -FAnimSpeed;
                    if (Trunc(FAnimPos)) = (FAnimStart + FAnimCount) then
                              FDoFlag1 := True;
                    if (Trunc(FAnimPos) = FAnimStart) and (FDoFlag1) then
                              FDoFlag2 := True;
                    if (FDoFlag1) and (FDoFlag2) then
                    begin
                         //FAnimPos := FAnimStart;
                         FDoAnimate := False;
                         FDoFlag1 := False;
                         FDoFlag2 := False;
                    end;
               end;
          end;
     end;
     FPatternIndex := Trunc(FAnimPos);
     FImageIndex := Trunc(FAnimPos);
end;

procedure TAnimatedSprite.SetAnim(AniImageName: string; AniStart, AniCount: Integer; AniSpeed: Single; AniLooped, DoMirror, DoAnimate: Boolean;
                  PlayMode: TAnimPlayMode=pmForward);
begin
     ImageName := AniImageName;
     FAnimStart := AniStart;
     FAnimCount := AniCount;
     FAnimSpeed := AniSpeed;
     FAnimLooped:= AniLooped;
     MirrorX := DoMirror;
     FDoAnimate := DoAnimate;
     FAnimPlayMode := PlayMode;
     //如果不加下面这句，FPatternIndex有可能超过AniCount，出现白框
     if (FPatternIndex<FAnimStart) or (FPatternIndex>=FAnimCount+FAnimStart)
       then
     begin
       FPatternIndex:=FAnimStart mod FAnimCount;
       FAnimPos:=FAnimStart;
     end;

end;

procedure TAnimatedSprite.SetAnim(AniImageName: string; AniStart, AniCount: Integer; AniSpeed: Single; AniLooped: Boolean;
                  PlayMode: TAnimPlayMode=pmForward);
begin
     ImageName := AniImageName;
     FAnimStart := AniStart;
     FAnimCount := AniCount;
     FAnimSpeed := AniSpeed;
     FAnimLooped:= AniLooped;
     FAnimPlayMode := PlayMode;
     if (FPatternIndex<FAnimStart) or (FPatternIndex>=FAnimCount+FAnimStart) then
     begin
       FPatternIndex:=FAnimStart mod FAnimCount;
       FAnimPos:=FAnimStart;
     end;
end;

procedure TAnimatedSprite.OnAnimStart;
begin
    //
end;

procedure TAnimatedSprite.OnAnimEnd;
begin
    //
end;

{ TParticleSprite}
constructor TParticleSprite.Create(const AParent: TSprite);
begin
     inherited;
     FAccelX := 0;
     FAccelY := 0;
     FVelocityX := 0;
     FVelocityY := 0;
     FUpdateSpeed :=0;
     FDecay := 0;
     FLifeTime := 1;
end;

procedure TParticleSprite.DoMove(const MoveCount: Single);
begin
     inherited;
     X:= X + FVelocityX * UpdateSpeed;
     Y:= Y + FVelocityY * UpdateSpeed;
     FVelocityX := FVelocityX + FAccelX * UpdateSpeed;
     FVelocityY := FVelocityY + FAccelY * UpdateSpeed;
     FLifeTime := FLifeTime - FDecay;
     if FLifeTime <= 0 then Dead;
end;

{  TPlayerSprite   }
constructor TPlayerSprite.Create(const AParent: TSprite);
begin
     inherited;
     FVelocityX := 0;
     FVelocityY := 0;
     Acceleration := 0;
     Decceleration := 0;
     Speed := 0;
     MinSpeed := 0;
     MaxSpeed := 0;
     FDirection := 0;
end;

procedure TPlayerSprite.SetSpeed(Value: Single);
begin
     if FSpeed > FMaxSpeed then
          FSpeed := FMaxSpeed
     else
          if FSpeed < FMinSpeed then
               FSpeed := FMinSpeed;
     FSpeed := Value;
     VelocityX := Cos256(FDirection+192) * Speed;
     VelocityY := Sin256(FDirection+192) * Speed;
end;

procedure TPlayerSprite.SetDirection(Value: Integer);
begin
     FDirection := Value;
     VelocityX := Cos256(FDirection+192) * Speed;
     VelocityY := Sin256(FDirection+192) * Speed;
end;

procedure TPlayerSprite.FlipXDirection;
begin
     if FDirection >= 64 then
          FDirection := 192 + (64 - FDirection)
     else
          if FDirection > 0 then
               FDirection := 256 - FDirection;
end;

procedure TPlayerSprite.FlipYDirection;
begin
     if FDirection > 128 then
          FDirection := 128 + (256 - FDirection)
     else
          FDirection := 128 - FDirection;
end;

procedure TPlayerSprite.Accelerate;
begin
     if FSpeed <> FMaxSpeed then
     begin
          FSpeed := FSpeed + FAcc;
          if FSpeed > FMaxSpeed then
               FSpeed := FMaxSpeed;
          VelocityX := Cos256(FDirection+192) * Speed;
          VelocityY := Sin256(FDirection+192) * Speed;
     end;
end;

procedure TPlayerSprite.Deccelerate;
begin
     if FSpeed <> FMinSpeed then
     begin
          FSpeed := FSpeed - FDcc;
          if FSpeed < FMinSpeed then
               FSpeed := FMinSpeed;
          VelocityX := Cos256(FDirection+192) * Speed;
          VelocityY := Sin256(FDirection+192) * Speed;
     end;
end;

procedure TPlayerSprite.UpdatePos;
begin
     inherited;
     X := X + VelocityX;
     Y := Y + VelocityY;
end;

{TFaderSprite}
procedure TFaderSprite.DoMove(const MoveCount: Single);
   var a, b: Single;
begin
     inherited;
     FFadeEnded := False;
     a := Counter * 0.01;
     b := 1 - a;
     FCurR := Round(FSrcR * b + a * FDestR);
     FCurG := Round(FSrcG * b + a * FDestG);
     FCurB := Round(FSrcB * b + a * FDestB);
     FCurA := Round(FSrcA * b + a * FDestA);
     Counter := Counter + FSpeed;
     if Counter >= 100 then
     begin
          if FMultiFade then
          begin
               Inc(FCurrentColorCount);
               if FCurrentColorCount > FNumColors then
               begin
                    if FLooped then
                    begin
                         Counter := 0;
                         FCurrentColorCount := 0;
                         FCurCol := FMultiCols;
                         SetSourceColor(FCurR, FCurG, FCurB, FCurA);
                         SetDestinationColor(FCurCol^);
                         Exit;
                    end
                    else
                    begin
                         Counter := 100;
                         FFadeEnded := True;
                         FMultiFade := False;
                         FMulti := False;
                         Freemem(FMultiCols);
                    end;
                    Exit;
               end;
               Inc(FCurCol);
               Counter := 0;
               SetSourceColor(FCurR, FCurG, FCurB, FCurA);
               SetDestinationColor(FCurCol^);
          end
          else
          if FMirrorFade then
          begin
               Inc(FMirrorCount);
               if (FMirrorCount > 1) and (FLooped = false) then
               begin
                    Counter := 100;
                    FFadeEnded := True;
               end
               else
               begin
                    Counter := 0;
                    SetDestinationColor(FSrcR, FSrcG, FSrcB, FSrcA);
                    SetSourceColor(FCurR, FCurG, FCurB, FCurA);
               end;
          end
          else
          begin
               if (FLooped) then Counter := 0
               else
               begin
                    Counter := 100;
                    FFadeEnded := True;
               end;
          end;
     end;
     Self.Red:=FCurR;
     Self.Green:=FCurG;
     Self.Blue:=FCurB;
     Self.Alpha:=FCurA;
end;

procedure TFaderSprite.Reset;
begin
     Counter := 0;
     FMirrorCount := 0;
     FFadeEnded := False;
end;

procedure TFaderSprite.SetSourceColor(Red, Green, Blue, Alpha: Byte);
begin
     FSrcR := Red;
     FSrcG := Green;
     FSrcB := Blue;
     FSrcA := Alpha;
     FCurR := Red;
     FCurG := Green;
     FCurB := Blue;
     FCurA := Alpha;
end;

procedure TFaderSprite.SetDestinationColor(Red, Green, Blue, Alpha: Byte);
begin
     FDestR := Red;
     FDestG := Green;
     FDestB := Blue;
     FDestA := Alpha;
end;

procedure TFaderSprite.SetDestinationColor(Color: TColor4);
begin
     SetDestinationColor(cRGB4(Red, Green, Blue , Alpha));
end;

procedure TFaderSprite.SetSourceColor(Color: TColor4);
begin
     SetSourceColor(cRGB4(Red, Green, Blue, Alpha));
end;

procedure TFaderSprite.SetFadeSpeed(Speed: Single);
begin
     if Speed > 100 then Speed := 100;
     if Speed < 0 then Speed := 0;
     FSpeed := Speed;
end;

constructor  TFaderSprite.Create(const AParent: TSprite);
begin
     inherited;
     FMultiFade := False;
     FLooped := False;
     FMulti := False;

     SetFadeSpeed(0.1);
     SetSourceColor(0, 0, 0, 0);
     SetDestinationColor(0, 0, 0, 255);
     FMirrorFade := False;
     FMirrorCount := 0;
     Reset;
end;

destructor TFaderSprite.Destroy;
begin
     if FMulti {FMultiCols<>nil{assigned(FMultiCols)} then Freemem(FMultiCols);
     inherited Destroy;;
end;

procedure TFaderSprite.SwapColors;
begin
     FCurR := FDestR;
     FCurG := FDestG;
     FCurB := FDestB;
     FCurA := FDestA;
     FDestR := FSrcR;
     FDestG := FSrcG;
     FDestB := FSrcB;
     FDestA := FSrcA;
     FSrcR := FCurR;
     FSrcG := FCurG;
     FSrcB := FCurB;
     FSrcA := FCurA;
end;

procedure TFaderSprite.FadeIn(Red, Green, blue: Byte; Speed: Single);
begin
     SetSourceColor(Red, Green, Blue, 0);
     SetDestinationColor(Red, green, Blue, 255);
     SetFadeSpeed(Speed);
     Reset;
end;

procedure TFaderSprite.FadeOut(Red, Green, Blue: Byte; Speed: Single);
begin
     SetSourceColor(Red, Green, Blue, 255);
     SetDestinationColor(Red, Green, Blue, 0);
     SetFadeSpeed(Speed);
     Reset;
end;

procedure TFaderSprite.MultiFade(Colors: array of TColor4);
begin
     GetMem(FMultiCols, SizeOf(Colors));
     FMulti := True;
     System.Move(Colors, FMultiCols^, SizeOf(Colors));
     FNumColors := High(Colors);
     if FNumColors < 0 then Exit;
     SetSourceColor(Colors[0]);
     if FNumColors > 0 then SetDestinationColor(Colors[1]);
     FCurrentColorCount := 0;
     FCurCol := FMultiCols;
     Inc(FCurCol);
     FMultiFade := True;
     Reset;
end;

procedure TFaderSprite.Stop;
begin
     FFadeEnded := True;
end;

{ TJumperSprite }
constructor TJumperSprite.Create(const AParent: TSprite);
begin
     inherited;
     FVelocityX := 0;
     FVelocityY := 0;
     MaxSpeed := FMaxSpeed;
     FDirection := 0;
     FJumpState := jsNone;
     FJumpSpeed := 0.25;
     FJumpHeight := 8;
     Acceleration := 0.2;
     Decceleration := 0.2;
     FMaxFallSpeed := 5;
     DoJump:= False;
end;

procedure TJumperSprite.SetJumpState(Value: TJumpState);
begin
     if FJumpState <> Value then
     begin
          FJumpState := Value;
          case Value of
               jsNone,
               jsFalling:
               begin
                    FVelocityY := 0;
               end;
          end;
     end;
end;

procedure TJumperSprite.Accelerate;
begin
     if FSpeed <> FMaxSpeed then
     begin
          FSpeed:= FSpeed+FAcc;
          if FSpeed > FMaxSpeed then
             FSpeed := FMaxSpeed;
          VelocityX := Cos256(FDirection) * Speed;
     end;
end;

procedure TJumperSprite.Deccelerate;
begin
     if FSpeed <> FMaxSpeed then
     begin
          FSpeed:= FSpeed+FAcc;
          if FSpeed < FMaxSpeed then
             FSpeed := FMaxSpeed;
          VelocityX := Cos256(FDirection) * Speed;
     end;
end;

procedure TJumperSprite.DoMove(const MoveCount: Single);
begin
     inherited;
     case FJumpState of
          jsNone:
          begin
               if DoJump then
               begin
                    FJumpState := jsJumping;
                    VelocityY := -FJumpHeight;
               end;
          end;
          jsJumping:
          begin
               Y:=Y+FVelocityY;
               VelocityY:=FVelocityY+FJumpSpeed;
               if VelocityY > 0 then
                  FJumpState := jsFalling;
          end;
          jsFalling:
          begin
               Y:=Y+FVelocityY;
               VelocityY:=VelocityY+FJumpSpeed;
               if VelocityY > FMaxFallSpeed then
                  VelocityY := FMaxFallSpeed;
          end;
     end;
     DoJump := False;
end;

{ TJumperSpriteEx }
constructor TJumperSpriteEx.Create(const AParent: TSprite);
begin
     inherited;
     FVelocityX := 0;
     FVelocityY := 0;
     MaxSpeed := FMaxSpeed;
     FDirection := 0;
     FJumpState := jsNone;
     FJumpSpeed := 0.2;
     FJumpStartSpeed := 0.2;
     FLowJumpSpeed := 0.185;
     FLowJumpGravity :=0.6;
     FHighJumpValue:=1000;
     FHighJumpSpeed:=0.1;
     FFallingSpeed:=0.2;
     FJumpCount := 0;
     FJumpHeight := 8;
     Acceleration := 0.2;
     Decceleration := 0.2;
     FMaxFallSpeed := 5;
     DoJump:= False;
end;

procedure TJumperSpriteEx.SetJumpState(Value: TJumpState);
begin
     if FJumpState <> Value then
     begin
          FJumpState := Value;
          case Value of
               jsNone,
               jsFalling:
               begin
                    FVelocityY := 0;
               end;
          end;
     end;
end;

procedure TJumperSpriteEx.Accelerate;
begin
     if FSpeed <> FMaxSpeed then
     begin
          FSpeed:= FSpeed+FAcc;
          if FSpeed > FMaxSpeed then
             FSpeed := FMaxSpeed;
          VelocityX := Cos256(FDirection) * Speed;
     end;
end;

procedure TJumperSpriteEx.Deccelerate;
begin
     if FSpeed <> FMaxSpeed then
     begin
          FSpeed:= FSpeed+FAcc;
          if FSpeed < FMaxSpeed then
             FSpeed := FMaxSpeed;
          VelocityX := Cos256(FDirection) * Speed;
     end;
end;

procedure TJumperSpriteEx.DoMove(const MoveCount: Single);
begin
    inherited;

    case FJumpState of
         jsNone:
         begin
               if DoJump then
               begin
                    FHoldKey:=True;
                    FJumpSpeed:=FJumpStartSpeed;
                    FJumpState := jsJumping;
                    VelocityY := -FJumpHeight;
               end;
         end;
         jsJumping:
         begin
              if FHoldKey=True then    Inc(FJumpCount);
              if FHoldKey=False then
              begin
                   FJumpSpeed:=FLowJumpSpeed;//0.185;
                   FOffset:=VelocityY;
                   VelocityY:=FOffset*FLowJumpGravity;//0.6;  //range 0.0-->1.0
                   FHoldKey:=True;
                   FJumpCount:=0;
              end;
               if (FJumpCount>FHighJumpValue)  then
                     FJumpSpeed:=FHighJumpSpeed;
               Y:=Y+FVelocityY;
               VelocityY:=FVelocityY+FJumpSpeed;
               if VelocityY > 0 then
                    FJumpState := jsFalling;
         end;
         jsFalling:
         begin
              FJumpCount:=0;
              FJumpSpeed:=FFallingSpeed;
              Y:=Y+FVelocityY;
              VelocityY:=VelocityY+FJumpSpeed;
              if VelocityY > FMaxFallSpeed then
                  VelocityY := FMaxFallSpeed;
         end;
     end;
     DoJump := False;
end;

{  TTileMapSprite  }
constructor TTileMapSprite.Create(const AParent: TSprite);
begin
     inherited Create(AParent);
     Collisioned := False;
end;

destructor TTileMapSprite.Destroy;
begin
     SetMapSize(0, 0);
     inherited Destroy;
end;

procedure TTileMapSprite.Draw;
var
  i: Integer;
begin
     if FVisible then
     begin
          if FEngine<>nil then
          begin
               if  FDoTile then
               begin
                    if (X > FEngine.WorldX-Width-Engine.WorldX ) and
                    (Y > FEngine.WorldY-Height-Engine.WorldY)    and
                    (X < FEngine.WorldX +FEngine.VisibleWidth-Engine.WorldX)  and
                    (Y < FEngine.WorldY +FEngine.VisibleHeight-Engine.WorldY) then
                     begin
                          DoDraw;
                          Inc(FEngine.FDrawCount);
                     end;
               end
               else
               begin
                    if (X > FEngine.WorldX-Width-FMapW ) and
                    (Y > FEngine.WorldY-Height-FMapH)    and
                    (X < FEngine.WorldX +FEngine.VisibleWidth+200)  and
                    (Y < FEngine.WorldY +FEngine.VisibleHeight+200) then
                     begin
                          DoDraw;
                          Inc(FEngine.FDrawCount);
                     end;
               end;
          end;

          if FDrawList<>nil then
          begin
               for i:=0 to FDrawList.Count-1 do
                   TSprite(FDrawList[i]).Draw;
          end;
     end;
end;

function Mod2(i, i2: Integer): Integer;
begin
     Result := i mod i2;
     if Result<0 then
        Result := i2+Result;
end;

procedure TTileMapSprite.DoDraw;
var
   _x, _y, cx, cy, cx2, cy2, c, ChipWidth, ChipHeight: Integer;
   StartX, StartY, EndX, EndY, StartX_, StartY_, OfsX, OfsY, dWidth, dHeight: Integer;
begin
     if (FMapWidth<=0) or (FMapHeight<=0) then Exit;
     ChipWidth :=Self.Width;
     ChipHeight := Self.Height;

     dWidth := (Engine.VisibleWidth+ChipWidth) div ChipWidth+1;
     dHeight := (Engine.VisibleHeight+ChipHeight) div ChipHeight+1;

     _x := Trunc(-Engine.WorldX-X);
     _y := Trunc(-Engine.WorldY-Y);

     OfsX := _x mod ChipWidth;
     OfsY := _y mod ChipHeight;

     StartX := _x div ChipWidth;
     StartX_ := 0;

     if StartX<0 then
     begin
          StartX_ := -StartX;
          StartX := 0;
     end;

     StartY := _y div ChipHeight;
     StartY_ := 0;

     if StartY<0 then
     begin
          StartY_ := -StartY;
          StartY := 0;
     end;

     EndX := Min(StartX+FMapWidth-StartX_, dWidth);
     EndY := Min(StartY+FMapHeight-StartY_, dHeight);

     if FDoTile then
     begin
          for cy:=-1 to dHeight do
          begin
               cy2 := Mod2((cy-StartY+StartY_), FMapHeight);
               for cx:=-1 to dWidth do
               begin
                    cx2 := Mod2((cx-StartX+StartX_), FMapWidth);
                    c := Cells[cx2, cy2];
                    if c>=0 then
                        DrawColor1(
                        FEngine.FCanvas,
                        TAsphyreImage(FEngine.Image.Image[ImageName]),
                         c,
                         cx*ChipWidth+OfsX,
                         cy*ChipHeight+OfsY,
                         FScaleX, FScaleY, FDoCenter,
                         FMirrorX, FMirrorY,
                         FRed, FGreen, FBlue, FAlpha, FDrawFx);
               end;
          end;
     end
     else
     begin
          for cy:=StartY to EndY-1 do
          begin
               for cx:=StartX to EndX-1 do
               begin
                    c := Cells[cx-StartX+StartX_, cy-StartY+StartY_];
                    if c>=0 then
                         DrawColor1(
                         FEngine.FCanvas,
                         TAsphyreImage(FEngine.Image.Image[ImageName]),
                         c,
                         cx*ChipWidth+OfsX ,
                         cy*ChipHeight+OfsY,
                         FScaleX, FScaleY, FDoCenter,
                         FMirrorX, FMirrorY,
                         FRed, FGreen, FBlue, FAlpha, FDrawFx);
               end;
         end;
     end;
end;

function TTileMapSprite.TestCollision(Sprite: TSprite): Boolean;
var
  b, b1, b2: TRect;
  cx, cy, ChipWidth, ChipHeight: Integer;
begin
     Result := True;
     if ImageName=' ' then Exit;
     if (FMapWidth<=0) or (FMapHeight<=0) then Exit;
     ChipWidth := Self.Width;
     ChipHeight := Self.Height;
     b1 := Rect(Trunc(Sprite.X),Trunc(Sprite.Y),Trunc(Sprite.X)+Width,Trunc(Sprite.Y)+ Height);
     b2 := BoundsRect;

     IntersectRect(b, b1, b2);

     OffsetRect(b, -Trunc(Engine.WorldX), -Trunc(Engine.WorldY));
     OffsetRect(b1, -Trunc(Engine.WorldX), -Trunc(Engine.WorldY));

     for cy:=(b.Top-ChipHeight+1) div ChipHeight to b.Bottom div ChipHeight do
     begin
          for cx:=(b.Left-ChipWidth+1) div ChipWidth to b.Right div ChipWidth do
          begin
              if CollisionMap[Mod2(cx, MapWidth), Mod2(cy, MapHeight)] then
              begin
                   if OverlapRect(Bounds(cx*ChipWidth, cy*ChipHeight, ChipWidth, ChipHeight), b1) then Exit;
              end;
          end;
     end;

     Result := False;
end;

function TTileMapSprite.GetCell(X, Y: Integer): Integer;
begin
     if (X>=0) and (X<FMapWidth) and (Y>=0) and (Y<FMapHeight) then
         Result := PInteger(Integer(FMap)+(Y*FMapWidth+X)*SizeOf(Integer))^
     else
         Result := -1;
end;

type
  PBoolean = ^Boolean;

function TTileMapSprite.GetCollisionMapItem(X, Y: Integer): Boolean;
begin
     if (X>=0) and (X<FMapWidth) and (Y>=0) and (Y<FMapHeight) then
         Result := PBoolean(Integer(FCollisionMap)+(Y*FMapWidth+X)*SizeOf(Boolean))^
     else
         Result := False;
end;

function TTileMapSprite.GetBoundsRect: TRect;
begin
  if FDoTile then
  Result := Rect(0,0,Engine.VisibleWidth,Engine.VisibleHeight)
  else
  begin
    if ImageName<>' ' then
      Result := Bounds(Trunc(-Engine.WorldX-X), Trunc(-Engine.WorldY-Y),
        Width*FMapWidth, Height*FMapHeight)
    else
      Result := Rect(0, 0, 0, 0);
  end;
end;

procedure TTileMapSprite.SetCell(X, Y: Integer; Value: Integer);
begin
     if (X>=0) and (X<FMapWidth) and (Y>=0) and (Y<FMapHeight) then
         PInteger(Integer(FMap)+(Y*FMapWidth+X)*SizeOf(Integer))^ := Value;
end;

procedure TTileMapSprite.SetCollisionMapItem(X, Y: Integer; Value: Boolean);
begin
     if (X>=0) and (X<FMapWidth) and (Y>=0) and (Y<FMapHeight) then
         PBoolean(Integer(FCollisionMap)+(Y*FMapWidth+X)*SizeOf(Boolean))^ := Value;
end;

procedure TTileMapSprite.SetMapHeight(Value: Integer);
begin
     SetMapSize(FMapWidth, Value);
end;

procedure TTileMapSprite.SetMapWidth(Value: Integer);
begin
     SetMapSize(Value, FMapHeight);
end;

procedure TTileMapSprite.SetMapSize(AMapWidth, AMapHeight: Integer);
begin
     FMapW:= Width* AMapWidth;
     FMapH:= Height* AMapHeight;
     if (FMapWidth<>AMapWidth) or (FMapHeight<>AMapHeight) then
     begin
          if (AMapWidth<=0) or (AMapHeight<=0) then
          begin
               AMapWidth := 0;
               AMapHeight := 0;
          end;
          {else
          begin
              FWidth:=AMapWidth*Image.Width;
              FHeight:=AMapHeight*Image.Height;
          end;
          }
          FMapWidth := AMapWidth;
          FMapHeight := AMapHeight;

          ReAllocMem(FMap, FMapWidth*FMapHeight*SizeOf(Integer));
          FillChar(FMap^, FMapWidth*FMapHeight*SizeOf(Integer), 0);

          ReAllocMem(FCollisionMap, FMapWidth*FMapHeight*SizeOf(Boolean));
          FillChar(FCollisionMap^, FMapWidth*FMapHeight*SizeOf(Boolean), 1);
     end;
end;

{    TSpriteEngine    }
constructor TSpriteEngine.Create(const AParent: TSprite);
begin
     inherited Create(AParent);
     Application.OnMessage:=MouseMessage;
     FDeadList := TList.Create;
     FCurrentSelected := TList.Create;
     GroupCount := 10;
     FVisibleWidth := 800;
     FVisibleHeight := 600;
     FDoMouseEvent := False;
end;

destructor TSpriteEngine.Destroy;
begin
     ClearCurrent;
     GroupCount := 0;
     FDeadList.Free;
     inherited Destroy;
     FCurrentSelected.Free;
end;

procedure TSpriteEngine.GroupSelect(const Area : TRect;Add: Boolean = false);
begin
     GroupSelect(Area,[TSprite],Add);
end;

procedure TSpriteEngine.GroupSelect(const Area : TRect; Filter : array of TSpriteClass;Add: Boolean = False);
var
    Index,Index2 : Integer;
    Sprite : TSprite;
begin
     Assert(Length(Filter) <> 0,'Filter = []');
     if not Add then
         ClearCurrent;
     if Length(Filter) = 1 then
     begin
          for Index :=0 to Count-1 do
          begin
               Sprite := TSpriteEx(Items[Index]);
               if (sprite is Filter[0]) and  OverlapRect(TSpriteEx(Sprite).GetBoundsRect,Area) then
                   TSpriteEx(Sprite).Selected := True;
          end
     end
     else
     begin
          for Index :=0 to Count-1 do
          begin
               Sprite := Items[Index];
               for Index2 := 0 to High(Filter) do
               begin
                    if (Sprite is Filter[Index2]) and  OverlapRect(TSpriteEx(Sprite).GetBoundsRect,Area) then
                    begin
                         TSpriteEx(Sprite).Selected:= True;
                         Break;
                    end;
               end;
          end
     end;
     FObjectsSelected := CurrentSelected.Count <> 0;
end;

function TSpriteEngine.Select(Point : TPoint; Filter : array of TSpriteClass;Add: Boolean = False) : TSprite;
var
  Index,Index2 : Integer;
begin
     Assert(Length(Filter) <> 0,'Filter = []');
     if not Add then
         ClearCurrent;
     // By searching the Drawlist in reverse
     // we select the highest sprite if the sprit is under the point
     Assert(FDrawList <> nil,'FDrawList = nil');
     if Length(Filter) = 1 then
     begin
          for Index := FDrawList.Count-1 downto 0 do
          begin
               Result := FDrawList[Index];
               if (Result is Filter[0]) and  PointInRect(Point,TSpriteEx(Result).GetBoundsRect) then
               begin
                    TSpriteEx(Result).Selected := True;
                    FObjectsSelected := CurrentSelected.Count <> 0;
                    Exit;
               end;
          end
     end
     else
     begin
          for Index := FDrawList.Count-1 downto 0 do
          begin
               Result := FDrawList[Index];
               for Index2 := 0 to High(Filter) do
               begin
                    if (Result is Filter[Index2]) and  PointInRect(Point,TSpriteEx(Result).GetBoundsRect) then
                    begin
                         TSpriteEx(Result).Selected:= True;
                         FObjectsSelected := CurrentSelected.Count <> 0;
                         Exit;
                    end;
               end;
          end
     end;
     Result := nil;
end;

function TSpriteEngine.Select(Point : TPoint;Add: Boolean = False) : TSprite;
begin
     Result := Select(Point,[TSprite],Add);
end;

procedure TSpriteEngine.ClearCurrent;
begin
     while CurrentSelected.Count <> 0 do
        TSpriteEx(CurrentSelected[CurrentSelected.Count-1]).Selected:= False;
     FObjectsSelected := False;
end;

procedure TSpriteEngine.ClearGroup(GroupNumber : Integer);
var
  Index : Integer;
  Group : TList;
begin
     Group := Groups[GroupNumber];
     if Group <> nil then
     for Index := 0 to Group.Count-1 do
       TSpriteEx(Group[Index]).Selected := False;
end; {ClearGroup}

procedure TSpriteEngine.CurrentToGroup(GroupNumber : Integer; Add: Boolean = False);
var
  Group : TList;
  Index : Integer;
begin
     Group := Groups[GroupNumber];
     if Group = nil then
        Exit;
     if not Add then
        ClearGroup(GroupNumber);
     for Index := 0 to Group.Count - 1 do
        TSpriteEx(Group[Index]).GroupNumber := GroupNumber;
end;

procedure TSpriteEngine.GroupToCurrent(GroupNumber : Integer; Add : Boolean = False);
var
  Group : TList;
  Index : Integer;
begin
     if not Add then
        ClearCurrent;
     Group := Groups[GroupNumber];
     if Group <> nil then
        for Index := 0 to Group.Count - 1 do
           TSpriteEx(Group[Index]).Selected := True;
end;

function TSpriteEngine.GetGroup(Index : Integer) : TList;
begin
     if (index >= 0) or (Index < FGroupCount ) then
        Result := FGroups[Index]
     else
        Result := nil;
end;

procedure TSpriteEngine.SetGroupCount(AGroupCount : Integer);
var
   Index : Integer;
begin
     if (AGroupCount <> FGroupCount) and (AGroupCount >= 0) then
     begin
          if FGroupCount > AGroupCount then
          begin // remove groups
               for index := AGroupCount to fGroupCount-1 do
               begin
                    ClearGroup(Index);
                    FGroups[Index].Free;
               end;
               SetLength(FGroups,AGroupCount);
          end
          else
          begin // add groups
               SetLength(FGroups,AGroupCount);
               for Index := FGroupCount to AGroupCount -1 do
                   FGroups[Index] := TList.Create;
          end;
          FGroupCount := Length(FGroups);
    end;
end;

procedure TSpriteEngine.Dead;
begin
     while FDeadList.Count>0 do
         TSprite(FDeadList[FDeadList.Count-1]).Free;
end;

procedure TSpriteEngine.Draw;
begin
     FDrawCount := 0;
     inherited Draw;
end;

procedure TSpriteEngine.MouseMessage(var Msg:TMsg; var Handled: Boolean);
var
    i:integer;
    Info:TWindowInfo ;
    bColi:boolean;   //huasoft 2007-03-30
begin
     if not FDoMouseEvent then Exit;
// --------begine----------------------------------by huasoft
//     GetWindowInfo(Device.Params.hDeviceWindow,Info);
     GetWindowInfo(msg.hwnd,Info);
     MousePoint:=msg.pt;
     ScreenToClient(Device.Params.hDeviceWindow,MousePoint);
     MousePoint.X:=trunc(Device.Params.BackBufferWidth*MousePoint.x/(Info.rcClient.Right-Info.rcClient.Left));
     MousePoint.Y:=trunc(Device.Params.BackBufferHeight*MousePoint.y/(Info.rcClient.Bottom-Info.rcClient.Top));
// --------end------------------------------
     bColi:=false;   //huasoft 2007-03-30
     for i:=0 to Count-1 do
     begin
          if TSpriteEx(Items[i]).MouseInRect then
          begin
               if TSpriteEx(Items[i]).FMouseEnterFlag=False then
               begin
                    TSpriteEx(Items[i]).OnMouseEnter;
                    TSpriteEx(Items[i]).FMouseEnterFlag:=True;
               end;
               case Msg.message of
                     WM_MOUSEMOVE :
                     begin
                          TSpriteEx(Items[i]).OnMouseMove;
                          if TSpriteEx(Items[i]).FMouseDownFlag=True then
                              TSpriteEx(Items[i]).OnMouseDrag(MousePoint.x,MousePoint.y);
                     end;
                     WM_LBUTTONDOWN:
                     begin
                          TSpriteEx(Items[i]).OnMouseClick(MousePoint.x,MousePoint.y);
                          TSpriteEx(Items[i]).FMouseDownFlag:=True;
                     end;
                     WM_LBUTTONUP :  TSpriteEx(Items[i]).OnMouseUp;
                     WM_LBUTTONDBLCLK :TSpriteEx(Items[i]).OnMouseDbClick;
                     WM_RBUTTONDOWN: TSpriteEx(Items[i]).OnMouseRClick;
                     WM_RBUTTONUP  : TSpriteEx(Items[i]).OnMouseRUp;
                     WM_MOUSEWHEEL : TSpriteEx(Items[i]).OnMouseWheel;
               end;
               bColi:=true;  //huasoft 2007-03-30
          end;
          if Msg.message=WM_LBUTTONUP then TSpriteEx(Items[i]).FMouseDownFlag:=False;

          if (not TSpriteEx(Items[i]).MouseInRect) then
          begin
               if TSpriteEx(Items[i]).FMouseEnterFlag=True then
               begin
                    TSpriteEx(Items[i]).OnMouseLeave;
                    TSpriteEx(Items[i]).FMouseEnterFlag:=False;
               end;
          end;
          if bColi then break;   //huasoft 2007-03-30
          
     end;
end;

end.
