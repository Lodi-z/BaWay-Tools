; TypingTools.ahk
; 刷字数、逐字输出等功能

class TypingTools {
	static TypeClipboardContentByChar() {
		clipboard_content := A_Clipboard
		lines := StrSplit(clipboard_content, "`r`n", "`n")
		for i, line in lines {
			if this.ShouldStop() {
				return
			}
			if (line != "") {
				trimmed_line := RegExReplace(line, "^\s+")
				for c in StrSplit(trimmed_line) {
					SendText(c)
					Sleep(20)
				}
			}
			; 只在非最后一行时发送Enter
			if (i < lines.Length) {
				Send("{Enter}")
			}
		}
		Send("{End}")
	}

	static LoopSendTextInClipboard() {
		TrayTip("按下Esc或鼠标左键停止", "开始刷字数")
		this.TypeTextByChar(A_Clipboard, 80)
	}

	static HandleAutoTyping() {
		inputDelay := InputBox("输入字符敲击间隔（单位：ms）", "输入字符敲击间隔", , "80")
		if (inputDelay.Result != "OK") {
			TrayTip("取消操作")
			return
		}
		if (!IsNumber(inputDelay.Value) || inputDelay.Value < 0) {
			TrayTip("输入数字有误，取消操作")
			return
		}
		inputText := InputBox("输入模拟敲击的字符串", "输入模拟敲击的字符串", , A_Clipboard)
		if (inputText.Result != "OK") {
			TrayTip("取消操作")
			return
		}
		TrayTip("按下Esc或鼠标左键停止", "开始刷字数")
		delay := inputDelay.Value
		str := inputText.Value
		this.TypeTextByChar(str, delay)
	}

	static ShouldStop() {
		return GetKeyState("Esc") || GetKeyState("LButton")
	}

	static TypeTextByChar(str, delay) {
		chars := StrSplit(str, "")
		loop {
			Sleep(delay)
			for c in chars {
				if this.ShouldStop() {
					return
				}
				SendText(c)
				Sleep(delay)
			}
			Send("{Escape}")
			Send("{Enter}")
		}
	}
}
