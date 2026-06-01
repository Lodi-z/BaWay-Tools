; TopmostTools.ahk
; 窗口置顶相关功能


class TopmostTools {
    static SetWindowAlwaysOnTop() {
        try {
            ; 获取鼠标下的窗口ID
            MouseGetPos(, , &windowID)
            
            ; 检查窗口ID是否有效
            if (!windowID) {
                MsgBox("未检测到有效窗口")
                return
            }
            
            ; 获取窗口的扩展样式并检查是否已置顶
            exStyle := WinGetExStyle("ahk_id " windowID)
            isAlwaysOnTop := (exStyle & 0x8) != 0
            
            ; 切换置顶状态
            WinSetAlwaysOnTop(isAlwaysOnTop ? 0 : 1, "ahk_id " windowID)
            
            ; 显示提示信息
            ToolTip("窗口置顶状态: " (isAlwaysOnTop ? "关闭" : "开启"))
            SetTimer(() => ToolTip(), -2000)
        } catch as err {
            MsgBox("设置窗口置顶失败: " err.Message "`n请尝试以管理员模式运行脚本。")
        }
    }
}
