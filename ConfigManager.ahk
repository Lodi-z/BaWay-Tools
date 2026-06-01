; 修饰键常量
ModifierKey := {
	Shift : 0x0001,
	Ctrl  : 0x0002,
	Alt   : 0x0004,
	Win   : 0x0008
}

; 透明度设置模式常量
SetTransparentMode := {
	num       : 0x0001,
	plusMinus : 0x0002,
	wheel     : 0x0004
}

; 全局配置对象
g_config := {}

class ConfigManager {
	static fileName := "config.ini"

	; 配置数组：[Section, Key, DefaultValue]
	static configs := [
		{ section: "Settings", key: "OpenThisPageOnStart", default: true, value: (*) => MenuGUI.guiObj["OpenThisPageOnStart"].Value },
		{ section: "URLs", key: "ExamPlatForm", default: "http://172.16.10.111:5886/#/", value: (*) => MenuGUI.guiObj["ExamPlatForm"].Value },
		{ section: "URLs", key: "CPWebForm", default: "http://111.202.197.147:8888/cp/", value: (*) => MenuGUI.guiObj["CPWebForm"].Value },
		{ section: "URLs", key: "NAS_AddressForm", default: "10.160.60.60", value: (*) => MenuGUI.guiObj["NAS_AddressForm"].Value },
		{ section: "URLs", key: "HomeworkDisk", default: "http://10.161.23.69:8010/", value: (*) => MenuGUI.guiObj["HomeworkDisk"].Value },
		{ section: "Hotkeys", key: "ShowTip", default: "+F1", value: (*) => MenuGUI.guiObj["ShowTip"].Value },
		{ section: "Hotkeys", key: "SetTransparentModifierKey", default: ModifierKey.Alt, value: (*) {
			guiObj := MenuGUI.guiObj
			modKey := 0
			if guiObj["ModAlt"].Value
				modKey |= ModifierKey.Alt
			if guiObj["ModShift"].Value
				modKey |= ModifierKey.Shift
			if guiObj["ModCtrl"].Value
				modKey |= ModifierKey.Ctrl
			if guiObj["ModWin"].Value
				modKey |= ModifierKey.Win
			return modKey
			}},
		{ section: "Hotkeys", key: "SetTransparentMode", default: SetTransparentMode.num | SetTransparentMode.plusMinus | SetTransparentMode.wheel, value: (*) {
			guiObj := MenuGUI.guiObj
			mode := 0
			if guiObj["ModeNum"].Value
				mode |= SetTransparentMode.num
			if guiObj["ModePlusMinus"].Value
				mode |= SetTransparentMode.plusMinus
			if guiObj["ModeWheel"].Value
				mode |= SetTransparentMode.wheel
			return mode
		}},
		{ section: "Hotkeys", key: "SetWindowAlwaysOnTop", default: "!t", value: (*) => MenuGUI.guiObj["SetWindowAlwaysOnTop"].Value },
		{ section: "Hotkeys", key: "TypeClipboardContentByChar", default: "!v", value: (*) => MenuGUI.guiObj["TypeClipboardContentByChar"].Value },
		{ section: "Hotkeys", key: "LoopSendTextInClipboard", default: "F8", value: (*) => MenuGUI.guiObj["LoopSendTextInClipboard"].Value },
		{ section: "Hotkeys", key: "HandleAutoTyping", default: "+F8", value: (*) => MenuGUI.guiObj["HandleAutoTyping"].Value },
	]

	; 加载配置
	static Load() {
		for config in this.configs {
			; 确保section存在
			if !g_config.HasOwnProp(config.section)
				g_config.%config.section% := {}

			g_config.%config.section%.%config.key% := IniRead(this.fileName, config.section, config.key, config.default)
		}
	}

	; 保存配置
	static Save() {
		for config in this.configs {
			g_config.%config.section%.%config.key% := config.value()
			IniWrite(g_config.%config.section%.%config.key%, this.fileName, config.section, config.key)
		}
	}

	; 将修饰键数值转换为AHK热键前缀字符串
	static ModsToHotkeyPrefix(mods) {
		prefix := ""
		if (mods & ModifierKey.Win)
			prefix .= "#"
		if (mods & ModifierKey.Ctrl)
			prefix .= "^"
		if (mods & ModifierKey.Alt)
			prefix .= "!"
		if (mods & ModifierKey.Shift)
			prefix .= "+"
		return prefix
	}
	
	; 检查是否有修改
    static HasChanges() {
		for config in this.configs {
			if (g_config.%config.section%.%config.key% != config.value())
				return true
		}
		return false
    }
}