{******************************************************************************}
{单元名称：GuiCnForms.pas                                                      }
{功能描述：实现支持WideString的GuiForm (参考GuiForms.pas)                      }
{开发人员：Piao40993470 (xbpiao@msn.com)                                       }
{创建时间：2007-07-07 16:27                                                    }
{使用说明：                                                                    }
{修改历史：                                                                    }
{                                                                              }
{******************************************************************************}

unit GuiCnForms;

interface

uses
  Types, Vectors2px, AsphyreTypes, GuiShapeRep, GuiTypes, GuiUtils,
  GuiObjects, GuiControls, GuiSkins;

type
  TGuiCnForm = class(TGuiControl)
  private
    FDragShape : string;
    FDragClick  : TPoint2px;
    FDragInit   : TPoint2px;
    FDragging: boolean;

    FCaption: WideString;
    FCaptRect: TRect;
    FCaptColor: TColor2;
    FCaptFont: string;
    FCaptionFontColor: Cardinal;

    FAlphaValue: Byte;
    FCaptVAlign: TVerticalAlign;
    FCaptHAlign: THorizontalAlign;

    FFontCacheID: Cardinal;

    procedure DrawText(const DrawPos: TPoint2px);
    procedure SetCaption(const Value: WideString);
    function HasMouseOverChild(): boolean;
  protected
    function GetSkinDrawType(): TSkinDrawType; override;
    procedure DoMouseEvent(const Pos: TPoint2px; Event: TMouseEventType;
      Button: TMouseButtonType; SpecialKeys: TSpecialKeyState); override;
    procedure DoDraw(const DrawPos: TPoint2px); override;

    procedure DoDescribe(); override;
    procedure WriteProperty(Code: Cardinal; Source: Pointer); override;
  public
    constructor Create(AOwner: TGuiObject); override;
    destructor Destroy(); override;

    property DragShape : string read FDragShape write FDragShape;
    { Caption 相关 }
    property Caption   : WideString read FCaption write SetCaption;
    property CaptRect  : TRect read FCaptRect write FCaptRect;
    property CaptColor : TColor2 read FCaptColor write FCaptColor;
    property CaptFont  : string read FCaptFont write FCaptFont;
    property CaptHAlign: THorizontalAlign read FCaptHAlign write FCaptHAlign;
    property CaptVAlign: TVerticalAlign read FCaptVAlign write FCaptVAlign;
    
    property AlphaValue: Byte read FAlphaValue write FAlphaValue;
    procedure SetFocus(); override;
  end;


implementation

uses AsphyreFontCache;

const
  cPropBase = $1000;

{ TGuiCnForm }

constructor TGuiCnForm.Create(AOwner: TGuiObject);
begin
  inherited;
  FDragging := False;
  FCaptHAlign := haCenter;
  FCaptVAlign := vaCenter;
  FAlphaValue := 255;
  FCaptionFontColor := $FF000000;
end;

destructor TGuiCnForm.Destroy;
begin
  if (FFontCacheID > 0) and Assigned(GuiFontCache) then
    GuiFontCache.Dirty(FFontCacheID);
  inherited;
end;

procedure TGuiCnForm.DoDescribe;
begin
  inherited;
  Describe(cPropBase + $0, 'Caption',    gdtWideString);
  Describe(cPropBase + $1, 'CaptFont',   gdtString);
  Describe(cPropBase + $2, 'CaptColor',  gdtColor2);
  Describe(cPropBase + $3, 'CaptRect',   gdtRect);
  Describe(cPropBase + $4, 'CaptHAlign', gdtHAlign);
  Describe(cPropBase + $5, 'CaptVAlign', gdtVAlign);
  Describe(cPropBase + $6, 'DragShape',  gdtString);
  Describe(cPropBase + $7, 'AlphaValue',  gdtCardinal);
  Describe(cPropBase + $8, 'CaptionFontColor',  gdtCardinal);

end;

procedure TGuiCnForm.DoDraw(const DrawPos: TPoint2px);
begin
  if (FCaptFont <> '')and(FCaption <> '') then DrawText(DrawPos);
end;

procedure TGuiCnForm.DoMouseEvent(const Pos: TPoint2px; Event: TMouseEventType;
  Button: TMouseButtonType; SpecialKeys: TSpecialKeyState);
begin
  if (Event = metDown)and(Button = mbtLeft)and
    (PointInside(FDragShape, Pos))and(not FDragging) then
  begin
    FDragInit := Origin;
    FDragClick:= Pos;
    FDragging := True;
  end;

  if (FDragging) and (Button = mbtLeft) and (Event = metUp) then
    FDragging:= False;
    
  if (FDragging)and(Event = metMove) then
    Origin:= FDragInit + Pos - FDragClick;
end;

procedure TGuiCnForm.DrawText(const DrawPos: TPoint2px);
begin
  if GuiFontCache = nil then Exit;
  if not GuiFontCache.TextRect(FFontCacheID, MoveRect(FCaptRect, DrawPos),
      FCaptHAlign, FCaptVAlign, FCaptColor) then
  begin
    FFontCacheID := GuiFontCache.GetFontCacheID(FCaptFont, FCaption, FCaptionFontColor);
    GuiFontCache.TextRect(FFontCacheID, MoveRect(FCaptRect, DrawPos),
      FCaptHAlign, FCaptVAlign, FCaptColor);
  end;// if
end;

function TGuiCnForm.GetSkinDrawType: TSkinDrawType;
begin
 Result:= sdtNormal;

 if (not Enabled) then
   Result:= sdtDisabled
 else
 begin
 if (Focused) then
   Result:= sdtFocused
 else
   if HasMouseOverChild() then Result:= sdtOver;
 end;// if

// if (FMouseDown) then Result:= sdtDown;
end;

function TGuiCnForm.HasMouseOverChild: boolean;
var i: integer;
    Temp : TGuiControl;
begin{ 窗体的MouseOver处理 }
  Result := MouseOver;
  if Result then Exit;
  for i := 0 to ChildCount - 1 do
  begin
    Temp:= nil;

    if (Child[i] is TGuiControl) then
    begin
      Temp := TGuiControl(Child[i]);
      if Temp.MouseOver then
      begin
        Result := True;
        Break;
      end;// if
    end;// if
  end;// for i

end;

procedure TGuiCnForm.SetCaption(const Value: WideString);
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

procedure TGuiCnForm.SetFocus;
begin
  inherited;
  BringToFront();
end;

procedure TGuiCnForm.WriteProperty(Code: Cardinal; Source: Pointer);
begin
  case Code of
    cPropBase + $0:
      FCaption:= PWideChar(Source);

    cPropBase + $1:
      FCaptFont:= PChar(Source);

    cPropBase + $2:
      FCaptColor:= PColor2(Source)^;

    cPropBase + $3:
      FCaptRect:= PRect(Source)^;

    cPropBase + $4:
      FCaptHAlign:= THorizontalAlign(Source^);

    cPropBase + $5:
      FCaptVAlign:= TVerticalAlign(Source^);

    cPropBase + $6:
      FDragShape:= PChar(Source);

    cPropBase + $7:
      if PCardinal(Source)^ > 255 then
        FAlphaValue := 255
      else
        FAlphaValue := PCardinal(Source)^;
        
     cPropBase + $8:
       FCaptionFontColor := PCardinal(Source)^;

    else inherited WriteProperty(Code, Source);
  end;// case

end;

end.
