# Asphyre4
Asphyre 4.1.0, snapshot 30-Mar-2007

基于Asphyre 4.1.0, snapshot 30-Mar-2007的修改版本，很多年以前学习d3d9时写的。

* 增加了AspnyreCanvas对DirectX8的支持编译时需要增加编译参数AsphyreUseDx8
  可看例子：Asphyre4snapshot30mar2007\Examples\Landscape\Landscape.dpr

* 如果要在DLL中使用需要编译参数AsphyreInDll
    在Dll中使用时要使用TAsphyreDevice.InitializeInDll初始化默认的TAsphyreDevice
    
* 增加组件
GuiCnForms.pas										TGuiCnForm								支持Unicode Caption的窗体
GuiCnButton.pas										TGuiCnButton							支持Unicode Caption的窗体
GuiCnEdit.pas										TGuiCnEdit								支持中文，但不能选择编辑（需要TntClipBrd.pas以支持粘贴Unicode文本）
GuiCnWebForms.pas									TGuiCnWebForm							附加些属性以方便支持增加内嵌IE窗体、FlashRender、FireFox等

* 简单调整使可以在d2010正确编译