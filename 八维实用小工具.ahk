#Include ConfigManager.ahk
#Include HotkeyManager.ahk
#Include TransparencyTools.ahk
#Include TopmostTools.ahk
#Include TypingTools.ahk
#Include AccountTools.ahk
#Include MenuGUI.ahk
; ========================全局变量==========================
A_HotkeyInterval := 2
ConfigManager.Load

; ========================热键==========================
; 动态注册热键
HotkeyManager.RegisterHotkeys

; ========================菜单项==========================
; 删除Pause Script菜单项
try A_TrayMenu.Delete("&Pause Script")
; 可打开自定义的设置菜单
A_TrayMenu.Insert("1&", "设置(&S)", (*) => MenuGUI.Show())
; 重命名其他菜单项
try A_TrayMenu.Rename("&Suspend Hotkeys", "暂停(&P)")
try A_TrayMenu.Rename("E&xit", "退出(&X)")

; ========================启动时运行==========================
if g_config.Settings.OpenThisPageOnStart
	MenuGUI.Show
