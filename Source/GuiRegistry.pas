unit GuiRegistry;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 SysUtils, GuiObjects;

//---------------------------------------------------------------------------
function CreateGuiClass(ClassName: string; Owner: TGuiObject): TGuiObject;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 GuiForms, GuiEdit, GuiButton, GuiCnForms, GuiCnButton, GuiCnEdit, GuiCnWebForms;

//---------------------------------------------------------------------------
function CreateGuiClass(ClassName: string; Owner: TGuiObject): TGuiObject;
begin
 ClassName:= LowerCase(ClassName);

 Result:= nil;
 if (ClassName = 'tguiform') then Result:= TGuiForm.Create(Owner);
 if (ClassName = 'tguiedit') then Result:= TGuiEdit.Create(Owner);
 if (ClassName = 'tguibutton') then Result:= TGuiButton.Create(Owner);
 
 if (ClassName = 'tguicnform') then Result:= TGuiCnForm.Create(Owner);
 if (ClassName = 'tguicnbutton') then Result:= TGuiCnButton.Create(Owner);
 if (ClassName = 'tguicnedit') then Result:= TGuiCnEdit.Create(Owner);
 if (ClassName = 'tguicnwebform') then Result:= TGuiCnWebForm.Create(Owner);

end;

//---------------------------------------------------------------------------
end.
