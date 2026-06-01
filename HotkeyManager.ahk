; HotkeyManager.ahk
; 动态读取g_config全局变量中的热键配置并注册

class HotkeyManager {
	; 主注册函数
	static RegisterHotkeys() {
		; 注册基础热键
		this.RegisterHotkey("ShowTip", (*) => MenuGUI.Show())
		this.RegisterHotkey("SetWindowAlwaysOnTop", (*) => TopmostTools.SetWindowAlwaysOnTop())
		this.RegisterHotkey("TypeClipboardContentByChar", (*) => TypingTools.TypeClipboardContentByChar())
		this.RegisterHotkey("LoopSendTextInClipboard", (*) => TypingTools.LoopSendTextInClipboard())
		this.RegisterHotkey("HandleAutoTyping", (*) => TypingTools.HandleAutoTyping())
		
		; 注册透明度相关热键
		this.RegisterTransparencyHotkeys()
	}
	
	; 注册单个热键
	static RegisterHotkey(configKey, callback) {
		if !g_config.Hotkeys.HasOwnProp(configKey)
			return
		
		hotkeyStr := g_config.Hotkeys.%configKey%
		if (hotkeyStr != "" && callback) {
			try
				Hotkey(hotkeyStr, callback, "On")
			catch
				MsgBox("注册热键失败: " hotkeyStr)
		}
	}
	
	; 注册透明度相关热键
	static RegisterTransparencyHotkeys() {
		if !g_config.Hotkeys.HasOwnProp("SetTransparentModifierKey") || !g_config.Hotkeys.HasOwnProp("SetTransparentMode")
			return
		
		modifierKey := g_config.Hotkeys.SetTransparentModifierKey
		mode := g_config.Hotkeys.SetTransparentMode
		prefix := ConfigManager.ModsToHotkeyPrefix(modifierKey)
		
		; 注册数字键透明度设置 (0-9)
		if (mode & SetTransparentMode.num) {
			Loop 10 {
				num := A_Index - 1
				hotkeyStr := prefix . num
				callback := this.CreateTransparentCallback(num)
				try
					Hotkey(hotkeyStr, callback, "On")
				catch
					MsgBox("注册透明度数字键失败: " hotkeyStr)
			}
		}
		
		; 注册 +/- 键加减透明度
		if (mode & SetTransparentMode.plusMinus) {
			try {
				Hotkey(prefix . "=", (*)=>TransparencyTools.AddTransparentAtCursor(1), "On")
				Hotkey(prefix . "-", (*)=>TransparencyTools.AddTransparentAtCursor(-1), "On")
			} catch
				MsgBox("注册透明度+/-键失败")
		}
		
		; 注册滚轮加减透明度
		if (mode & SetTransparentMode.wheel) {
			try {
				Hotkey(prefix . "WheelUp", (*)=>TransparencyTools.AddTransparentAtCursor(1), "On")
				Hotkey(prefix . "WheelDown", (*)=>TransparencyTools.AddTransparentAtCursor(-1), "On")
			} catch
				MsgBox("注册透明度滚轮键失败")
		}
	}
	
	; 创建透明度回调函数
	static CreateTransparentCallback(num) {
		switch num {
            case 1: value := 25
			case 2: value := 51
			case 3: value := 76
			case 4: value := 102
			case 5: value := 127
			case 6: value := 153
			case 7: value := 178
			case 8: value := 204
			case 9: value := 229
			case 0: value := 255
			default: return (*) => {}
		}
		return (*) => TransparencyTools.SetTransparentAtCursor(value)
	}
}