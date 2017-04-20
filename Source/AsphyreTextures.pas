unit AsphyreTextures;
//---------------------------------------------------------------------------
// AsphyreTextures.pas                                  Modified: 24-Jan-2006
// Basic wrappers for Direct3D textures                           Version 1.0
//---------------------------------------------------------------------------
// Important Notice:
//
// If you modify/use this code or one of its parts either in original or
// modified form, you must comply with Mozilla Public License v1.1,
// specifically section 3, "Distribution Obligations". Failure to do so will
// result in the license breach, which will be resolved in the court.
// Remember that violating author's rights is considered a serious crime in
// many countries. Thank you!
//
// !! Please *read* Mozilla Public License 1.1 document located at:
//  http://www.mozilla.org/MPL/
//
// If you require any clarifications about the license, feel free to contact
// us or post your question on our forums at: http://www.afterwarp.net
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
//
// The Original Code is AsphyreTextures.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// Afterwarp Interactive. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Windows, Types, Classes, SysUtils, Vectors2px,
 AsphyreAsserts, MediaUtils, AsphyreArchives, Vectors2, AsphyreTypes 
 {$IFDEF DebugMode}, AsphyreDebug{$ENDIF},
 {$IFDEF AsphyreUseDx8}
 Direct3D8, D3DX8
 {$ELSE}
 Direct3D9, D3DX9
 {$ENDIF} ;

//---------------------------------------------------------------------------
type
 TAsphyreTextureType = (attManaged, attDynamic, attRenderTarget);

//---------------------------------------------------------------------------
 TAsphyreCustomTexture = class
 private
  FDevice   : TObject;
  FFormat   : TD3DFormat;
  FMipLevels: Cardinal;
  FSize     : TPoint;
 protected
  {$IFDEF AsphyreUseDx8}
  FTex9       : IDirect3DTexture8;
  {$ELSE}
  FTex9       : IDirect3DTexture9;
  {$ENDIF}
  FTextureType: TAsphyreTextureType;
  FInitialized: Boolean;

  procedure FindUsagePool(out Usage: Cardinal; out Pool: TD3DPool);
 public
  // The particular device this texture is bound to.
  property Device: TObject read FDevice;

  // Interface to Direct3D texture.
  {$IFDEF AsphyreUseDx8}
  property Tex9: IDirect3DTexture8 read FTex9;
  {$ELSE}
  property Tex9: IDirect3DTexture9 read FTex9;
  {$ENDIF}

  // Indicates whether the texture has been initialized successfully.
  property Initialized: Boolean read FInitialized;

  // The specific type of texture.
  property TextureType: TAsphyreTextureType read FTextureType;

  // The current size of the texture.
  property Size: TPoint read FSize write FSize;

  // The format of texture pixels; may differ after initialization.
  property Format: TD3DFormat read FFormat write FFormat;

  // Number of mip levels to be created.
  property MipLevels: Cardinal read FMipLevels write FMipLevels;

  function Initialize(): Boolean; virtual; abstract;
  procedure Finalize(); virtual; abstract;

  // Binds this texture to the specific stage.
  procedure Activate(Stage: Cardinal);

  // Converts pixel coordinates to logical coordinates [0..1].
  function CoordToLogical(const Coord: TPoint2px): TPoint2; virtual;

  // Converts logical coordinates [0..1] to pixel coordinates.
  function LogicalToCoord(const Coord: TPoint2): TPoint2px; virtual;

  // Converts an array of four texture coordinates in pixels to logical
  // values of [0..1].
  function CoordToLogical4(const Points: TPoint4px): TPoint4;

  constructor Create(ADevice: TObject); virtual;
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
 TAsphyrePlainTexture = class(TAsphyreCustomTexture)
 private
  FOrigSize   : TPoint2px;
  FPatternSize: TPoint2px;
  FPadding    : TPoint2px;
 protected
  function RefreshInfo(): Boolean;
 public
  // The original texture size, which stays unchanged.
  property OrigSize: TPoint2px read FOrigSize write FOrigSize;

  // The size of individual sub-images inside the texture.
  property PatternSize: TPoint2px read FPatternSize write FPatternSize;

  // The padding of individual patterns
  property Padding: TPoint2px read FPadding write FPadding;

  // initialize texture using SrcSize, Format and MipLevel config
  function Initialize(): Boolean; override;
  function InitializeEx(const Source: string; ColorKey: Cardinal): Boolean;
  procedure Finalize(); override;

  // These functions are overriden because pixel coordinates are given
  // in terms of "OrigSize" and not the actual texture size.
  function CoordToLogical(const Coord: TPoint2px): TPoint2; override;
  function LogicalToCoord(const Coord: TPoint2): TPoint2px; override;

  constructor Create(ADevice: TObject); override;
 end;

//---------------------------------------------------------------------------
 TAsphyreRenderTarget = class(TAsphyreCustomTexture)
 private
  FUseDepthStencil: Boolean;
  {$IFDEF AsphyreUseDx8}
  DepthStencil : IDirect3DSurface8;
  SavedSurface : IDirect3DSurface8;
  SavedDepthBuf: IDirect3DSurface8;
  {$ELSE}
  DepthStencil : IDirect3DSurface9;
  SavedSurface : IDirect3DSurface9;
  SavedDepthBuf: IDirect3DSurface9;
  {$ENDIF}
 protected
  function RefreshInfo(): Boolean;
 public
  // Determines whether to use depth/stencil buffers, assuming that the device
  // has depth/stencil buffer support enabled as well. The depth/stencil format
  // will match the one provided in the related TAsphyreDevice.
  property UseDepthStencil: Boolean read FUseDepthStencil write FUseDepthStencil;

  // initialize texture using SrcSize, Format and MipLevel config
  function Initialize(): Boolean; override;
  procedure Finalize(); override;

  // Start rendering on this render target.
  function BeginDraw(): Boolean;

  // End rendering on this render target.
  procedure EndDraw();

  constructor Create(ADevice: TObject); override;
 end;

//---------------------------------------------------------------------------
 TAsphyreDynamicTexture = class(TAsphyreCustomTexture)
 protected
  function RefreshInfo(): Boolean;
 public
  // initialize texture using SrcSize, Format and MipLevel config
  function Initialize(): Boolean; override;
  function InitializeEx(const Source: string; ColorKey: Cardinal): Boolean;
  procedure Finalize(); override;

  function Lock(out Bits: Pointer; out Pitch: Integer; Flag: Cardinal = D3DLOCK_DISCARD): Boolean;
  procedure Unlock();

  constructor Create(ADevice: TObject); override;
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 AsphyreDevices;

//---------------------------------------------------------------------------
constructor TAsphyreCustomTexture.Create(ADevice: TObject);
begin
 inherited Create();

 FDevice:= ADevice;

 Assert((FDevice <> nil)and(FDevice is TAsphyreDevice),
  msgDeviceUnspecified);

 FInitialized:= False;
 FTextureType:= attManaged;
 FFormat     := D3DFMT_UNKNOWN;
 FMipLevels  := D3DX_DEFAULT;
end;

//---------------------------------------------------------------------------
destructor TAsphyreCustomTexture.Destroy();
begin
 if (FInitialized) then Finalize();

 inherited;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCustomTexture.FindUsagePool(out Usage: Cardinal;
 out Pool: TD3DPool);
begin
 Usage:= 0;
 Pool := D3DPOOL_MANAGED;

 case TextureType of
  attDynamic:
   begin
    Usage:= D3DUSAGE_DYNAMIC;
    Pool := D3DPOOL_DEFAULT;
   end;

  attRenderTarget:
   begin
    Usage:= D3DUSAGE_RENDERTARGET;
    Pool := D3DPOOL_DEFAULT;
   end;
 end;
end;

//---------------------------------------------------------------------------
function TAsphyreCustomTexture.LogicalToCoord(const Coord: TPoint2): TPoint2px;
begin
 Result.X:= Round(Coord.x * FSize.X);
 Result.Y:= Round(Coord.y * FSize.Y);
end;

//---------------------------------------------------------------------------
function TAsphyreCustomTexture.CoordToLogical(const Coord: TPoint2px): TPoint2;
begin
 if (FSize.X > 0) then Result.x:= Coord.X / FSize.X else Result.x:= 0.0;
 if (FSize.Y > 0) then Result.y:= Coord.Y / FSize.Y else Result.y:= 0.0;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCustomTexture.Activate(Stage: Cardinal);
begin
 if (FDevice <> nil)and(FTex9 <> nil) then
 {$IFDEF AsphyreUseDx8}
 TAsphyreDevice(Device).Dev8.SetTexture(Stage, FTex9);
 {$ELSE}
  TAsphyreDevice(Device).Dev9.SetTexture(Stage, FTex9);
 {$ENDIF}
end;

//---------------------------------------------------------------------------
function TAsphyreCustomTexture.CoordToLogical4(
 const Points: TPoint4px): TPoint4;
var
 i: Integer;
begin
 for i:= 0 to 3 do
  Result[i]:= CoordToLogical(Points[i]);
end;

//---------------------------------------------------------------------------
constructor TAsphyrePlainTexture.Create(ADevice: TObject);
begin
 inherited;

 FTextureType:= attManaged;
 Format      := D3DFMT_UNKNOWN;
 MipLevels   := D3DX_DEFAULT;
end;

//---------------------------------------------------------------------------
function TAsphyrePlainTexture.RefreshInfo(): Boolean;
var
 Desc: TD3DSurfaceDesc;
begin
 Result:= (FTex9 <> nil);
 if (not Result) then Exit;

 Result:= Succeeded(FTex9.GetLevelDesc(0, Desc));
 if (Result) then
  begin
   FSize.X:= Desc.Width;
   FSize.Y:= Desc.Height;
   FFormat:= Desc.Format;
  end;
end;

//---------------------------------------------------------------------------
function TAsphyrePlainTexture.Initialize(): Boolean;
var
 Usage: Cardinal;
 Pool : TD3DPool;
begin
 Assert(not FInitialized, msgAlreadyInitialized);
 FindUsagePool(Usage, Pool);
 {$IFDEF AsphyreUseDx8}
 Result:= Succeeded(D3DXCreateTexture(TAsphyreDevice(Device).Dev8,
  FOrigSize.X, FOrigSize.Y, FMipLevels, Usage, FFormat, Pool, FTex9));
// Result:= Succeeded(TAsphyreDevice(Device).Dev8.CreateTexture(
//   FOrigSize.X, FOrigSize.Y, FMipLevels, Usage, FFormat, Pool, FTex9));
 {$ELSE}
 Result:= Succeeded(D3DXCreateTexture(TAsphyreDevice(Device).Dev9,
  FOrigSize.X, FOrigSize.Y, FMipLevels, Usage, FFormat, Pool, FTex9));
// Result:= Succeeded(TAsphyreDevice(Device).Dev9.CreateTexture(
//   FOrigSize.X, FOrigSize.Y, FMipLevels, Usage, FFormat, Pool, FTex9));
 {$ENDIF}
 if (not Result)or(not RefreshInfo()) then
  begin
   FTex9 := nil;
   Result:= False;
  end;

 FInitialized:= Result;
end;

//---------------------------------------------------------------------------
function TAsphyrePlainTexture.InitializeEx(const Source: string;
 ColorKey: Cardinal): Boolean;
var
 Usage: Cardinal;
 Pool : TD3DPool;
 Info : TD3DXImageInfo;
 TempPath, TempFile: AnsiString;
 tmpFile: AnsiString;
 MemStream: TMemoryStream;
begin
 FindUsagePool(Usage, Pool);

 if (IsArchiveLink(Source)) then
  begin
   if (ArchiveManager.ShouldUseDisk(Source)) then
    begin // archive is to be extracted to disk first
     {$IFDEF DebugMode}
     DebugLog(' + Extracting texture ' + ExtractArchiveKey(Source) + ' from ' +
      ExtractFileName(ExtractArchiveName(Source)) + ' to disk.');
     {$ENDIF}

     // find some temporary path to save file to
     TempPath:= AnsiString(GetTempPath());

     // extract the item from archive to temporary path
     Result:= ArchiveManager.ExtractToDisk(Source, TempPath);
     if (Result) then
      begin
       // find the name of the extracted file
       TempFile:= AnsiString(MakeValidPath(TempPath) +
        MakeValidFileName(ExtractArchiveKey(Source)));

       {$IFDEF DebugMode}
       DebugLog(' ++ Loading texture from: ' + TempFile);
       {$ENDIF}

       // load the extracted file
       {$IFDEF AsphyreUseDx8}
       Result:= Succeeded(D3DXCreateTextureFromFileExA(TAsphyreDevice(Device).Dev8,
        PAnsiChar(TempFile),
        D3DX_DEFAULT {width}, D3DX_DEFAULT {height}, FMipLevels, Usage, FFormat,
        Pool, D3DX_DEFAULT {filter}, D3DX_DEFAULT {mip filter}, ColorKey, @Info,
        nil, FTex9));

       {$ELSE}
       Result:= Succeeded(D3DXCreateTextureFromFileExA(TAsphyreDevice(Device).Dev9,
        PAnsiChar(TempFile),
        D3DX_DEFAULT {width}, D3DX_DEFAULT {height}, FMipLevels, Usage, FFormat,
        Pool, D3DX_DEFAULT {filter}, D3DX_DEFAULT {mip filter}, ColorKey, @Info,
        nil, FTex9));
       {$ENDIF}
       // remove the extracted file to avoid trash
       DeleteFile(String(TempFile));
      end;
    end else
    begin // can load the bitmap directly from memory
     {$IFDEF DebugMode}
     DebugLog(' + Extracting texture ' + ExtractArchiveKey(Source) + ' from ' +
      ExtractFileName(ExtractArchiveName(Source)) + ' to memory.');
     {$ENDIF}

     // create a temporary memory stream
     MemStream:= TMemoryStream.Create();

     // extract archive directly to memory
     Result:= ArchiveManager.ExtractToStream(Source, MemStream);
     if (Result) then
      begin
       {$IFDEF DebugMode}
       DebugLog(' +++ Loading texture from memory.');
       {$ENDIF}

       {$IFDEF AsphyreUseDx8}
       Result:= Succeeded(D3DXCreateTextureFromFileInMemoryEx(TAsphyreDevice(Device).Dev8,
        MemStream.Memory, MemStream.Size, D3DX_DEFAULT {width},
        D3DX_DEFAULT {height}, FMipLevels, Usage, FFormat, Pool,
        D3DX_DEFAULT {filter}, D3DX_DEFAULT {mip filter}, ColorKey, @Info, nil,
        FTex9));
       {$ELSE}
       Result:= Succeeded(D3DXCreateTextureFromFileInMemoryEx(TAsphyreDevice(Device).Dev9,
        MemStream.Memory, MemStream.Size, D3DX_DEFAULT {width},
        D3DX_DEFAULT {height}, FMipLevels, Usage, FFormat, Pool,
        D3DX_DEFAULT {filter}, D3DX_DEFAULT {mip filter}, ColorKey, @Info, nil,
        FTex9));
       {$ENDIF}
      end;

     // release the memory stream
     MemStream.Free();
    end;
  end else
  begin // load image
   {$IFDEF DebugMode}
   DebugLog('Loading texture from disk: ' + {Source}ExtractArchiveName(Source));
   {$ENDIF}
   // 这个中间变量保证d2010下调用API正确
   tmpFile := AnsiString(ExtractArchiveName(Source));
   {$IFDEF AsphyreUseDx8}
   Result:= Succeeded(D3DXCreateTextureFromFileExA(TAsphyreDevice(Device).Dev8,
    PAnsiChar(tmpFile), D3DX_DEFAULT {width}, D3DX_DEFAULT {height},
    FMipLevels, Usage, FFormat, Pool, D3DX_DEFAULT {filter},
    D3DX_DEFAULT {mip filter}, ColorKey, @Info, nil, FTex9));
   {$ELSE}
   Result:= Succeeded(D3DXCreateTextureFromFileExA(TAsphyreDevice(Device).Dev9,
    PAnsiChar(tmpFile), D3DX_DEFAULT {width}, D3DX_DEFAULT {height},
    FMipLevels, Usage, FFormat, Pool, D3DX_DEFAULT {filter},
    D3DX_DEFAULT {mip filter}, ColorKey, @Info, nil, FTex9));
   {$ENDIF}
  end;

 if (not Result)or(not RefreshInfo()) then
  begin
   FTex9 := nil;
   Result:= False;
  end else
  begin
   FOrigSize.X:= Info.Width;
   FOrigSize.Y:= Info.Height;
   FInitialized:= True;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyrePlainTexture.Finalize();
begin
 if (FTex9 <> nil) then FTex9:= nil;
 FInitialized:= False;
end;

//---------------------------------------------------------------------------
function TAsphyrePlainTexture.LogicalToCoord(const Coord: TPoint2): TPoint2px;
begin
 Result.X:= Round(Coord.x * FOrigSize.X);
 Result.Y:= Round(Coord.y * FOrigSize.Y);
end;

//---------------------------------------------------------------------------
function TAsphyrePlainTexture.CoordToLogical(const Coord: TPoint2px): TPoint2;
begin
 if (FOrigSize.X > 0) then Result.x:= Coord.X / FOrigSize.X
  else Result.x:= 0.0;
 if (FOrigSize.Y > 0) then Result.y:= Coord.Y / FOrigSize.Y
  else Result.y:= 0.0;
end;

//---------------------------------------------------------------------------
constructor TAsphyreRenderTarget.Create(ADevice: TObject);
begin
 inherited;

 FTextureType:= attRenderTarget;
 Format      := D3DFMT_A8R8G8B8;
 MipLevels   := 1;

 FUseDepthStencil:= False;

 DepthStencil := nil;
 SavedSurface := nil;
 SavedDepthBuf:= nil;
end;

//---------------------------------------------------------------------------
function TAsphyreRenderTarget.RefreshInfo(): Boolean;
var
 Desc: TD3DSurfaceDesc;
begin
 Result:= (FTex9 <> nil);
 if (not Result) then Exit;

 Result:= Succeeded(FTex9.GetLevelDesc(0, Desc));
 if (Result) then
  begin
   FSize.X:= Desc.Width;
   FSize.Y:= Desc.Height;
   FFormat:= Desc.Format;
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreRenderTarget.Initialize(): Boolean;
var
 Usage: Cardinal;
 Pool : TD3DPool;
begin
 Assert(not FInitialized, msgAlreadyInitialized);
 FindUsagePool(Usage, Pool);
 {$IFDEF AsphyreUseDx8}
 Result:= Succeeded(D3DXCreateTexture(TAsphyreDevice(Device).Dev8,
  FSize.X, FSize.Y, FMipLevels, Usage, FFormat, Pool, FTex9));
//  {$IFDEF UseOutputDebugString}
//    if not Result then
//    begin// 创建失败时输出相关信息
//      OutputDebugString(PAnsiChar('TAsphyreRenderTarget.Initialize Error [' +
//        SysErrorMessage(GetLastError) + '] x=' + IntToStr(FSize.X) +
//        ' y=' + IntToStr(FSize.Y) + ' FMipLevels=' + IntToStr(FMipLevels) +
//        ' Usage=' + IntToStr(Usage) + ' FFormat=' + IntToStr(Ord(FFormat)) +
//        ' Pool=' + IntToStr(Ord(Pool))));
//     Result:= Succeeded(TAsphyreDevice(Device).Dev8.CreateTexture(
//       FSize.X, FSize.Y, FMipLevels, Usage, FFormat, Pool, FTex9));
//      OutputDebugString(PAnsiChar('TAsphyreRenderTarget.Initialize ReTry Result=' + BoolToStr(Result) ));
//    end
//    else
//    begin
//      OutputDebugString(PAnsiChar('TAsphyreRenderTarget.Initialize OK [' +
//        SysErrorMessage(GetLastError) + '] x=' + IntToStr(FSize.X) +
//        ' y=' + IntToStr(FSize.Y) + ' FMipLevels=' + IntToStr(FMipLevels) +
//        ' Usage=' + IntToStr(Usage) + ' FFormat=' + IntToStr(Ord(FFormat)) +
//        ' Pool=' + IntToStr(Ord(Pool))));
//    end;// if
//  {$ENDIF}
 {$ELSE}
 Result:= Succeeded(D3DXCreateTexture(TAsphyreDevice(Device).Dev9,
  FSize.X, FSize.Y, FMipLevels, Usage, FFormat, Pool, FTex9));
 {$ENDIF}
 if (not Result)or(not RefreshInfo()) then
  begin
   FTex9 := nil;
   Result:= False;
  end;

 if (Result)and(FUseDepthStencil) then
  with TAsphyreDevice(Device) do
   begin
    {$IFDEF AsphyreUseDx8}
    Result:= Succeeded(Dev8.CreateDepthStencilSurface(FSize.X, FSize.Y,
     Params.AutoDepthStencilFormat, D3DMULTISAMPLE_NONE, DepthStencil));
    {$ELSE}
    Result:= Succeeded(Dev9.CreateDepthStencilSurface(FSize.X, FSize.Y,
     Params.AutoDepthStencilFormat, D3DMULTISAMPLE_NONE, 0, True, DepthStencil,
     nil));
    {$ENDIF}

    if (not Result) then FTex9:= nil;
   end;

 if (not Result)or(not RefreshInfo()) then
  begin
   FTex9 := nil;
   Result:= False;
  end;

 FInitialized:= Result;
end;

//---------------------------------------------------------------------------
procedure TAsphyreRenderTarget.Finalize();
begin
 if (SavedDepthBuf <> nil) then SavedDepthBuf:= nil;
 if (SavedSurface <> nil) then SavedSurface:= nil;
 if (DepthStencil <> nil) then DepthStencil:= nil;
 if (FTex9 <> nil) then FTex9:= nil;

 FInitialized:= False;
end;

//---------------------------------------------------------------------------
{$IFDEF AsphyreUseDx8}
function TAsphyreRenderTarget.BeginDraw(): Boolean;
var
 MySurface: IDirect3DSurface8;
begin
 Assert(FInitialized, msgNotInitialized);

 // (1) Retreive my own surface for setting it as a render target.
 Result:= Succeeded(FTex9.GetSurfaceLevel(0, MySurface));
 if (not Result) then
  begin
   {$IFDEF DebugMode}
   DebugLog('!! Failed retreiving my render target surface.');
   {$ENDIF}
   Exit;
  end;

 with TAsphyreDevice(Device).Dev8 do
  begin
   // (2) Retreive the render surface that was previously active.
   Result:= Succeeded(GetRenderTarget(SavedSurface));
   if (not Result) then
    begin
     {$IFDEF DebugMode}
     DebugLog('!! Failed retreiving currently active rendering surface.');
     {$ENDIF}
     Exit;
    end;

   // (3) Retreive the depth/stencil that was previously active.
   if (FUseDepthStencil) then
    begin
     Result:= Succeeded(GetDepthStencilSurface(SavedDepthBuf));
     if (not Result) then
      begin
       {$IFDEF DebugMode}
       DebugLog('!! Failed retreiving currently active depth/stencil buffer.');
       {$ENDIF}
       Exit;
      end;
    end;

    if (MySurface <> nil) and (DepthStencil <> nil) then
    begin
      Result:= Succeeded(SetRenderTarget(MySurface, DepthStencil));
    end
    else
    begin
   // (4) Set my surface to be the new render target.
   Result:= Succeeded(SetRenderTarget(MySurface, nil));
   if (not Result) then
    begin
     {$IFDEF DebugMode}
     DebugLog('!! Failed setting my surface as a new rendering target.');
     {$ENDIF}
     Exit;
    end;

       // (5) Set my own buffer as a new depth/stencil buffer.
       if (FUseDepthStencil) then
        begin{ 在dx8中这部分无法处理因为没有SetDepthStencilSurface }
         Result:= Succeeded(SetRenderTarget(nil, DepthStencil));
         if (not Result) then
          begin
           {$IFDEF DebugMode}
           DebugLog('!! Failed setting my buffer as a new depth/stencil buffer.');
           {$ENDIF}
           Exit;
          end;
    //     Result:= Succeeded(SetDepthStencilSurface(DepthStencil));
    //     if (not Result) then
    //      begin
    //       {$IFDEF DebugMode}
    //       DebugLog('!! Failed setting my buffer as a new depth/stencil buffer.');
    //       {$ENDIF}
    //       Exit;
    //      end;
        end;
    end;// if
   // (6) Release the surface instance previously retreived.
   MySurface:= nil;
  end;
end;
{$ELSE}
function TAsphyreRenderTarget.BeginDraw(): Boolean;
var
 MySurface: IDirect3DSurface9;
begin
 Assert(FInitialized, msgNotInitialized);

 // (1) Retreive my own surface for setting it as a render target.
 Result:= Succeeded(FTex9.GetSurfaceLevel(0, MySurface));
 if (not Result) then
  begin
   {$IFDEF DebugMode}
   DebugLog('!! Failed retreiving my render target surface.');
   {$ENDIF}
   Exit;
  end;

 with TAsphyreDevice(Device).Dev9 do
  begin
   // (2) Retreive the render surface that was previously active.
   Result:= Succeeded(GetRenderTarget(0, SavedSurface));
   if (not Result) then
    begin
     {$IFDEF DebugMode}
     DebugLog('!! Failed retreiving currently active rendering surface.');
     {$ENDIF}
     Exit;
    end;

   // (3) Retreive the depth/stencil that was previously active.
   if (FUseDepthStencil) then
    begin
     Result:= Succeeded(GetDepthStencilSurface(SavedDepthBuf));
     if (not Result) then
      begin
       {$IFDEF DebugMode}
       DebugLog('!! Failed retreiving currently active depth/stencil buffer.');
       {$ENDIF}
       Exit;
      end;
    end;

   // (4) Set my surface to be the new render target.
   Result:= Succeeded(SetRenderTarget(0, MySurface));
   if (not Result) then
    begin
     {$IFDEF DebugMode}
     DebugLog('!! Failed setting my surface as a new rendering target.');
     {$ENDIF}
     Exit;
    end;

   // (5) Set my own buffer as a new depth/stencil buffer.
   if (FUseDepthStencil) then
    begin
     Result:= Succeeded(SetDepthStencilSurface(DepthStencil));
     if (not Result) then
      begin
       {$IFDEF DebugMode}
       DebugLog('!! Failed setting my buffer as a new depth/stencil buffer.');
       {$ENDIF}
       Exit;
      end;
    end;

   // (6) Release the surface instance previously retreived.
   MySurface:= nil;
  end;
end;
{$ENDIF}

//---------------------------------------------------------------------------
{$IFDEF AsphyreUseDx8}
procedure TAsphyreRenderTarget.EndDraw();
begin
 with TAsphyreDevice(Device).Dev8 do
  begin
   if (SavedDepthBuf <> nil) and (SavedSurface <> nil) then
   begin
     SetRenderTarget(SavedSurface, SavedDepthBuf);
     SavedDepthBuf:= nil;
     SavedSurface:= nil;
   end
   else
   begin
   // Restore previously used depth/stencil buffer.
   if (SavedDepthBuf <> nil) then
    begin{ 在dx8中这部分无法处理因为没有SetDepthStencilSurface }
     SetRenderTarget(nil, SavedDepthBuf); // 先这样试试
     //SetDepthStencilSurface(SavedDepthBuf);
     SavedDepthBuf:= nil;
    end;

     // Restore previously used surface as a render target.
     if (SavedSurface <> nil) then
      begin
       SetRenderTarget(SavedSurface, nil);
       SavedSurface:= nil;
      end;
    end;// if
  end;
end;
{$ELSE}
procedure TAsphyreRenderTarget.EndDraw();
begin
 with TAsphyreDevice(Device).Dev9 do
  begin
   // Restore previously used depth/stencil buffer.
   if (SavedDepthBuf <> nil) then
    begin
     SetDepthStencilSurface(SavedDepthBuf);
     SavedDepthBuf:= nil;
    end;

   // Restore previously used surface as a render target.
   if (SavedSurface <> nil) then
    begin
     SetRenderTarget(0, SavedSurface);
     SavedSurface:= nil;
    end;
  end;
end;
{$ENDIF}
//---------------------------------------------------------------------------
constructor TAsphyreDynamicTexture.Create(ADevice: TObject);
begin
 inherited;

 FTextureType:= attDynamic;
 Format      := D3DFMT_A8R8G8B8;
 MipLevels   := 1;
end;

//---------------------------------------------------------------------------
function TAsphyreDynamicTexture.RefreshInfo(): Boolean;
var
 Desc: TD3DSurfaceDesc;
begin
 Result:= (FTex9 <> nil);
 if (not Result) then Exit;

 Result:= Succeeded(FTex9.GetLevelDesc(0, Desc));
 if (Result) then
  begin
   FSize.X:= Desc.Width;
   FSize.Y:= Desc.Height;
   FFormat:= Desc.Format;
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreDynamicTexture.Initialize(): Boolean;
var
 Usage: Cardinal;
 Pool : TD3DPool;
begin
 Assert(not FInitialized, msgAlreadyInitialized);
 FindUsagePool(Usage, Pool);
 {$IFDEF AsphyreUseDx8}
 Result:= Succeeded(D3DXCreateTexture(TAsphyreDevice(Device).Dev8,
  FSize.X, FSize.Y, FMipLevels, Usage, FFormat, Pool, FTex9));

//  {$IFDEF UseOutputDebugString}
//    if not Result then
//    begin// 创建失败时输出相关信息
//      OutputDebugString(PAnsiChar('TAsphyreDynamicTexture.Initialize Error [' +
//        SysErrorMessage(GetLastError) + '] x=' + IntToStr(FSize.X) +
//        ' y=' + IntToStr(FSize.Y) + ' FMipLevels=' + IntToStr(FMipLevels) +
//        ' Usage=' + IntToStr(Usage) + ' FFormat=' + IntToStr(Ord(FFormat)) +
//        ' Pool=' + IntToStr(Ord(Pool))));
//     Result:= Succeeded(TAsphyreDevice(Device).Dev8.CreateTexture(
//       FSize.X, FSize.Y, FMipLevels, Usage, FFormat, Pool, FTex9));
//      OutputDebugString(PAnsiChar('TAsphyreDynamicTexture.Initialize ReTry Result=' + BoolToStr(Result) ));
//    end
//    else
//    begin
//      OutputDebugString(PAnsiChar('TAsphyreDynamicTexture.Initialize OK [' +
//        SysErrorMessage(GetLastError) + '] x=' + IntToStr(FSize.X) +
//        ' y=' + IntToStr(FSize.Y) + ' FMipLevels=' + IntToStr(FMipLevels) +
//        ' Usage=' + IntToStr(Usage) + ' FFormat=' + IntToStr(Ord(FFormat)) +
//        ' Pool=' + IntToStr(Ord(Pool))));
//    end;// if
//  {$ENDIF}
 {$ELSE}
 Result:= Succeeded(D3DXCreateTexture(TAsphyreDevice(Device).Dev9,
  FSize.X, FSize.Y, FMipLevels, Usage, FFormat, Pool, FTex9));
 {$ENDIF}
 if (not Result)or(not RefreshInfo()) then
  begin
   FTex9 := nil;
   Result:= False;
  end;

 FInitialized:= Result;
end;

//---------------------------------------------------------------------------
function TAsphyreDynamicTexture.InitializeEx(const Source: string;
 ColorKey: Cardinal): Boolean;
var
 Usage: Cardinal;
 Pool : TD3DPool;
begin
 Assert(not FInitialized, msgAlreadyInitialized);
 FindUsagePool(Usage, Pool);
 {$IFDEF AsphyreUseDx8}
 Result:= Succeeded(D3DXCreateTexture(TAsphyreDevice(Device).Dev8,
  FSize.X, FSize.Y, FMipLevels, Usage, FFormat, Pool, FTex9));
 {$ELSE}
 Result:= Succeeded(D3DXCreateTexture(TAsphyreDevice(Device).Dev9,
  FSize.X, FSize.Y, FMipLevels, Usage, FFormat, Pool, FTex9));
 {$ENDIF}
 if (not Result)or(not RefreshInfo()) then
  begin
   FTex9 := nil;
   Result:= False;
  end;

 if (not Result)or(not RefreshInfo()) then
  begin
   FTex9 := nil;
   Result:= False;
  end;

 FInitialized:= Result;  
end;

//---------------------------------------------------------------------------
procedure TAsphyreDynamicTexture.Finalize();
begin
 if (FTex9 <> nil) then FTex9:= nil;
 FInitialized:= False;
end;

//---------------------------------------------------------------------------
function TAsphyreDynamicTexture.Lock(out Bits: Pointer;
 out Pitch: Integer; Flag: Cardinal = D3DLOCK_DISCARD): Boolean;
var
 LockedRect: TD3DLockedRect;
begin
 Assert(FTex9 <> nil);

 Result:= Succeeded(FTex9.LockRect(0, LockedRect, nil, Flag));

 Bits := LockedRect.pBits;
 Pitch:= LockedRect.Pitch;
end;

//---------------------------------------------------------------------------
procedure TAsphyreDynamicTexture.Unlock();
begin
 Assert(FTex9 <> nil);

 FTex9.UnlockRect(0);
end;

//---------------------------------------------------------------------------
end.
