{******************************************************************************}
{单元名称：GuiCnButton.pas                                                     }
{功能描述：Modify by GuiButton.pas                                             }
{开发人员：Piao40993470 (xbpiao@msn.com)                                       }
{创建时间：2007-07-08 22:09                                                    }
{使用说明：                                                                    }
{修改历史：                                                                    }
{                                                                              }
{******************************************************************************}

unit GuiCnButton;

interface

uses
 Types, Vectors2px, AsphyreTypes, GuiSkins, GuiTypes, GuiUtils,
 GuiObjects, GuiControls;

type
  TGuiCnButton = class(TGuiControl)
  private
    FCaptCol   : TGuiFontCol;
    FCaptRect  : TRect;
    FCaptFont  : string;
    FCaptHAlign: THorizontalAlign;
    FCaptVAlign: TVerticalAlign;
    FCaption   : WideString;
    FCaptionFontColor: Cardinal;
    FFontCacheID: Cardinal;

    procedure DrawText(const DrawPos: TPoint2px);
    procedure SetCaption(const Value: WideString);

  protected
    procedure DoDestroy(); override;
    procedure DoDraw(const DrawPos: TPoint2px); override;

    procedure DoDescribe(); override;
    procedure WriteProperty(Code: Cardinal; Source: Pointer); override;
  public
    property CaptCol: TGuiFontCol read FCaptCol;

    property CaptHAlign: THorizontalAlign read FCaptHAlign write FCaptHAlign;
    property CaptVAlign: TVerticalAlign read FCaptVAlign write FCaptVAlign;
    property CaptRect  : TRect read FCaptRect write FCaptRect;
    property CaptFont  : string read FCaptFont write FCaptFont;
    property Caption   : WideString read FCaption write SetCaption;

    constructor Create(AOwner: TGuiObject); override;
  end;


implementation

uses AsphyreFontCache;

const
  cPropBase = $1000;

{ TGuiCnButton }

constructor TGuiCnButton.Create(AOwner: TGuiObject);
begin
  inherited;
  FCaptHAlign:= haCenter;
  FCaptVAlign:= vaCenter;

  FCaptCol:= TGuiFontCol.Create();
  FCaptionFontColor := $FF000000;

  FFontCacheID := 0;
end;

procedure TGuiCnButton.DoDescribe;
begin
  inherited;
  Describe(cPropBase + $0, 'Caption',    gdtWideString);
  Describe(cPropBase + $1, 'CaptionFontColor', gdtCardinal);
  Describe(cPropBase + $2, 'CaptFont',   gdtString);
  Describe(cPropBase + $3, 'CaptRect',   gdtRect);
  Describe(cPropBase + $4, 'CaptHAlign', gdtHAlign);
  Describe(cPropBase + $5, 'CaptVAlign', gdtVAlign);
  Describe(cPropBase + $6, 'CaptCol',    gdtFontColor);

end;

procedure TGuiCnButton.DoDestroy;
begin
  FCaptCol.Free();
  if (FFontCacheID > 0) and Assigned(GuiFontCache) then
    GuiFontCache.Dirty(FFontCacheID);
  inherited;
end;

procedure TGuiCnButton.DoDraw(const DrawPos: TPoint2px);
begin
  inherited;
  if (FCaptFont <> '')and(FCaption <> '') then DrawText(DrawPos);
end;

procedure TGuiCnButton.DrawText(const DrawPos: TPoint2px);
var
  Shift: TPoint2px;
begin
  if (GuiFontCache = nil) or (Length(FCaption) = 0) then Exit;

  if (FFontCacheID = 0) or (GuiFontCache.Exist(FFontCacheID) < 0) then
  begin
    FFontCacheID := GuiFontCache.GetFontCacheID(FCaptFont, FCaption, FCaptionFontColor);
  end;// if

  if FFontCacheID > 0 then
  begin
    Shift:= ZeroPoint2px;
    if (MouseDown) then
      Shift:= Point2px(1, 1);

    GuiFontCache.TextRect(FFontCacheID, MoveRect(FCaptRect, DrawPos + Shift),
      FCaptHAlign, FCaptVAlign, FCaptCol.UseColor(GetSkinDrawType()));
  end;// if
end;

procedure TGuiCnButton.SetCaption(const Value: WideString);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    // 过期的会被自动回收
    if (FFontCacheID > 0) then
      GuiFontCache.Dirty(FFontCacheID);
    FFontCacheID := 0;
  end;// if
end;

procedure TGuiCnButton.WriteProperty(Code: Cardinal; Source: Pointer);
begin
  case Code of
    cPropBase + $0:
     FCaption:= PWideChar(Source);

    cPropBase + $1:
     FCaptionFontColor:= PCardinal(Source)^;

    cPropBase + $2:
     FCaptFont:= PChar(Source);

    cPropBase + $3:
     FCaptRect:= PRect(Source)^;

    cPropBase + $4:
     FCaptHAlign:= THorizontalAlign(Source^);

    cPropBase + $5:
     FCaptVAlign:= TVerticalAlign(Source^);

    cPropBase + $6:
     FCaptCol.Assign(TGuiFontCol(Source));

    else
      inherited WriteProperty(Code, Source);
  end;// case

end;

end.
