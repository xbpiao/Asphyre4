//-----------精灵的移动----------------------------------------------------------
//-------------------------------------------------------------------------------
//    huaosft(http://www.huosoft.com)               Modified:29-Mar-2007
//------------------------------------------------------------------------------
unit MainFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, AdPhysics,
  Dialogs, AsphyreDevices, AsphyreTimer, ExtCtrls, AsphyreTypes, AsphyreImages, MediaFonts,
  AsphyrePalettes, AsphyreEffects, StdCtrls, AsphyreSprite, MSprite, AsphyreSpriteEffects,
  AsphyreSpriteUtils, AsphyreSystemFonts, AsphyreEvents;

type
  TMainForm = class(TForm)
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  Private
    { Private declarations }
    procedure DevConfig(Sender: TAsphyreDevice; Tag: TObject; var Config: TScreenConfig);
    procedure TimerEvent(Sender: TObject);
    procedure DevRender(Sender: TAsphyreDevice; Tag: TObject);
    procedure InitDevice(Sender: TObject; EventParam: Pointer; var Success: Boolean);
  Public
    SpriteEngine: TSpriteEngine;
    GameSprite: TGameSprite;
    Mouse_X, Mouse_Y: Integer;
    DestMsg: string;
  end;

var
  MainForm: TMainForm;

implementation
uses
  AsphyreArchives, AsphyreArcASDb, AsphyreArc7z, MediaImages, CommonUtils;
{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := 'Newton Demo for Asphyre4(火人工作室提供)';
  ImageGroups.ParseLink('/media.xml');
  FontGroups.ParseLink('/media.xml');

//  Devices.InitEvent := InitDevice;

  Devices.Count := 1; //Devices.DisplayCount;
  if (not Devices.Initialize(DevConfig, Self)) then
  begin
    ShowMessage('Initialization failed.');
    Close();
    Exit;
  end;
  Timer.Enabled := True;
  Timer.OnTimer := TimerEvent;
  Timer.MaxFPS := 4000;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Devices.Finalize();
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then Close();
end;

procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
////  GameSprite.SetSpriteDestPos(cSpritePos(X,Y,-1,2*PI));
//  GameSprite.SetSpriteDestPos(cSpritePos(X, Y));
//  DestMsg:='Move Dest:  X='+Inttostr(X)+',Y='+Inttostr(Y);
end;

procedure TMainForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Sprite: TSprite;
begin
//  Mouse_X := X;
//  Mouse_Y := Y;
//  Sprite := TSpriteEx(SpriteEngine).GetSpriteAt(X + 35, Y + 43);
//
//  SpriteEngine[0].DrawFx := fxuBlend;
//  if Sprite <> nil then Sprite.DrawFx := fxuBright;

end;

procedure TMainForm.DevConfig(Sender: TAsphyreDevice; Tag: TObject;
  var config: TScreenConfig);
begin
  Config.Width := ClientWidth;
  Config.Height := ClientHeight;
  Config.Windowed := true;
  Config.VSync := True;
  Config.BitDepth := bd24bit;
  Config.WindowHandle := Self.Handle;
  Config.HardwareTL := False;
  Config.DepthStencil := dsNone;

  EventDeviceCreate.Subscribe(InitDevice, Sender);

end;

procedure TMainForm.InitDevice(Sender: TObject; EventParam: Pointer; var Success: Boolean);
var
  i: integer;
begin
  if (Sender is TAsphyreDevice) then
    with Sender as TAsphyreDevice do
    begin
      SpriteEngine := TSpriteEngine.Create(nil);
      SpriteEngine.Image := Images;
      SpriteEngine.Canvas := Canvas;
      SpriteEngine.Device := Sender as TAsphyreDevice;
      SpriteEngine.VisibleWidth := Params.BackBufferWidth;
      SpriteEngine.VisibleHeight := Params.BackBufferHeight;
      SpriteEngine.Width := Params.BackBufferWidth;
      SpriteEngine.Height := Params.BackBufferHeight;
      SpriteEngine.X := 0;
      SpriteEngine.y := 0;

      with TPhysicalApplication.Create(SpriteEngine) do
      begin
        SolverModel := smLinear;
//        ImageName := '/images/bu';
        Active := true;
        Visible := false;
      end;

      for i := 0 to 35 do
      begin
        case random(2) of
          0: with TPhysicalCylinderSprite.Create(SpriteEngine) do
            begin
              X := random(40) + (i mod 5 + 1) * 100;
              Y := i div 4 * 40;
              ImageName := '/images/cylinder';
              Mass := 1;
              Width := 32;
              Height := 32;
//              DrawMode := 1;
              Typ := ptDynamic;
              InitializeShape;
              Active := true;
            end;
          1: with TPhysicalBoxSprite.Create(SpriteEngine) do
            begin
              X := random(40) + (i mod 5 + 1) * 100;
              Y := i div 4 * 40;
              ImageName := '/images/box';
              Width := 32;
              Height := 32;
              Mass := 10;
//              DrawMode := 1;
              Typ := ptDynamic;
              InitializeShape;
              Active := true;
            end;
        end;
      end;

      for i := 0 to 10 do
      begin
        with TPhysicalCylinderSprite.Create(SpriteEngine) do
        begin
          X := i * 60 + 32;
          Y := 400 - (i mod 3) * 100;
          ImageName := '/images/point';
          Width := 32;
          Height := 32;
          Typ := ptStatic;
//          DrawMode := 1;
          Typ := ptDynamic;
          InitializeShape;
          Active := true;
        end;
      end;

      with TPhysicalBoxSprite.Create(SpriteEngine) do
      begin
        X := 0;
        Y := 600;
        ImageName := '/images/plate';
        ScaleX := ClientWidth / 16;
        width := 640;
//        DrawMode := 1;
        Typ := ptStatic;
        InitializeShape;
        Active := true;
      end;

//      GameSprite := TGameSprite.Create(SpriteEngine);
//      with GameSprite do
//      begin
//        ImageName := '/images/bu';
//        X := 450;
//        Y := 110;
//        Z := -2;
//        Width := 70;
//        Height := 86;
//        DoAnimate := true;
//        DoCenter := true;
//        AnimSpeed := 0.31;
//        AnimCount := 12;
//        DrawMode := 1;
//        ChangeSpeed := 0.5;
//      end;

      Images.ResolveImage('/images/bu');
      Images.ResolveImage('/images/box');
      Images.ResolveImage('/images/cylinder');
      SysFonts.CreateFont('s/tahoma', 'tahoma', 10, False, fwtNormal);

    end;
end;

procedure TMainForm.TimerEvent(Sender: TObject);
begin
  Devices[0].Render(DevRender, Self, $FF88BB88);
//  Caption := 'FPS: ' + IntToStr(Timer.FrameRate);
  Timer.Process();
end;

procedure TMainForm.DevRender(Sender: TAsphyreDevice; Tag: TObject);
begin

  SpriteEngine.Move(0.01);
  SpriteEngine.Draw;

//  Sender.SysFonts.Font['s/tahoma'].TextOut('Mouse Pos:  Mouse_X=' +
//    Inttostr(Round(Mouse_X)) + ',Mouse_Y=' + Inttostr(Round(Mouse_Y)), 310, 10, $FF0000FF);

end;

end.

