unit AsphyreSpriteEffects;
//---------------------------------------------------------------------------
// SpriteEffects.pas                                    Modified: 23-Jan-2007
// SpriteEngine: blending effects                                 Version 1.0
//---------------------------------------------------------------------------
// A modification of the code written by DraculaLin.
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
 AsphyreEffects, AsphyreTypes,
 {$IFDEF AsphyreUseDx8}
   Direct3D8
 {$ELSE}
   Direct3D9
 {$ENDIF}
 ;

//---------------------------------------------------------------------------
const
 fxuSrcColorAdd   = $200;
 fxuInvert        = $201;
 fxuSrcBright     = $202;
 fxuDestBright    = $203;
 fxuInvSrcBright  = $204;
 fxuInvDestBright = $205;
 fxuMultiplyAlpha = $206;

 fxuAdd2X         = $207;
 fxuLight         = $208;
 fxuLightAdd      = $209;
 fxuBright        = $20A;
 fxuBrightAdd     = $20B;
 fxuGrayScale     = $20C;
 fxuOneColor      = $20D;

//---------------------------------------------------------------------------
type
 TSpriteEffects = class
 protected
 {$IFDEF AsphyreUseDx8}
  procedure EffectHandler(Sender: TObject; const Dev9: IDirect3DDevice8;
   var Code: Integer; var Handled: Boolean);
 {$ELSE}
  procedure EffectHandler(Sender: TObject; const Dev9: IDirect3DDevice9;
   var Code: Integer; var Handled: Boolean);
 {$ENDIF}
 public
  constructor Create();
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
var
 SpriteEffects: TSpriteEffects = nil;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
constructor TSpriteEffects.Create();
begin
 inherited;

 EffectManager.Include(EffectHandler);
end;

//---------------------------------------------------------------------------
destructor TSpriteEffects.Destroy();
begin
 EffectManager.Exclude(EffectHandler);

 inherited;
end;

//---------------------------------------------------------------------------
{$IFDEF AsphyreUseDx8}
procedure TSpriteEffects.EffectHandler(Sender: TObject;
  const Dev9: IDirect3DDevice8; var Code: Integer; var Handled: Boolean);
{$ELSE}
procedure TSpriteEffects.EffectHandler(Sender: TObject;
 const Dev9: IDirect3DDevice9; var Code: Integer; var Handled: Boolean);
{$ENDIF}
begin
 case Code of
  fxuSrcColorAdd:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuInvert:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_INVDESTCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ZERO);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuSrcBright:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_SRCCOLOR);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuDestBright:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_DESTCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_DESTCOLOR);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuInvSrcBright:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_INVSRCCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCCOLOR);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuInvDestBright:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_INVDESTCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVDESTCOLOR);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuMultiplyAlpha:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ZERO);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_SRCALPHA);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuAdd2X:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE2X);
    Dev9.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

    Handled:= True;
   end;

  fxuLight:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_DESTCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE2X);
    Dev9.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

    Handled:= True;
   end;

  fxuLightAdd:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_DESTCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE4X);
    Dev9.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

    Handled:= True;
   end;

  fxuBright:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE2X);
    Dev9.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

    Handled:= True;
   end;

  fxuBrightAdd:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE4X);
    Dev9.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

    Handled:= True;
   end;

  fxuGrayScale:
   begin
    Dev9.SetRenderState(D3DRS_TextureFactor,Integer((cRGB1(155, 255, 155,
     155))));
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_DOTPRODUCT3);
    Dev9.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_TFACTOR);

    Handled:= True;
   end;

  fxuOneColor:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, 25);
    Dev9.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

    Handled:= True;
   end;
 end;
end;


//---------------------------------------------------------------------------
initialization
 SpriteEffects:= TSpriteEffects.Create();

//---------------------------------------------------------------------------
finalization
 SpriteEffects.Free();
 SpriteEffects:= nil;

//---------------------------------------------------------------------------
end.
