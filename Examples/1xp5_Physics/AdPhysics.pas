{
* This program is licensed under the Common Public License (CPL) Version 1.0
* You should have recieved a copy of the license with this file.
* If not, see http://www.opensource.org/licenses/cpl1.0.txt for more informations.
* 
* Inspite of the incompatibility between the Common Public License (CPL) and the GNU General Public License (GPL) you're allowed to use this program * under the GPL. 
* You also should have recieved a copy of this license with this file. 
* If not, see http://www.gnu.org/licenses/gpl.txt for more informations.
*
* Project: Andorra 2D
* Author:  Andreas Stoeckel
* File: AdPhysics.pas
* Comment: Contains a link to newton
* To use the AdPhysics unit you'll need the Newton headers for Delphi from
*    http://newton.delphigl.de/
* and a version of Newton itsself from
*    http://www.newtongamedynamics.com/
* where you have to download the SDK for your platform and copy the .dll/.so/.dynlib to your Andorra 2D directory.
}

{ Contains a link to newton
To use the AdPhysics unit you'll need the Newton headers for Delphi from  http://newton.delphigl.de/ and a version of Newton itsself from   http://www.newtongamedynamics.com/ where you have to download the SDK for your platform and copy the .dll/.so/.dynlib to your Andorra 2D directory.}
unit AdPhysics;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses  NewtonImport, AsphyreSprite,Classes, Types, Math;

type
  {A matrix}
  TAdMatrix = array[0..3] of array[0..3] of double;

  //A vector for the use with newton
  TNtVector3f = record
     //The position
     X,Y,Z : Single;
  end;
  {Another simple vector with 3 parameters}
  TAdVector3 = record
    {Stores the vectors information.}
    x,y,z:double;
  end;

  //A matrix for the use with newton
  TNtMatrix4f = array[0..3, 0..3] of Single;  

    {A list, which contains sprites.}
  TSpriteList = class(TList)
    private
    	function GetItem(AIndex:integer):TSprite;
    	procedure SetItem(AIndex:integer;AItem:TSprite);
    protected
    public
    	{Access on every item in the list.}
      property Items[AIndex:integer]:TSprite read GetItem write SetItem;default;
      {Adds a sprite to the list and orders it by its Z value}
      procedure Add(ASprite:TSprite);
      {Removes a sprite from the list.}
      procedure Remove(ASprite:TSprite);
  end;

  //Contains data about a physical element.
  TPhysicalConstructData = class
     //The mass of an element
     Mass:single;
  end;

  //Contains data about a normal physical element.
  TPhysicalSimpleData = class(TPhysicalConstructData)
    //The size of an element
    Width,Height:single;
  end;  

  //A sprite which represents the physics engine.
  TPhysicalApplication = class;

  //A class which creates a physical element
  TPhysicalConstruct = class
    protected
      Parent:TPhysicalApplication;
    public
      //A pointer to newton's physical body/construct
      NewtonBody:PNewtonBody;
      //Creates the construct with the parameters given in AData
      procedure CreateConstruct(AData:TPhysicalConstructData);virtual;abstract;

      //Creates an instance of TPhysicalConstruct
      constructor Create(AParent:TPhysicalApplication);
      //Destroys an instance of TPhysicalConstruct
      destructor Destroy;override;
  end;

  //A class which creates a physical box
  TPhysicalBoxConstruct = class(TPhysicalConstruct)
    public
      //Creates the box with the parameters given in AData
      procedure CreateConstruct(AData:TPhysicalConstructData);override;
  end;

  //A class which creates a physical cylinder
  TPhysicalCylinderConstruct = class(TPhysicalConstruct)
    public
      //Creates the cylinder with the parameters given in AData
      procedure CreateConstruct(AData:TPhysicalConstructData);override;
  end;

  //A type which represents how accurate the simulation is
  TNewtonSolverModel = (
    smExact,//< Accurate but slow
    smAdaptive,//< Less accurate but still slow
    smLinear//< Unaccurate but fast
  );

  //A sprite which represents the physics engine.
  TPhysicalApplication = class(TSprite)
    private
      FLastSizeX:integer;
      FLastSizeY:integer;
      FTime:double;
      FInterval:single;
      FActive:boolean;
      FMinFrameRate:integer;
      FSolverModel:TNewtonSolverModel;
      procedure SetSolverModel(Value:TNewtonSolverModel);
    protected
      procedure DoMove(const MoveCount: Single);override;
    public
      // A pointer to newtons world
      NewtonWorld:PNewtonWorld;

      //Creates an instance of TPysicalApplication in the SpriteEngine
      constructor Create(const AParent:TSprite);override;
      //Destroys the instance
      destructor Destroy;override;

      //Checks the bounds of the sprite world and expands is if neccesary
      procedure CheckBounds;

      //Sets wether the simulation is active or not
      property Active:boolean read FActive write FActive;
      //The interval of simulation in ms. Default is 10ms --> 100FPS.
      property Interval:single read FInterval write FInterval;
      //If the framerate is lower than this value the simulation is paused.
      property MinFrameRate:integer read FMinFrameRate write FMinFrameRate;
      //Sets the solver model. Have a look on the description of TNewtonSolverModel
      property SolverModel:TNewtonSolverModel read FSolverModel write SetSolverModel;
  end;

  //The typ of the physical sprite
  TPhysicalSpriteTyp = (
    ptDynamic,//< The sprite can move arround
    ptStatic//< The sprite is static, e.g. the landscape
  );

  //A sprite in the physical world. Don't use this sprite directly. Use e.g. TPhysicalBoxSprite or create a child class and override InitializeShape
  TPhysicalSprite = class(TAnimatedSprite)
    private
      FLastAx,FLastAy:double;
      FActive:boolean;
      FContinousActive:boolean;
      FBaseMatrix:TNtMatrix4f;
      FMass:single;
    protected
      Physics:TPhysicalApplication;
      Updating:Boolean;
      procedure DoMove(const MoveCount: Single);override;

      procedure SetX(const Value: Single);override;
      procedure SetY(const Value: Single);override;
      procedure SetAngle(Value:double);
      procedure UpdateNewtonMatrix;virtual;

      procedure SetActive(Value:boolean);virtual;
      function GetActive:boolean;virtual;

      procedure SetContinousActive(Value:boolean);
      function GetContinousActive:boolean;
    public
      //The creator of the physical form
      Construct:TPhysicalConstruct;
      //The typ of the sprite
      Typ:TPhysicalSpriteTyp;
      
      //Creates an instance of the sprite
      constructor Create(const AParent:TSprite);override;
      //Destroys the instance
      destructor Destroy;override;
      
      //Frees the old construct if neccesary and waits for a child class to create the construct.
      procedure InitializeShape;virtual;
      
      //Wakes its neighbours up if they snooze at the moment.
      procedure ActivateNeighbours;

      //Sets the Sprite to the sleep modus (false)  or wakes it up (true).
      property Active:boolean read GetActive write SetActive;
      //Sets wether the sprite doesn't snooze. TRUE brings higher accuracy but it needs a lot of performance
      property ContinousActive:boolean read GetContinousActive write SetContinousActive;
      //The mass of the sprite
      property Mass:single read FMass write FMass;
  end;

  //A sprite with box form
  TPhysicalBoxSprite = class(TPhysicalSprite)
    public
      //Creates a box construct
      procedure InitializeShape;override;
  end;

  //A sprite with cylinder fotm
  TPhysicalCylinderSprite = class(TPhysicalSprite)
    public
      //Creates a cylinder construct
      procedure InitializeShape;override;
  end;

  //Creates an TNtVector3f
  function NtVector3f(AX,AY,AZ:single):TNtVector3f;
{Multiplies two matrices.}
function AdMatrix_Multiply(amat1,amat2:TAdMatrix):TAdMatrix;
{Creates a translation matrix.}
function AdMatrix_Translate(tx,ty,tz:single):TAdMatrix;
{Creates a rotation matrix.}
function AdMatrix_RotationZ(angle:single):TAdMatrix;
{Creates a rotation matrix.}
function AdMatrix_RotationX(angle:single):TAdMatrix;
{Creates a rotation matrix.}
function AdMatrix_RotationY(angle:single):TAdMatrix;
{Creates a identity matrix.}
function AdMatrix_Identity:TAdMatrix;
{Creates a clear matrix. (With zeros everywhere)}
function AdMatrix_Clear:TAdMatrix;

  //Makes an TAdMatrix out of a TNtMatrix4f
  procedure AndorraToNewtonMatrix(Andorra:TAdMatrix; out Newton:TNtMatrix4f);

implementation

function NtVector3f(AX,AY,AZ:single):TNtVector3f;
begin
  with result do
  begin
    X := AX;
    Y := AY;
    Z := AZ;
  end;
end;

procedure AndorraToNewtonMatrix(Andorra:TAdMatrix; out Newton:TNtMatrix4f);
var x,y:integer;
begin
  for x := 0 to 3 do
    for y := 0 to 3 do
      Newton[x,y] := Andorra[x,y];
end; 

procedure ForceAndTorqueCallback(const body : PNewtonBody); cdecl;
var
 Mass : Single;
 Inertia : TNtVector3f;
 Force : TNtVector3f;
// i,j: integer;
begin
  NewtonBodyGetMassMatrix(Body, @Mass, @Inertia.x, @Inertia.y, @Inertia.z);
  with Force do
  begin
    X := 0;
    Y := 36 * Mass;
    Z := 0;
  end;
  NewtonBodyAddForce(Body, @Force.x);
end;
  
{ TPhysicalApplication }

constructor TPhysicalApplication.Create(const AParent: TSprite);
begin
  inherited;
  NewtonWorld := NewtonCreate(nil,nil);

  FLastSizeX := 0;
  FLastSizeY := 0;

  FTime := 0;
  FInterval := 10;
  FActive := true;
  FMinframeRate := 20;
  FSolverModel := smExact;

  CheckBounds;

//  NewtonImport.NewtonSetGlobalScale(
end;

destructor TPhysicalApplication.Destroy;
begin
  NewtonDestroy(NewtonWorld);
  inherited;
end;

procedure TPhysicalApplication.DoMove(const MoveCount: Single);
begin
  if FActive then
  begin
    if MoveCount < 1/FMinFramerate then
    begin
      FTime := FTime + MoveCount*1000;
      while FTime > FInterval do
      begin
        FTime := FTime - FInterval;
        NewtonUpdate(NewtonWorld, FInterval / 100);
      end;
    end;
    CheckBounds;
  end;
end;

procedure TPhysicalApplication.SetSolverModel(Value: TNewtonSolverModel);
begin
  FSolverModel := Value;
  case Value of
    smExact: NewtonSetSolverModel(NewtonWorld,0);
    smAdaptive: NewtonSetSolverModel(NewtonWorld,1);
    smLinear: NewtonSetSolverModel(NewtonWorld,2);
  end;
end;

procedure TPhysicalApplication.CheckBounds;
var vc1,vc2:TNtVector3f;
begin
  if (FLastSizeX <> Engine.Width) or
     (FLastSizeY <> Engine.Height) then
  begin

    FLastSizeX := Engine.Width;
    FLastSizeY := Engine.Height;

    vc1 := NtVector3f((Engine.X-1)*128,//Engine.GridSize,
                      (Engine.Y-1)*128{Engine.GridSize},-50);
    vc2 := NtVector3f((Engine.X+Engine.Width+1)*128,
                      (Engine.Y+Engine.Height+1)*128, 50);

    NewtonSetWorldSize(NewtonWorld, @vc1.X, @vc2.X);

  end;
end;

{ TPhysicalSprite }

constructor TPhysicalSprite.Create(const AParent: TSprite);
var i:integer;
begin
  inherited;
  Physics := nil;
  for i := 0 to Engine.Count-1 do
  begin
    if Engine.Items[i] is TPhysicalApplication then
    begin
      Physics := TPhysicalApplication(Engine.Items[i]);
      break;
    end;
  end;

  Construct := nil;
  FActive := true;
  FContinousActive := false;
end;

destructor TPhysicalSprite.Destroy;
begin
  inherited;
end;

procedure TPhysicalSprite.DoMove(const MoveCount: Single);
var Matrix:TNtMatrix4f;
    ax,ay:double;
begin
  inherited;
  if (FActive) and (Physics <> nil) and (Construct <> nil) and (Construct.NewtonBody <> nil) then
  begin
    NewtonBodyGetMatrix(Construct.NewtonBody, @Matrix[0,0]);
    Updating := true;

    X := Matrix[3,0] - Width / 2;
    Y := Matrix[3,1] - Height / 2;


    ax := (Matrix[0,0]) + (Matrix[1,0]);
    ay := (Matrix[0,1]) + (Matrix[1,1]);
    if (FLastAX <> ax) or (FLastAY <> ay) then
    begin
      FLastAx := ax;
      FLastAy := ay;
      if ay > 0 then
      begin
        Angle := arccos(ax/(sqrt(sqr(ax)+sqr(ay))))-PI/4;//RadToDeg(arccos(ax/(sqrt(sqr(ax)+sqr(ay)))))-45;
      end
      else
      begin
        Angle :=2*PI-arccos(ax/(sqrt(sqr(ax)+sqr(ay))))-PI/4;// 360-RadToDeg(arccos(ax/(sqrt(sqr(ax)+sqr(ay)))))-45;
      end;
    end;

    if (Matrix[2,0] <> FBaseMatrix[2,0]) or  (Matrix[2,1] <> FBaseMatrix[2,1]) or
       (Matrix[2,2] <> FBaseMatrix[2,2]) or  (Matrix[0,2] <> FBaseMatrix[0,2]) or
       (Matrix[1,2] <> FBaseMatrix[1,2]) then
    begin
      UpdateNewtonMatrix;
    end;


    Updating := false;
  end;
end;

function TPhysicalSprite.GetActive: boolean;
begin
  if FActive then
  begin
    result := NewtonBodyGetSleepingState(Construct.NewtonBody) = 1;
  end
  else
  begin
    result := false;
  end;
end;

function TPhysicalSprite.GetContinousActive: boolean;
begin
  if Construct <> nil then
  begin
    result := NewtonBodyGetAutoFreeze(Construct.NewtonBody) = 0;
  end
  else
  begin
    result := FContinousActive;
  end;
end;

procedure TPhysicalSprite.SetContinousActive(Value: boolean);
begin
  FContinousActive := Value;
  if Construct <> nil then
  begin
    if Value then
    begin
      NewtonBodySetAutoFreeze(Construct.NewtonBody,0)
    end
    else
    begin
      NewtonBodySetAutoFreeze(Construct.NewtonBody,1);
    end;
  end;
end;

procedure TPhysicalSprite.InitializeShape;
begin
  if Construct <> nil then
  begin
    Construct.Free;
    Construct := nil;
  end;
end;

procedure TPhysicalSprite.SetActive(Value: boolean);
begin
  if (Construct <> nil) and (Value <> Active) then
  begin
    FActive := Value;
    if Value then
    begin
      NewtonWorldUnfreezeBody(Physics.NewtonWorld, Construct.NewtonBody);
      ActivateNeighbours;
    end
    else
    begin
      NewtonWorldFreezeBody(Physics.NewtonWorld, Construct.NewtonBody);
    end;
  end;
end;

procedure TPhysicalSprite.SetAngle(Value: double);
begin
  inherited;
  if (not Updating) and (Construct <> nil) then
  begin
    UpdateNewtonMatrix;
  end;
end;

procedure TPhysicalSprite.SetX(const Value: Single);
begin
  inherited;
  if (not Updating) and (Construct <> nil) then
  begin
    UpdateNewtonMatrix;
  end;
end;

procedure TPhysicalSprite.SetY(const Value: Single);
begin
  inherited;
  if (not Updating) and (Construct <> nil) then
  begin
    UpdateNewtonMatrix;
  end;
end;

procedure TPhysicalSprite.ActivateNeighbours;
var r:TRect;
    ax,ay,i:integer;
    List:TSpriteList;
begin
//  r := CollideRect;
//  for ax := r.Left to r.Right do
//  begin
//    for ay := r.Top to r.Bottom do
//    begin
////      List := Parent.SpriteField.Items[ax,ay];
//      for i := 0 to List.Count - 1 do
//      begin
//        if (List[i] <> self) and (List[i] is TPhysicalSprite) and 
//           (TPhysicalSprite(List[i]).Typ <> ptStatic) then
//        begin
//          TPhysicalSprite(List[i]).Active := true;
//        end;
//      end;
//    end;
//  end;
end;

procedure TPhysicalSprite.UpdateNewtonMatrix;
var Mat1,Mat2:TAdMatrix;
    Mat3:TNtMatrix4f;
begin
  Mat1 := AdMatrix_Translate(X + Width / 2, Y + Height / 2, 50);
  Mat2 := AdMatrix_RotationZ(DegToRad(Angle));
  Mat2 := AdMatrix_Multiply(Mat2,Mat1);
  AndorraToNewtonMatrix(Mat2,Mat3);
  NewtonBodySetMatrix(Construct.NewtonBody, @Mat3[0,0]);
end;

{ TPhysicalContstruct }

constructor TPhysicalConstruct.Create(AParent:TPhysicalApplication);
begin
  inherited Create;

  Parent := AParent;
  NewtonBody := nil;
end;

destructor TPhysicalConstruct.Destroy;
begin
  if NewtonBody <> nil then
  begin
    NewtonDestroyBody(Parent.NewtonWorld, NewtonBody);
  end;
  inherited;
end;

{ TPhysicalBoxConstruct }

procedure TPhysicalBoxConstruct.CreateConstruct(AData: TPhysicalConstructData);
var Collision:PNewtonCollision;
    Inertia:TAdVector3;
begin
  if AData is TPhysicalSimpleData then
  begin
    with AData as TPhysicalSimpleData do
    begin
      Collision := NewtonCreateBox(Parent.NewtonWorld, Width, Height, 100, nil);
      NewtonBody := NewtonCreateBody(Parent.NewtonWorld, Collision);
      NewtonReleaseCollision(Parent.NewtonWorld, Collision);

      with Inertia do
      begin
        x := Mass * (sqr(Height) + 10000)      / 12;
        y := Mass * (sqr(Width) + 10000)       / 12;
        z := Mass * (sqr(Width) + sqr(Height)) / 12;
        NewtonBodySetMassMatrix(NewtonBody, Mass, x, y, z);
      end;

      NewtonBodySetForceAndTorqueCallback(NewtonBody, ForceAndTorqueCallback);
    end;
  end;
end;

{ TPhysicalBoxSprite }

procedure TPhysicalBoxSprite.InitializeShape;
var Data:TPhysicalSimpleData;
begin
  inherited;
  Construct := TPhysicalBoxConstruct.Create(Physics);
  Data := TPhysicalSimpleData.Create;
  Data.Width := Width;
  Data.Height := Height;
  if Typ = ptDynamic then
  begin
    Data.Mass := Mass;
  end
  else
  begin
    Data.Mass := 0;
  end;

  Construct.CreateConstruct(Data);
  Data.Free;

  NewtonBodyGetMatrix(Construct.NewtonBody,@FBaseMatrix[0,0]);

  Physics.CheckBounds;

  SetX(X);
  SetY(Y);

  SetContinousActive(FContinousActive);
end;

{ TPhysicalZylinderConstruct }

procedure TPhysicalCylinderConstruct.CreateConstruct(
  AData: TPhysicalConstructData);
var Collision:PNewtonCollision;
    Inertia:TAdVector3;
    Mat1:TAdMatrix;
    Mat2:TNtMatrix4f;
begin
  if AData is TPhysicalSimpleData then
  begin
    with AData as TPhysicalSimpleData do
    begin
      Mat1 := AdMatrix_RotationY(1/2*Pi);
      AndorraToNewtonMatrix(Mat1,Mat2);

      Collision := NewtonImport.NewtonCreateCylinder(Parent.NewtonWorld, Width / 2, 100, @Mat2[0,0]);
      NewtonBody := NewtonCreateBody(Parent.NewtonWorld, Collision);
      NewtonReleaseCollision(Parent.NewtonWorld, Collision);

      with Inertia do
      begin
        x := Mass * (sqr(Height)+ 10000)      / 12;
        y := Mass * (sqr(Width) + 10000)       / 12;
        z := Mass * (sqr(Width) + sqr(Height)) / 12;
        NewtonBodySetMassMatrix(NewtonBody, Mass, x, y, z);
      end;

      NewtonBodySetForceAndTorqueCallback(NewtonBody, ForceAndTorqueCallback);
    end;
  end;  
end;

{ TPhysicalCylinderSprite }

procedure TPhysicalCylinderSprite.InitializeShape;
var Data:TPhysicalSimpleData;
begin
  inherited;
  Construct := TPhysicalCylinderConstruct.Create(Physics);
  Data := TPhysicalSimpleData.Create;
  Data.Width := Width;
  Data.Height := Height;
  if Typ = ptDynamic then
  begin
    Data.Mass := Mass;
  end
  else
  begin
    Data.Mass := 0;
  end;

  Construct.CreateConstruct(Data);
  Data.Free;

  NewtonBodyGetMatrix(Construct.NewtonBody,@FBaseMatrix[0,0]);

  Physics.CheckBounds;

  SetX(X);
  SetY(Y);

  SetContinousActive(FContinousActive);
end;

{ TSpriteList }
procedure TSpriteList.Add(ASprite: TSprite);
var I:integer;
begin
  I := 0;
  if Count > 0 then
  begin
    while I < Count do
    begin
      if Items[I].Z < ASprite.Z then
      begin
        I := I + 1;
      end
      else
      begin
        break;
      end;
    end;
    Insert(I,ASprite);
  end
  else
  begin
    inherited Add(ASprite);
  end;
end;

function TSpriteList.GetItem(AIndex:integer):TSprite;
begin
  result := TSprite(inherited Items[AIndex]);
end;

procedure TSpriteList.Remove(ASprite: TSprite);
begin
  inherited Remove(ASprite);
end;

procedure TSpriteList.SetItem(AIndex:integer;AItem:TSprite);
begin
  inherited Items[AIndex] := AItem;
end;

//Matrix functions
function AdMatrix_Multiply(amat1,amat2:TAdMatrix):TAdMatrix;
var x,y:integer;
begin
  for x := 0 to 3 do
  begin
    for y := 0 to 3 do
    begin
      result[x,y] := amat2[0,y]*amat1[x,0] + amat2[1,y]*amat1[x,1] + amat2[2,y]*amat1[x,2] +amat2[3,y]*amat1[x,3];
    end;
  end;
end;

function AdMatrix_Translate(tx,ty,tz:single):TAdMatrix;
begin
  result := AdMatrix_Identity;
  result[3,0] := tx;
  result[3,1] := ty;
  result[3,2] := tz;
end;

function AdMatrix_RotationZ(angle:single):TAdMatrix;
begin
  result := AdMatrix_Clear;
  result[0,0] := cos(angle);
  result[0,1] := sin(angle);
  result[1,0] := -sin(angle);
  result[1,1] := cos(angle);
  result[2,2] := 1;
  result[3,3] := 1;
end;

function AdMatrix_RotationX(angle:single):TAdMatrix;
begin
  result := AdMatrix_Clear;
  result[0,0] := 1;
  result[1,1] := cos(angle);
  result[1,2] := sin(angle);
  result[2,1] := -sin(angle);
  result[2,2] := cos(angle);
  result[3,3] := 1;
end;

function AdMatrix_RotationY(angle:single):TAdMatrix;
begin
  result := AdMatrix_Clear;
  result[0,0] := cos(angle);
  result[0,2] := -sin(angle);
  result[1,1] := 1;
  result[2,0] := sin(angle);
  result[2,2] := cos(angle);
  result[3,3] := 1;
end;

function AdMatrix_Clear:TAdMatrix;
var x,y:integer;
begin
  for x := 0 to 3 do
  begin
    for y := 0 to 3 do
    begin
      result[x,y] := 0;
    end;
  end;
end;

function AdMatrix_Identity:TAdMatrix;
begin
  result := AdMatrix_Clear;
  result[0,0] := 1;
  result[1,1] := 1;
  result[2,2] := 1;
  result[3,3] := 1;
end;

end.
