unit AsphyreBmpLoad;
//---------------------------------------------------------------------------
// AsphyreBmpLoad.pas                                   Modified: 04-Jan-2005
// Generic Bitmap loading for Asphyre                            Version 1.02
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
 Classes, SysUtils, Graphics, AsphyreTGA, AsphyreJPG, AsphyrePNG;

//---------------------------------------------------------------------------
type
 TImageFormat = (ifBMP, ifTGA, ifJPEG, ifPNG, ifAuto);

//---------------------------------------------------------------------------
// LoadBitmap()
//
// Loads generalized image format from stream or file.
//---------------------------------------------------------------------------
function LoadBitmap(Stream: TStream; Dest: TBitmap;
 Format: TImageFormat): Boolean; overload;
function LoadBitmap(const FileName: string; Dest: TBitmap;
 Format: TImageFormat = ifAuto): Boolean; overload;

//---------------------------------------------------------------------------
// SaveBitmap()
//
// Saves bitmap to generalized image format with default/recommended options.
//---------------------------------------------------------------------------
function SaveBitmap(Stream: TStream; Source: TBitmap;
 Format: TImageFormat): Boolean; overload;
function SaveBitmap(const FileName: string; Source: TBitmap;
 Format: TImageFormat = ifAuto): Boolean; overload;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
function FormatFromName(const FileName: string): TImageFormat;
var
 ext: string;
begin
 Result:= ifBmp;
 ext:= ExtractFileExt(FileName);

 if (SameText(ext, '.tga')) then Result:= ifTGA;
 if (SameText(ext, '.jpg'))or(SameText(ext, '.jpeg')) then Result:= ifJPEG;
 if (SameText(ext, '.png')) then Result:= ifPNG;
end;

//---------------------------------------------------------------------------
function LoadBitmap(Stream: TStream; Dest: TBitmap;
 Format: TImageFormat): Boolean; overload;
begin
 case Format of
  // Windows Bitmap
  ifBMP:
   begin
    Result:= True;
    try
     Dest.LoadFromStream(Stream);
    except
     Result:= False;
    end;
   end;
  // Truevision TARGA
  ifTGA:
    try
      Result:= LoadTGAtoBMP(Stream, Dest);
    except
      Result:= False;
    end;
  // JPEG
  ifJPEG:
    try
      Result:= LoadJPGtoBMP(Stream, Dest);
    except
      Result:= False;
    end;
  // Portable Network Graphics
  ifPNG:
    try
      Result:= LoadPNGtoBMP(Stream, Dest);
    except
      Result:= False;
    end;
  else
   Result:= False;
 end;
end;

//---------------------------------------------------------------------------
function LoadBitmap(const FileName: string; Dest: TBitmap;
 Format: TImageFormat): Boolean; overload;
begin
 if (Format = ifAuto) then
  Format:= FormatFromName(FileName);

 case Format of
  // Windows Bitmap
  ifBMP:
   begin
    Result:= True;
    try
     Dest.LoadFromFile(FileName);
    except
     Result:= False;
    end;
   end;
  // Truevision TARGA
  ifTGA:
    try
      Result:= LoadTGAtoBMP(FileName, Dest);
    except
      Result:= False;
    end;
  // JPEG
  ifJPEG:
    try
      Result:= LoadJPGtoBMP(FileName, Dest);
    except
      Result:= False;
    end;
  // Portable Network Graphics
  ifPNG:
    try
      Result:= LoadPNGtoBMP(FileName, Dest);
    except
      Result:= False;
    end;
  else
   Result:= False;
 end;
end;

//---------------------------------------------------------------------------
function SaveBitmap(Stream: TStream; Source: TBitmap;
 Format: TImageFormat): Boolean; overload;
begin
 case Format of
  // Windows Bitmap
  ifBMP:
   begin
    Result:= True;
    try
     Source.SaveToStream(Stream);
    except
     Result:= False;
    end;
   end;
  // Truevision TARGA
  ifTGA:
    try
      Result:= SaveBMPtoTGA(Stream, Source, [tfCompressed]);
    except
      Result:= False;
    end;
  // JPEG
  ifJPEG:
    try
      Result:= SaveBMPtoJPG(Stream, Source, [jfProgressive], 90);
    except
      Result:= False;
    end;
  // Portable Network Graphics
  ifPNG:
    try
      Result:= SaveBMPtoPNG(Stream, Source, 9);
    except
      Result:= False;
    end;
  else
   Result:= False;
 end;
end;

//---------------------------------------------------------------------------
function SaveBitmap(const FileName: string; Source: TBitmap;
 Format: TImageFormat): Boolean; overload;
begin
 if (Format = ifAuto) then
  Format:= FormatFromName(FileName);

 case Format of
  // Windows Bitmap
  ifBMP:
   begin
    Result:= True;
    try
     Source.SaveToFile(FileName);
    except
     Result:= False;
    end;
   end;
  // Truevision TARGA
  ifTGA:
    try
      Result:= SaveBMPtoTGA(FileName, Source, [tfCompressed]);
    except
      Result:= False;
    end;
  // JPEG
  ifJPEG:
    try
      Result:= SaveBMPtoJPG(FileName, Source, [jfProgressive], 87);
    except
      Result:= False;
    end;
  // Portable Network Graphics
  ifPNG:
    try
      Result:= SaveBMPtoPNG(FileName, Source, 9);
    except
      Result:= False;
    end;
  else
   Result:= False;
 end;
end;

//---------------------------------------------------------------------------
end.
