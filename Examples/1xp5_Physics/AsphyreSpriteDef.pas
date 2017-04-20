unit AsphyreSpriteDef;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Types, Math, AsphyreTypes, Vectors2;

//---------------------------------------------------------------------------
type
 PAsphyrePolygon = ^TAsphyrePolygon;
 TAsphyrePolygon = array of TPoint2;

//---------------------------------------------------------------------------
 TBezierPoints  = array[0..3] of TPoint;
 TBezierPoints2 = TPoint4;

//---------------------------------------------------------------------------
// Extended Point4 helper routines.
//---------------------------------------------------------------------------
function pBounds4s2(_Left, _Top, _Width, _Height, ScaleX, ScaleY: Real): TPoint4;
function pBounds4sc2(_Left, _Top, _Width, _Height, ScaleX, ScaleY: Real): TPoint4;
// rotated rectangle (Origin + Size) around (Middle) with Angle and Scale
function pRotate42(const Origin, Size, Middle: TPoint2; Angle: Real;
 ScaleX, ScaleY: Real): TPoint4;
function pRotate4c2(const Origin, Size: TPoint2; Angle,
 ScaleX, ScaleY: Real): TPoint4;
function pRotateTransForm(const X, Y, X1, Y1, X2, Y2, X3, Y3, X4, Y4,
 CenterX, CenterY, Angle: Real; Scale: Real = 1.0): TPoint4;
function pRotateTransForm2(const X, Y, X1, Y1, X2, Y2, X3, Y3, X4, Y4,
 CenterX, CenterY, Angle, ScaleX, ScaleY: Real): TPoint4;

//---------------------------------------------------------------------------
function BezierPoints(const OriginPoint, DestPoint, C1Point, C2Point: TPoint): TBezierPoints; overload;
function BezierPoints(const OriginPoint, DestPoint, C1Point, C2Point: TPoint2): TBezierPoints2;overload;

//---------------------------------------------------------------------------
// returns True if the point4  Quadrangle overlap
//---------------------------------------------------------------------------
function OverlapQuadrangle(const Q1, Q2: TPoint4): Boolean;

//---------------------------------------------------------------------------
// returns True if polygons overlap
// last points of polygons must be the first one ( P1[0] = P1[N]  ; P2[0] = P2[N] )
//---------------------------------------------------------------------------
function OverlapPolygon(const P1, P2: TAsphyrePolygon): Boolean;

function PtInPolygon(const Pt: TPoint2; const Pg: TAsphyrePolygon):Boolean;

//---------------------------------------------------------------------------
// Precalculated Sin/Cos tables
//---------------------------------------------------------------------------
function Cos8(i: Integer): Real;
function Sin8(i: Integer): Real;
function Cos16(i: Integer): Real;
function Sin16(i: Integer): Real;
function Cos32(i: Integer): Real;
function Sin32(i: Integer): Real;
function Cos64(i: Integer): Real;
function Sin64(i: Integer): Real;
function Cos128(i: Integer): Real;
function Sin128(i: Integer): Real;
function Cos256(i: Integer): Real;
function Sin256(i: Integer): Real;
function Cos512(i: Integer): Real;
function Sin512(i: Integer): Real;

//---------------------------------------------------------------------------
implementation

function pBounds4s2(_Left, _Top, _Width, _Height, ScaleX, ScaleY: Real): TPoint4;
begin
 Result:= pBounds4(_Left, _Top, Round(_Width * ScaleX), Round(_Height * ScaleY));
end;

function pBounds4sc2(_Left, _Top, _Width, _Height, ScaleX, ScaleY: Real): TPoint4;
var
 Left, Top: Real;
 Width, Height: Real;
begin
 if (ScaleX = 1.0) and (ScaleY=1.0) then
  Result:= pBounds4(_Left, _Top, _Width, _Height)
 else
  begin
   Width := _Width * ScaleX;
   Height:= _Height * ScaleY;
   Left  := _Left + Round((_Width - Width) * 0.5);
   Top   := _Top + Round((_Height - Height) * 0.5);
   Result:= pBounds4(Left, Top, Round(Width), Round(Height));
  end;
end;

//---------------------------------------------------------------------------


function pRotate42(const Origin, Size, Middle: TPoint2; Angle: Real;
 ScaleX, ScaleY: Real ): TPoint4;
var
 CosPhi: Real;
 SinPhi: Real;
 Index : Integer;
 Points: TPoint4;
 Point : TPoint2;
begin
 CosPhi:= Cos(Angle);
 SinPhi:= Sin(Angle);

 // create 4 points centered at (0, 0)
 Points:= pBounds4(-Middle.X, -Middle.Y, Size.X, Size.Y);

 // process the created points
 for Index:= 0 to 3 do
  begin
   // scale the point
   Points[Index].x:= Points[Index].x * ScaleX;
   Points[Index].y:= Points[Index].y * ScaleY;

   // rotate the point around Phi
   Point.x:= (Points[Index].x * CosPhi) - (Points[Index].y * SinPhi);
   Point.y:= (Points[Index].y * CosPhi) + (Points[Index].x * SinPhi);

   // translate the point to (Origin)
   Points[Index].x:= Point.x + Origin.x;
   Points[Index].y:= Point.y + Origin.y;
  end;

 Result:= Points;
end;

//---------------------------------------------------------------------------

function pRotate4c2(const Origin, Size: TPoint2; Angle,
 ScaleX, ScaleY: Real): TPoint4;
begin
 Result:= pRotate42(Origin, Size, Point2(Size.x * 0.5, Size.y * 0.5), Angle, ScaleX, ScaleY);
end;

function pRotateTransForm(const X, Y, X1, Y1, X2, Y2, X3, Y3, X4, Y4 ,
 CenterX, CenterY, Angle: Real; Scale: Real = 1.0): TPoint4;
var
 CosPhi: Real;
 SinPhi: Real;
 Index : Integer;
 Points: TPoint4;
 Point : TPoint2;
begin
 CosPhi:= Cos(Angle);
 SinPhi:= Sin(Angle);

 // create 4 points centered at (0, 0)
 Points:= Point4(X1-CenterX, Y1-CenterY, X2-CenterX, Y2-CenterY,
                  X3-CenterX, Y3-CenterY, X4-CenterX, Y4-CenterY);

 // process the created points
 for Index:= 0 to 3 do
  begin
   // scale the point
   Points[Index].X:= Points[Index].X * Scale;
   Points[Index].Y:= Points[Index].Y * Scale;

   // rotate the point around Phi
   Point.x:= (Points[Index].X * CosPhi) - (Points[Index].Y * SinPhi);
   Point.y:= (Points[Index].Y * CosPhi) + (Points[Index].X * SinPhi);

   // translate the point to (Origin)
   Points[Index].X:= Point.X + X ;
   Points[Index].Y:= Point.Y + Y ;
  end;

 Result:= Points;
end;

function pRotateTransForm2(const X, Y, X1, Y1, X2, Y2, X3, Y3, X4, Y4 ,
 CenterX, CenterY, Angle, ScaleX, ScaleY: Real): TPoint4;
var
 CosPhi: Real;
 SinPhi: Real;
 Index : Integer;
 Points: TPoint4;
 Point : TPoint2;
begin
 CosPhi:= Cos(Angle);
 SinPhi:= Sin(Angle);

 // create 4 points centered at (0, 0)
 Points:= Point4(X1-CenterX, Y1-CenterY, X2-CenterX, Y2-CenterY,
                  X3-CenterX, Y3-CenterY, X4-CenterX, Y4-CenterY);

 // process the created points
 for Index:= 0 to 3 do
  begin
   // scale the point
   Points[Index].X:= Points[Index].X * ScaleX;
   Points[Index].Y:= Points[Index].Y * ScaleY;

   // rotate the point around Phi
   Point.x:= (Points[Index].X * CosPhi) - (Points[Index].Y * SinPhi);
   Point.y:= (Points[Index].Y * CosPhi) + (Points[Index].X * SinPhi);

   // translate the point to (Origin)
   Points[Index].X:= Point.X + X ;
   Points[Index].Y:= Point.Y + Y ;
  end;

 Result:= Points;
end;

//---------------------------------------------------------------------------
function BezierPoints(const OriginPoint, DestPoint, C1Point, C2Point: TPoint): TBezierPoints;
begin
  Result[0] := OriginPoint;
  Result[1] := C1Point;
  Result[2] := C2Point;
  Result[3] := DestPoint;
end;

function BezierPoints(const OriginPoint, DestPoint, C1Point, C2Point: TPoint2): TBezierPoints2;
begin
  Result[0] := OriginPoint;
  Result[1] := C1Point;
  Result[2] := C2Point;
  Result[3] := DestPoint;
end;

//---------------------------------------------------------------------------
function OverlapQuadrangle(const Q1, Q2: TPoint4): Boolean;
var
 d1, d2, d3, d4: Single;
begin
 d1:= (Q1[2].X - Q1[1].X) * (Q2[0].X - Q1[0].X) + (Q1[2].Y - Q1[1].Y) *
  (Q2[0].Y - Q1[0].Y);
 d2:= (Q1[3].X - Q1[2].X) * (Q2[0].X - Q1[1].X) + (Q1[3].Y - Q1[2].Y) *
  (Q2[0].Y - Q1[1].Y);
 d3 := (Q1[0].X - Q1[3].X) * (Q2[0].X - Q1[2].X) + (Q1[0].Y - Q1[3].Y) *
  (Q2[0].Y - Q1[2].Y);
 d4:= (Q1[1].X - Q1[0].X) * (Q2[0].X - Q1[3].X) + (Q1[1].Y - Q1[0].Y) *
  (Q2[0].Y - Q1[3].Y);

 if (d1 >= 0) and (d2 >= 0) and (d3 >= 0) and (d4 >= 0) then
 begin
  Result:= True;
  Exit;
 end;

 d1:= (Q1[2].X - Q1[1].X) * (Q2[1].X - Q1[0].X) + (Q1[2].Y - Q1[1].Y) *
  (Q2[1].Y - Q1[0].Y);
 d2:= (Q1[3].X - Q1[2].X) * (Q2[1].X - Q1[1].X) + (Q1[3].Y - Q1[2].Y) *
  (Q2[1].Y - Q1[1].Y);
 d3:= (Q1[0].X - Q1[3].X) * (Q2[1].X - Q1[2].X) + (Q1[0].Y - Q1[3].Y) *
  (Q2[1].Y - Q1[2].Y);
 d4:= (Q1[1].X - Q1[0].X) * (Q2[1].X - Q1[3].X) + (Q1[1].Y - Q1[0].Y) *
  (Q2[1].Y - Q1[3].Y);
 if (d1 >= 0) and (d2 >= 0) and (d3 >= 0) and (d4 >= 0) then
 begin
  Result:= True;
  Exit;
 end;

 d1:= (Q1[2].X - Q1[1].X) * (Q2[2].X - Q1[0].X) + (Q1[2].Y - Q1[1].Y) *
  (Q2[2].Y - Q1[0].Y);
 d2:= (Q1[3].X - Q1[2].X) * (Q2[2].X - Q1[1].X) + (Q1[3].Y - Q1[2].Y) *
  (Q2[2].Y - Q1[1].Y);
 d3:= (Q1[0].X - Q1[3].X) * (Q2[2].X - Q1[2].X) + (Q1[0].Y - Q1[3].Y) *
  (Q2[2].Y - Q1[2].Y);
 d4:= (Q1[1].X - Q1[0].X) * (Q2[2].X - Q1[3].X) + (Q1[1].Y - Q1[0].Y) *
  (Q2[2].Y - Q1[3].Y);
 if(d1 >= 0) and (d2 >= 0) and (d3 >= 0) and (d4 >= 0) then
 begin
  Result := True;
  Exit;
 end;

 d1:= (Q1[2].X - Q1[1].X) * (Q2[3].X - Q1[0].X) + (Q1[2].Y - Q1[1].Y) *
  (Q2[3].Y - Q1[0].Y);
 d2:= (Q1[3].X - Q1[2].X) * (Q2[3].X - Q1[1].X) + (Q1[3].Y - Q1[2].Y) *
  (Q2[3].Y - Q1[1].Y);
 d3:= (Q1[0].X - Q1[3].X) * (Q2[3].X - Q1[2].X) + (Q1[0].Y - Q1[3].Y) *
  (Q2[3].Y - Q1[2].Y);
 d4:= (Q1[1].X - Q1[0].X) * (Q2[3].X - Q1[3].X) + (Q1[1].Y - Q1[0].Y) *
  (Q2[3].Y - Q1[3].Y);
 if (d1 >= 0) and (d2 >= 0) and (d3 >= 0) and (d4 >= 0) then
 begin
  Result:= True;
  Exit;
 end;

 Result:= False;
end;

//---------------------------------------------------------------------------
{ algorithm by Paul Bourke }
function PtInPolygon(const Pt: TPoint2; const Pg: TAsphyrePolygon): Boolean;
var
  N, Counter , I : Integer;
  XInters : Real;
  P1, P2 : TPoint2;
begin
  N := High(Pg);
  Counter := 0;
  P1 := Pg[0];
  for I := 1 to N do
  begin
    P2 := Pg[I mod N];
    if Pt.y > Min(P1.y, P2.y) then
      if Pt.y <= Max(P1.y, P2.y) then
        if Pt.x <= Max(P1.x, P2.x) then
          if P1.y <> P2.y then
          begin
            XInters := (Pt.y - P1.y) * (P2.x - P1.x) / (P2.y - P1.y) + P1.x;
            if (P1.x = P2.x) or (Pt.x <= XInters) then Inc(Counter);
          end;
    P1 := P2;
  end;
  Result := (Counter mod 2 <> 0);
end;

//---------------------------------------------------------------------------
{ NOTE: last points of polygons must be the first one ( P1[0] = P1[N]  ; P2[0] = P2[N] ) }
function OverlapPolygon(const P1, P2: TAsphyrePolygon): Boolean;
var
  Poly1, Poly2 : TAsphyrePolygon;
  I, J : Integer;
  xx , yy : Single;
  StartP, EndP : Integer;
  Found : Boolean;
begin
  Found := False;
  { Find polygon with fewer points }
  if High(P1) < High(P2) then
  begin
    Poly1 := P1;
    Poly2 := P2;
  end
  else
  begin
    Poly1 := P2;
    Poly2 := P1;
  end;

  for I := 0 to High(Poly1) - 1 do
  begin
    { Trace new line }
    StartP := Round(Min(Poly1[I].x, Poly1[I+1].x));
    EndP   := Round(Max(Poly1[I].x, Poly1[I+1].x));


    if StartP = EndP then
    { A vertical line (ramp = inf) }
    begin
      xx := StartP;
      StartP := Round(Min(Poly1[I].y, Poly1[I+1].y));
      EndP   := Round(Max(Poly1[I].y, Poly1[I+1].y));
      { Follow a vertical line }
      for J := StartP to EndP do
      begin
        { line equation }
        if PtInPolygon(Point2(xx,J), Poly2) then
        begin
          Found := True;
          Break;
        end;
      end;
    end
    else
    { Follow a usual line (ramp <> inf) }
    begin
      { A Line which X is its variable i.e. Y = f(X) }
      if Abs(Poly1[I].x -  Poly1[I+1].x) >= Abs(Poly1[I].y -  Poly1[I+1].y) then
      begin
        StartP := Round(Min(Poly1[I].x, Poly1[I+1].x));
        EndP   := Round(Max(Poly1[I].x, Poly1[I+1].x));
        for J := StartP to EndP do
        begin
          xx := J;
          { line equation }
          yy := (Poly1[I+1].y - Poly1[I].y) / (Poly1[I+1].x - Poly1[I].x) * (xx - Poly1[I].x) + Poly1[I].y;
          if PtInPolygon(Point2(xx,yy), Poly2) then
          begin
            Found := True;
            Break;
          end;
        end;
      end
      { A Line which Y is its variable i.e. X = f(Y) }
      else
      begin
        StartP := Round(Min(Poly1[I].y, Poly1[I+1].y));
        EndP   := Round(Max(Poly1[I].y, Poly1[I+1].y));
        for J := StartP to EndP do
        begin
          yy := J;
          { line equation }
          xx := (Poly1[I+1].x - Poly1[I].x) / (Poly1[I+1].y - Poly1[I].y) * (yy - Poly1[I].y) + Poly1[I].x;
          if PtInPolygon(Point2(xx,yy), Poly2) then
          begin
            Found := True;
            Break;
          end;
        end;
      end;
    end;
    if Found then Break;
  end;

  { Maybe one polygon is completely inside another }
  if not Found then
    Found := PtInPolygon(Poly1[0], Poly2) or PtInPolygon(Poly2[0], Poly1);

  Result := Found;
end;



//---------------------------------------------------------------------------
//precalculated fixed  point  cosines for a full circle
var
  CosTable8  : array[0..7]   of Double;
  CosTable16 : array[0..15]  of Double;
  CosTable32 : array[0..31]  of Double;
  CosTable64 : array[0..63]  of Double;
  CosTable128: array[0..127] of Double;
  CosTable256: array[0..255] of Double;
  CosTable512: array[0..511] of Double;

procedure InitCosTable;
var
  i: Integer;
begin
   for i:=0 to 7 do
    CosTable8[i] := Cos((i/8)*2*PI);

   for i:=0 to 15 do
    CosTable16[i] := Cos((i/16)*2*PI);

   for i:=0 to 31 do
    CosTable32[i] := Cos((i/32)*2*PI);

   for i:=0 to 63 do
    CosTable64[i] := Cos((i/64)*2*PI);

   for i:=0 to 127 do
    CosTable128[i] := Cos((i/128)*2*PI);

   for i:=0 to 255 do
    CosTable256[i] := Cos((i/256)*2*PI);

   for i:=0 to 511 do
    CosTable512[i] := Cos((i/512)*2*PI);
end;

function Cos8(i: Integer): Real;
begin
  Result := CosTable8[i and 7];
end;

function Sin8(i: Integer): Real;
begin
  Result := CosTable8[(i+6) and 7];
end;

function Cos16(i: Integer): Real;
begin
  Result := CosTable16[i and 15];
end;

function Sin16(i: Integer): Real;
begin
  Result := CosTable16[(i+12) and 15];
end;

function Cos32(i: Integer): Real;
begin
  Result := CosTable32[i and 31];
end;

function Sin32(i: Integer): Real;
begin
  Result := CosTable32[(i+24) and 31];
end;

function Cos64(i: Integer): Real;
begin
  Result := CosTable64[i and 63];
end;

function Sin64(i: Integer): Real;
begin
  Result := CosTable64[(i+48) and 63];
end;

function Cos128(i: Integer): Real;
begin
  Result := CosTable128[i and 127];
end;

function Sin128(i: Integer): Real;
begin
  Result := CosTable128[(i+96) and 127];
end;

function Cos256(i: Integer): Real;
begin
  Result := CosTable256[i and 255];
end;

function Sin256(i: Integer): Real;
begin
  Result := CosTable256[(i+192) and 255];
end;

function Cos512(i: Integer): Real;
begin
  Result := CosTable512[i and 511];
end;

function Sin512(i: Integer): Real;
begin
  Result := CosTable512[(i+384) and 511];
end;

//---------------------------------------------------------------------------
initialization
 InitCosTable();

//---------------------------------------------------------------------------
end.
