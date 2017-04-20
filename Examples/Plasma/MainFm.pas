unit MainFm;
//---------------------------------------------------------------------------
// Asphyre example application                          Modified: 21-Feb-2007
// Copyright (c) 2000 - 2007  Afterwarp Interactive
//---------------------------------------------------------------------------
// This demo illustrates how to render isometric terrain with variable
// height using Asphyre.
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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, AsphyreDevices, AsphyrePalettes, AsphyreTypes;

//---------------------------------------------------------------------------
type
  TMainForm = class(TForm)
    StatusBar1: TStatusBar;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    SinTab, CosTab: array[0..1023] of Word;
    PaletteTab: array[0..1023] of Cardinal;
    iShift, jShift: Integer;
    PalIndex: Integer;

    procedure InitPlasma();
    procedure InitPalette();
    procedure SetupDevice(Sender: TAsphyreDevice; Tag: TObject;
     var Config: TScreenConfig);
    procedure OnResolveFailed(Sender: TObject; EventParam: Pointer;
     var Success: Boolean);
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
    procedure DoPlasma(iShift, jShift: Integer);
  public
    { Public declarations }
  end;

//---------------------------------------------------------------------------
var
  MainForm: TMainForm;

//---------------------------------------------------------------------------
implementation
uses
 MediaImages, MediaFonts, AsphyreTimer, AsphyreImages, AsphyreFonts,
 AsphyreEffects, AsphyreEvents;
{$R *.dfm}

//---------------------------------------------------------------------------
procedure TMainForm.FormCreate(Sender: TObject);
begin
 InitPlasma();
 InitPalette();

 // retreive image and font descriptions
 ImageGroups.ParseLink('/media.xml');
 FontGroups.ParseLink('/media.xml');

 if (not Devices.Initialize(SetupDevice, Self)) then
  begin
   MessageDlg('Failed to initialize Asphyre device.', mtError, [mbOk], 0);
   Close();
   Exit;
  end;

 // configure Asphyre timer
 Timer.Enabled  := True;
 Timer.OnTimer  := TimerEvent;
 Timer.OnProcess:= ProcessEvent;
 Timer.MaxFPS   := 4000;
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormDestroy(Sender: TObject);
begin
 Devices.Finalize();
end;

//---------------------------------------------------------------------------
procedure TMainForm.InitPlasma();
var
 i: Integer;
begin
 // make lookup tables
 for i:= 0 to 1023 do
  begin
   SinTab[i]:= (Trunc(Sin(2.0 * Pi * i / 1024.0) * 512) + 512) and $3FF;
   CosTab[i]:= (Trunc(Cos(2.0 * Pi * i / 1024.0) * 512) + 512) and $3FF;
  end;

 // sine / cosine displacers
 iShift:= 0;
 jShift:= 0;
end;

//---------------------------------------------------------------------------
procedure TMainForm.InitPalette();
var
 Palette: TAsphyrePalette;
 i: Integer;
begin
 Palette:= TAsphyrePalette.Create();
 Palette.Add($FF000000, ntSine, 0.0);
 Palette.Add($FF7E00FF, ntSine, 0.1);
 Palette.Add($FFE87AFF, ntSine, 0.2);
 Palette.Add($FF7E00FF, ntSine, 0.3);
 Palette.Add($FFFFFFFF, ntSine, 0.4);

 Palette.Add($FF000000, ntPlain, 0.5);
 Palette.Add($FF0500A8, ntBrake, 0.6);
 Palette.Add($FFBEFF39, ntAccel, 0.7);
 Palette.Add($FFFFC939, ntBrake, 0.8);
 Palette.Add($FFFFF58D, ntSine,  0.9);
 Palette.Add($FF000000, ntPlain, 1.0);

 for i:= 0 to 1023 do
  PaletteTab[i]:= Palette.Color[i / 1023.0];

 Palette.Free();
end;

//---------------------------------------------------------------------------
procedure TMainForm.SetupDevice(Sender: TAsphyreDevice; Tag: TObject;
  var Config: TScreenConfig);
begin
 Config.Width   := ClientWidth;
 Config.Height  := ClientHeight;
 Config.Windowed:= True;

 Config.WindowHandle:= Self.Handle;
 Config.HardwareTL  := False;

 EventResolveFailed.Subscribe(OnResolveFailed, Sender);
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormResize(Sender: TObject);
begin
 Devices[0].ChangeParams(ClientWidth, ClientHeight, True);
end;

//---------------------------------------------------------------------------
procedure TMainForm.OnResolveFailed(Sender: TObject; EventParam: Pointer;
 var Success: Boolean);
begin
 Timer.Enabled:= False;

 MessageDlg('Failed to resolve symbol ' + PChar(EventParam), mtError, [mbOk],
  0);

 Close();
end;

//---------------------------------------------------------------------------
procedure TMainForm.TimerEvent(Sender: TObject);
begin
 // place plasma on dynamic texture
 DoPlasma(iShift, jShift);

 Devices[0].Render(RenderPrimary, Self, 0);
 Timer.Process();
end;

//---------------------------------------------------------------------------
procedure TMainForm.RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
var
 i, j: Integer;
 DraftIndex, ScanIndex: Integer;
begin
 // retreive indexes to speed up the rendering
 DraftIndex:= Devices[0].Images.Image['pixelcanvas'].ImageIndex;
 ScanIndex := Devices[0].Images.Image['scanline'].ImageIndex;

 // draw plasma (tiled)
 for j:= 0 to (ClientHeight div 256) do
  for i:= 0 to (ClientWidth div 256) do
   begin
    Sender.Canvas.UseImage(Sender.Images[DraftIndex], TexFull4);
    Sender.Canvas.TexMap(pBounds4(i * 256, j * 256, 256, 256),
     clWhite4, fxuNoBlend);
   end;

 // apply scanline effect
 for j:= 0 to (ClientHeight div 64) do
  for i:= 0 to (ClientWidth div 64) do
   begin
    Sender.Canvas.UseImage(Sender.Images[ScanIndex], TexFull4);
    Sender.Canvas.TexMap(pBounds4(i * 64, j * 64, 64, 64),
    clWhite4, fxuMultiply);
   end;

 with Sender.Fonts.Font['x/tranceform'] do
  begin
   Options.Kerning:= -2;
   Options.ShowShadow:= True;

   TextOut('Frame Rate: ' + IntToStr(Timer.FrameRate), 4, 4, cColor2($FF9500FF,
    $FFFFFFFF));
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.ProcessEvent(Sender: TObject);
begin
 Inc(iShift);
 Dec(jShift);
 Inc(PalIndex);
end;

//---------------------------------------------------------------------------
procedure TMainForm.DoPlasma(iShift, jShift: Integer);
var
 Image: TAsphyreDraft;
 Bits : Pointer;
 Pitch: Integer;

 DestPtr: Pointer;

 i, j, Xadd, Cadd: Integer;
 pl: PLongword;
 Index: Integer;
begin
 // Gain direct access to our draft surface.
 Image:= TAsphyreDraft(Devices[0].Images.Image['pixelcanvas']);
 if (Image = nil)or(not Image.Draft.Lock(Bits, Pitch)) then Exit;

 // plasma rendering
 DestPtr:= Bits;
 for j:= 0 to 255 do
  begin
   pl:= DestPtr;

   // plasma shifts
   Xadd:= SinTab[((j shl 2) + iShift) and $3FF];
   Cadd:= CosTab[((j shl 2) + jShift) and $3FF];

   // render scanline
   for i:= 0 to 255 do
    begin
     Index:= (SinTab[((i shl 2) + Xadd) and $3FF] + Cadd + (PalIndex * 4)) and $3FF;
     if (Index > 511) then Index:= 1023 - Index;

     pl^:= PaletteTab[((Index div 4) + PalIndex) and $3FF];
     Inc(pl);
    end;

   // select the next scanline
   Inc(Integer(DestPtr), Pitch);
  end;

 // release the surface
 Image.Draft.Unlock();
end;

//---------------------------------------------------------------------------
end.
