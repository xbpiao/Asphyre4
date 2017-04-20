unit AsphyreSpriteUtils;
//---------------------------------------------------------------------------
// AsphyreSpriteUtils.pas                               Modified: 23-Jan-2007
// SpriteEngine: utility routines                                 Version 1.0
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
interface

//---------------------------------------------------------------------------
uses
 Windows, Types, AsphyreTypes, AsphyreSpriteDef, AsphyreCanvas, AsphyreImages,
 AsphyreDevices, Vectors2, Direct3D9, Math ,Vectors2px;

//---------------------------------------------------------------------------
// Sprite Engine helper functions
//---------------------------------------------------------------------------
procedure DrawEx(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage;
 PatternIndex: Integer; x, y, ScaleX, ScaleY: Real; DoCenter, MirrorX,
 MirrorY: Boolean; const Color: TColor4; DrawFx: Integer); overload;

procedure DrawEx(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawEx(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y: Real;
  const Color: TColor4; DrawFx: Integer); overload;
procedure DrawColor1(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Red, Green, Blue, Alpha: Byte; DrawFx: Integer); overload;
procedure DrawColor1(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Red, Green, Blue, Alpha: Byte; DrawFx: Integer); overload;
procedure DrawColor1(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y: Real;
  Red, Green, Blue, Alpha: Byte; DrawFx: Integer); overload;
procedure DrawAlpha1(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Alpha: Byte; DrawFx: Integer); overload;
procedure DrawAlpha1(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Alpha: Byte; DrawFx: Integer); overload;
procedure DrawAlpha1(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y: Real;
  Alpha: Byte; DrawFx: Integer); overload;
procedure DrawColor4(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Color1, Color2, Color3, Color4: Cardinal; DrawFx: Integer); overload;
procedure DrawColor4(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Color1, Color2, Color3, Color4: Cardinal; DrawFx: Integer); overload;
procedure DrawColor4(Canvas: TAsphyreCanvas; Image: TAsphyrecustomImage; PatternIndex: Integer; X, Y: Real;
  Color1, Color2, Color3, Color4: Byte; DrawFx: Integer); overload;
procedure DrawAlpha4(Canvas: TAsphyreCanvas; Image: TAsphyrecustomImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer); overload;
procedure DrawAlpha4(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer); overload;
procedure DrawAlpha4(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y: Real;
  Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer); overload;
procedure DrawStretch(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X1, Y1, X2, Y2: Integer;
  MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawStretch(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Width, Height,
  ScaleX, ScaleY: Real; DoCenter, MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawPortion(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y: Real;
  SrcX1, SrcY1, SrcX2, SrcY2: Integer; ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawPortion(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y: Real;
  SrcX1, SrcY1, SrcX2, SrcY2: Integer; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRectStretch(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X1, y1, X2, Y2: Real;
  SrcX1, SrcY1, SrcX2, SrcY2: Integer; MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer);
procedure DrawTransForm(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X1, Y1, X2, Y2,
  X3, Y3, X4, Y4: Real; MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer);
procedure DrawRectTransForm(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X1, Y1, X2, Y2,
  X3, Y3, X4, Y4: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
  MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer);
procedure DrawRotateC(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Angle: Real;
  const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotateC(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Angle,
  ScaleX, ScaleY: Real; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotateC(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Angle,
  ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotate(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
  Angle: Real; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotate(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
  Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotate(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
  Angle, ScaleX, ScaleY: Real; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotateStretchC(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y,
  Width, Height, Angle: Real; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotateStretchC(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y,
  Width, Height, Angle, ScaleX, ScaleY: Real; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotateStretchC(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y,
  Width, Height, Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean;
  const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotateStretch(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y,
  Width, Height, CenterX, CenterY, Angle: Real; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotateStretch(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y,
  Width, Height, CenterX, CenterY, Angle, ScaleX, ScaleY: Real; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotateStretch(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y,
  Width, Height, CenterX, CenterY, Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean;
  const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotateRect(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Angle,
  ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer; MirrorX, MirrorY: Boolean;
  const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotateRect(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Angle,
  CenterX, CenterY, ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
  MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer); overload;
procedure DrawRotateRect(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Width, Height, Angle,
  CenterX, CenterY, ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
  MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer); overload;
procedure SetGamma(Dev9: IDirect3DDevice9; Red, Green, Blue, Brightness, Contrast: Byte);


//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
procedure DrawEx(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage;
 PatternIndex: Integer; x, y, ScaleX, ScaleY: Real; DoCenter, MirrorX,
 MirrorY: Boolean; const Color: TColor4; DrawFx: Integer);
var
 vSize: TPoint2px;
begin
 vSize:= TAsphyreImage(Image).VisibleSize;

 Canvas.UseImage(Image, PatternIndex, Rect(0, 0, vSize.X, vSize.Y), MirrorX,
  MirrorY);

 case DoCenter of
  True:
   begin
    Canvas.TexMap(pBounds4sc2(x, y, vSize.X, vSize.Y, ScaleX, ScaleY), Color,
     DrawFx);
   end;
  False:
   begin
    Canvas.TexMap(pBounds4s2(x, y, vSize.X, vSize.Y, ScaleX, ScaleY), Color,
     DrawFx);
   end;
 end;
end;

procedure DrawEx(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; const Color: TColor4; DrawFx: Integer);
var
 vSize: TPoint2px;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image, PatternIndex);
  case DoCenter of
    True:
      begin
        Canvas.TexMap( pBounds4sc(X, Y, vSize.X, vSize.Y, Scale),
          Color, DrawFx);
      end;
    False:
      begin
        Canvas.TexMap( pBounds4s(X, Y, vSize.X, vSize.Y, Scale),
          Color,  DrawFx);
      end;
  end;

end;
procedure DrawEx(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer;
  X, Y: Real;  const Color: TColor4; DrawFx: Integer);
var
  vSize: TPoint2px;
begin
   vSize:= TAsphyreImage(Image).VisibleSize;
   Canvas.UseImage(Image,PatternIndex);
   Canvas.TexMap( pBounds4(X, Y, vSize.X, vSize.Y), Color, DrawFx);
end;

procedure DrawColor1(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Red, Green, Blue, Alpha: Byte; DrawFx: Integer);
begin
  DrawEx(Canvas, Image, PatternIndex, X, Y, ScaleX, ScaleY,
    DoCenter, MirrorX, MirrorY, cRGB4(Red, Green, Blue, Alpha), DrawFx);
end;

procedure DrawColor1(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Red, Green, Blue, Alpha: Byte; DrawFx: Integer);
begin
  DrawEx(Canvas, Image, PatternIndex, X, Y, Scale, DoCenter, cRGB4(Red, Green, Blue, Alpha), DrawFx);
end;

procedure DrawColor1(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y: Real;
  Red, Green, Blue, Alpha: Byte; DrawFx: Integer);
var
  vSize: TPoint;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image,PatternIndex);
  Canvas.TexMap( pBounds4(X, Y, vSize.X, vSize.Y),
    cRGB4(Red, Green, Blue, Alpha),  DrawFx);
end;

procedure DrawAlpha1(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Alpha: Byte; DrawFx: Integer);
begin
  DrawEx(Canvas, Image, PatternIndex, X, Y, ScaleX, ScaleY,
    DoCenter, MirrorX, MirrorY, cAlpha4(Alpha), DrawFx);
end;

procedure DrawAlpha1(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Alpha: Byte; DrawFx: Integer);
begin
   DrawEx(Canvas, Image, PatternIndex, X, Y, Scale, DoCenter, cAlpha4(Alpha), DrawFx);
end;
procedure DrawAlpha1(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y: Real;
  Alpha: Byte; DrawFx: Integer);
var
 vSize: TPoint;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image,PatternIndex);
  Canvas.TexMap( pBounds4(X, Y, vSize.X, vSize.Y),
    cAlpha4(Alpha), DrawFx);
end;

procedure DrawColor4(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Color1, Color2, Color3, Color4: Cardinal; DrawFx: Integer); overload;
begin
  DrawEx(Canvas, Image, PatternIndex, X, Y, ScaleX, ScaleY, DoCenter,
    MirrorX, MirrorY, cColor4(Color1, Color2, Color3, Color4), DrawFx);
end;

procedure DrawColor4(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Color1, Color2, Color3, Color4: Cardinal; DrawFx: Integer);
begin
  DrawEx(Canvas, Image, PatternIndex, X, Y, Scale, DoCenter,
    cColor4(Color1, Color2, Color3, Color4), DrawFx);
end;

procedure DrawColor4(Canvas: TAsphyreCanvas; Image: TAsphyrecustomImage; PatternIndex: Integer; X, Y: Real;
  Color1, Color2, Color3, Color4: Byte; DrawFx: Integer);
var
  vSize: TPoint;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image,PatternIndex);
  Canvas.TexMap( pBounds4(X, Y, vsize.X, vSize.Y),
    cColor4(Color1, Color2, Color3, Color4),DrawFx);
end;

procedure DrawAlpha4(Canvas: TAsphyreCanvas; Image: TAsphyrecustomImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer);
begin
  DrawEx(Canvas, Image, PatternIndex, X, Y, ScaleX, ScaleY, DoCenter,
    MirrorX, MirrorY, cAlpha4(Alpha1, Alpha2, Alpha3, Alpha4), DrawFx);
end;

procedure DrawAlpha4(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer);
begin
  DrawEx(Canvas, Image, PatternIndex, X, Y, Scale, DoCenter,
    cAlpha4(Alpha1, Alpha2, Alpha3, Alpha4), DrawFx);
end;

procedure DrawAlpha4(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y: Real;
  Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer);
var
  vSize: TPoint;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image,PatternIndex);
  Canvas.TexMap( pBounds4(X, Y, TAsphyreImage(Image).PatternSize.X, TAsphyreImage(Image).PatternSize.Y),
    cAlpha4(Alpha1, Alpha2, Alpha3, Alpha4), DrawFx);
end;

procedure DrawStretch(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X1, Y1, X2, Y2: Integer;
  MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer);
var
  vSize: TPoint;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image, PatternIndex, Rect(0, 0, vSize.X, vSize.Y), MirrorX, MirrorY);
  Canvas.TexMap( pRect4(Rect(X1, Y1, X2, Y2)), Color,  DrawFx);
end;
procedure DrawStretch(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Width, Height,
  ScaleX, ScaleY: Real; DoCenter, MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer);
var
  vSize: TPoint;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image,PatternIndex, Rect(0, 0, vSize.X, vSize.Y), MirrorX, MirrorY);
  case DoCenter of
    True: Canvas.TexMap( pBounds4sc2(X, Y, Width, Height, ScaleX, ScaleY), Color,  DrawFx);
    False: Canvas.TexMap( pBounds4s2(X, Y, Width, Height, ScaleX, ScaleY), Color,  DrawFx);
  end;
end;

procedure DrawPortion(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y: Real;
  SrcX1, SrcY1, SrcX2, SrcY2: Integer; ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer);
begin
  Canvas.UseImage(Image, PatternIndex, Rect(SrcX1, SrcY1, SrcX2-SrcX1, SrcY2-SrcY1), MirrorX, MirrorY);
  case DoCenter of
    True: Canvas.TexMap( pBounds4sc2(X, Y, SrcX2-SrcX1, SrcY2-SrcY1, ScaleX, ScaleY),
        Color,  DrawFx);

    False: Canvas.TexMap( pBounds4s2(X, Y, SrcX2-SrcX1, SrcY2-SrcY1, ScaleX, ScaleY),
        Color,  DrawFx);
  end;
end;

procedure DrawPortion(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y: Real;
  SrcX1, SrcY1, SrcX2, SrcY2: Integer; const Color: TColor4; DrawFx: Integer);
begin
  Canvas.UseImage(Image, PatternIndex, Rect(SrcX1, SrcY1, SrcX2-SrcX1, SrcY2-SrcY1), False, False);
  Canvas.TexMap(pBounds4(X, Y, SrcX2-SrcX1, SrcY2-SrcY1), Color,  DrawFx);
end;

procedure DrawRectStretch(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X1, y1, X2, Y2: Real;
  SrcX1, SrcY1, SrcX2, SrcY2: Integer; MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer);
begin
  Canvas.UseImage(Image, PatternIndex, Rect(SrcX1, SrcY1, SrcX2-SrcX1, SrcY2-SrcY1), False, False);
  Canvas.TexMap(pBounds4(X1, Y1, X2, Y2), Color,  DrawFx);
end;

procedure DrawTransForm(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X1, Y1, X2, Y2,
  X3, Y3, X4, Y4: Real; MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer);
begin
  Canvas.UseImage(Image, PatternIndex,
    Rect(0, 0, TAsphyreImage(Image).PatternSize.X, TAsphyreImage(Image).PatternSize.Y), MirrorX, MirrorY);
  Canvas.TexMap( Point4(X1, Y1, X2, Y2, X3, Y3, X4, Y4), Color,  DrawFx);
end;

procedure DrawRectTransForm(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X1, Y1, X2, Y2,
  X3, Y3, X4, Y4: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
  MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer);
begin
 Canvas.UseImage(Image, PatternIndex, Rect(SrcX1, SrcY1, SrcX2-SrcX1, SrcY2-SrcY1), MirrorX, MirrorY);
 Canvas.TexMap( Point4(X1, Y1, X2, Y2, X3, Y3, X4, Y4), Color,  DrawFx);
end;

procedure DrawRotateC(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Angle: Real;
  const Color: TColor4; DrawFx: Integer);
var
  vSize: TPoint;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image,PatternIndex); //pRotate4
  Canvas.TexMap( pRotate4c(Point2(X, Y), Point2(vSize.X, vSize.Y), Angle,1),
    Color, DrawFx);
//  Canvas.TexMap( pRotate4(Point2(X, Y), Point2(vSize.X, vSize.Y),Point2(0,0), Angle,1),
//    Color, DrawFx);
end;

procedure DrawRotateC(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Angle,
  ScaleX, ScaleY: Real; const Color: TColor4; DrawFx: Integer);
var
  vSize: TPoint;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image,PatternIndex);
  Canvas.TexMap( pRotate4c2(Point2(X, Y), Point2(vSize.X, vSize.Y), Angle, ScaleX, ScaleY),
     Color,  DrawFx);
end;

procedure DrawRotateC(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage;
  PatternIndex: Integer; X, Y, Angle,ScaleX, ScaleY: Real;
  MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer);
var
  vSize: TPoint;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image, PatternIndex,Rect(0, 0, vSize.X, vSize.Y), MirrorX, MirrorY);
  Canvas.TexMap( pRotate4c2(Point2(X, Y), Point2(vSize.X, vSize.Y), Angle, ScaleX, ScaleY),
    Color,  DrawFx);
end;

procedure DrawRotate(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
  Angle: Real; const Color: TColor4; DrawFx: Integer);
var
  vSize: TPoint;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image,PatternIndex);
  Canvas.TexMap( pRotate4(Point2(X, Y), Point2(vSize.X, vSize.Y),
    Point2(CenterX, CenterY), Angle,1), Color,  DrawFx);
end;

procedure DrawRotate(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
  Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer);
var
  vSize: TPoint;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image,PatternIndex);
  Canvas.TexMap( pRotate42(Point2(X, Y), Point2(vSize.X, vSize.Y),
    Point2(CenterX, CenterY), Angle, ScaleX, ScaleY), Color, DrawFx);
end;

procedure DrawRotate(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
  Angle, ScaleX, ScaleY: Real; const Color: TColor4; DrawFx: Integer);
var
  vSize: TPoint;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image,PatternIndex);
  Canvas.TexMap( pRotate42(Point2(X, Y), Point2(vSize.X, vsize.Y),
    Point2(CenterX, CenterY), Angle, ScaleX, ScaleY), Color, DrawFx);
end;

procedure DrawRotateStretchC(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y,
  Width, Height, Angle: Real; const Color: TColor4; DrawFx: Integer);
begin
  Canvas.UseImage(Image,PatternIndex);
  Canvas.TexMap( pRotate4c(Point2(X, Y), Point2(Width, Height), Angle,1),
    Color, DrawFx);
end;

procedure DrawRotateStretchC(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y,
  Width, Height, Angle, ScaleX, ScaleY: Real; const Color: TColor4; DrawFx: Integer);
begin
  Canvas.UseImage(Image,PatternIndex);
  Canvas.TexMap( pRotate4c2(Point2(X, Y), Point2(Width, Height), Angle, ScaleX, ScaleY),
    Color, DrawFx);
end;
procedure DrawRotateStretchC(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y,
  Width, Height, Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean;
  const Color: TColor4; DrawFx: Integer);
var
  vSize: TPoint;
begin
  vSize:= TAsphyreImage(Image).VisibleSize;
  Canvas.UseImage(Image,PatternIndex, Rect(0, 0, vSize.X, vSize.Y), MirrorX, MirrorY);
  Canvas.TexMap( pRotate4c2(Point2(X, Y), Point2(Width, Height), Angle, ScaleX, ScaleY),
    Color,  DrawFx);
end;
procedure DrawRotateStretch(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y,
  Width, Height, CenterX, CenterY, Angle: Real; const Color: TColor4; DrawFx: Integer);
begin
  Canvas.UseImage(Image,PatternIndex);
  Canvas.TexMap( pRotate4(Point2(X, Y), Point2(Width, Height), Point2(CenterX, CenterY), Angle,1),
    Color,  DrawFx);
end;

procedure DrawRotateStretch(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y,
  Width, Height, CenterX, CenterY, Angle, ScaleX, ScaleY: Real; const Color: TColor4; DrawFx: Integer); overload;
begin
  Canvas.UseImage(Image,PatternIndex);
  Canvas.TexMap( pRotate42(Point2(X, Y), Point2(Width, Height), Point2(CenterX, CenterY), Angle,
    ScaleX, ScaleY), Color, DrawFx);
end;

procedure DrawRotateStretch(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y,
  Width, Height, CenterX, CenterY, Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean;
  const Color: TColor4; DrawFx: Integer);
begin
  Canvas.UseImage(Image,PatternIndex);
  Canvas.TexMap( pRotate42(Point2(X, Y), Point2(Width, Height), Point2(CenterX, CenterY), Angle,
    ScaleX, ScaleY), Color,  DrawFx);
end;

procedure DrawRotateRect(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Angle,
  ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer; MirrorX, MirrorY: Boolean;
  const Color: TColor4; DrawFx: Integer);
begin
  Canvas.UseImage(Image, PatternIndex, Rect(SrcX1, SrcY1, SrcX2-SrcX1, SrcY2-SrcY1), MirrorX, MirrorY);
  Canvas.TexMap( pRotate4c2(Point2(X, Y), Point2(SrcX2-SrcX1, SrcY2-SrcY1), Angle,
    ScaleX, ScaleY), Color,  DrawFx);
end;

procedure DrawRotateRect(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Angle,
  CenterX, CenterY, ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
  MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer);
begin
  Canvas.UseImage(Image, PatternIndex, Rect(SrcX1, SrcY1, SrcX2-SrcX1, SrcY2-SrcY1), MirrorX, MirrorY);
  Canvas.TexMap(pRotate42(Point2(X, Y), Point2(SrcX2-SrcX1, SrcY2-SrcY1),
    Point2(CenterX, CenterY), Angle, ScaleX, ScaleY), Color,  DrawFx);
end;

procedure DrawRotateRect(Canvas: TAsphyreCanvas; Image: TAsphyreCustomImage; PatternIndex: Integer; X, Y, Width, Height, Angle,
  CenterX, CenterY, ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
  MirrorX, MirrorY: Boolean; const Color: TColor4; DrawFx: Integer); overload;
begin
  Canvas.UseImage(Image, PatternIndex, Rect(SrcX1, SrcY1, SrcX2-SrcX1, SrcY2-SrcY1), MirrorX, MirrorY);
  Canvas.TexMap( pRotate42(Point2(X, Y), Point2(Width, Height),
    Point2(CenterX, CenterY), Angle, ScaleX, ScaleY), Color, DrawFx);
end;

procedure SetGamma(Dev9: IDirect3DDevice9; Red, Green, Blue, Brightness, Contrast: Byte);
var
  FGammaRamp: TD3DGammaRamp;
  k: Single;
  k2, i: Integer;
begin
  for i := 0 to 255 do
  begin
    FGammaRamp.Red[i] := i * (Red + 1);
    FGammaRamp.Green[i] := i * (Green + 1);
    FGammaRamp.Blue[i] := i * (Blue + 1);
  end;

  with FGammaRamp do
  begin
    k := (Contrast / 128) - 1;
    if (k < 1) then
      for i := 0 to 255 do
      begin
        if (Red[i] > 32767.5) then
          Red[i] := Min(Round(Red[i] + (Red[i] - 32767.5) * k), 65535)
        else Red[i] := Max(Round(Red[i] - (32767.5 - Red[i]) * k), 0);
        if (Green[i] > 32767.5) then
          Green[i] := Min(Round(Green[i] + (Green[i] - 32767.5) * k), 65535)
        else Green[i] := Max(Round(Green[i] - (32767.5 - Green[i]) * k), 0);
        if (Blue[i] > 32767.5) then
          Blue[i] := Min(Round(Blue[i] + (Blue[i] - 32767.5) * k), 65535)
        else Blue[i] := Max(Round(Blue[i] - (32767.5 - Blue[i]) * k), 0);
      end else
      for i := 0 to 255 do
      begin
        if (Red[i] > 32767.5) then
          Red[i] := Max(Round(Red[i] - (Red[i] - 32767.5) * k), 32768)
        else Red[i] := Min(Round(Red[i] + (32767.5 - Red[i]) * k), 32768);
        if (Green[i] > 32767.5) then
          Green[i] := Max(Round(Green[i] - (Green[i] - 32767.5) * k), 32768)
        else Green[i] := Min(Round(Green[i] + (32767.5 - Green[i]) * k), 32768);
        if (Blue[i] > 32767.5) then
          Blue[i] := Max(Round(Blue[i] - (Blue[i] - 32767.5) * k), 32768)
        else Blue[i] := Min(Round(Blue[i] + (32767.5 - Blue[i]) * k), 32768);
      end;

    k2 := Round(((Brightness / 128) - 1) * 65535);
    if (k2 < 0) then
      for i := 0 to 255 do
      begin
        Red[i] := Max(Red[i] + k2, 0);
        Green[i] := Max(Green[i] + k2, 0);
        Blue[i] := Max(Blue[i] + k2, 0);
      end
    else
      for i := 0 to 255 do
      begin
        Red[i] := Min(Red[i] + k2, 65535);
        Green[i] := Min(Green[i] + k2, 65535);
        Blue[i] := Min(Blue[i] + k2, 65535);
      end;
  end;

  Dev9.SetGammaRamp(0, D3DSGR_CALIBRATE, FGammaRamp);
end;



//---------------------------------------------------------------------------
end.
