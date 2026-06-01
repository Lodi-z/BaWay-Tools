; TransparencyTools.ahk
; 窗口透明度相关功能
class TransparencyTools {
    static SetTransparentAtCursor(value) => this.AdjustTransparencyAtCursor(value, true)

    static AddTransparentAtCursor(value) => this.AdjustTransparencyAtCursor(value, false)

    static SetTransColorAtCursor(value) {
        try {
            MouseGetPos &MouseX, &MouseY, &windowID, &con
            WinSetTransColor("Off", windowID)
            color := PixelGetColor(MouseX, MouseY)
            WinSetTransColor(color . " " . value, windowID)
            this.ShowTransparencyToolTip(value)
        } catch {
            MsgBox("该窗口的权限过高，如果执意要调整，请以管理员模式运行脚本。")
        }
    }

    static AdjustTransparencyAtCursor(value, setMode) {
        try {
            MouseGetPos , , &windowID, &con
            currentTransparency := WinGetTransparent(windowID)
            if (currentTransparency = "")
                currentTransparency := 255
            newTransparency := setMode ? value : currentTransparency + value
            newTransparency := (newTransparency < 1) ? 1 : (newTransparency > 255) ? 255 : newTransparency
            WinSetTransparent(newTransparency, windowID)
            this.ShowTransparencyToolTip(newTransparency)
        } catch {
            MsgBox("该窗口的权限过高，如果执意要调整，请以管理员模式运行脚本。")
        }
    }

    static ShowTransparencyToolTip(value) {
        ToolTip("当前不透明度: " value " (" Format("{:.1f}", value / 255 * 100) "%)")
        SetTimer () => ToolTip(""), -2000
    }
}