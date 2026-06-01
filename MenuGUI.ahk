; MenuGUI.ahk
; 菜单

class MenuGUI {
    /**@type {Gui}*/
    static guiObj := ""
    static originalConfig := ""  ; 存储原始配置用于检测是否修改

    static Show() {
        if (this.guiObj) {
            this.guiObj.Show
            return
        }

        ; 创建GUI
        this.CreateGUI()
        this.guiObj.Show("w800 h640")
    }

    static CreateGUI() {
        this.guiObj := Gui("-Resize", "八维实用小工具 - 设置面板")
        this.guiObj.OnEvent("Close", (*) => this.OnClose())
        this.guiObj.SetFont("s10", "Microsoft YaHei")

        ; 基本设置 - 顶部
        this.guiObj.AddGroupBox("x10 y10 w520 h100", "ℹ️ 软件信息").SetFont("w700")
        this.guiObj.AddText("x30 y40 w120", "作者：张一天")
        this.guiObj.AddButton("yp w120", "查看爱发电主页").OnEvent("Click",(*)=>Run("https://afdian.com/a/luodi"))
        this.guiObj.AddButton("yp w120", "查看b站主页").OnEvent("Click",(*)=>Run("https://space.bilibili.com/418324770"))
        this.guiObj.AddText("x30 y70 w120", "版本：v5.3")
        this.guiObj.AddPicture("x440 y30 w50 h50 Icon1", "image/icon.ico")
        this.guiObj.AddText("x418 y80 w105", "八维实用小工具").SetFont("w700 c8e2600")

        ; 启动设置 - 右上角
        this.guiObj.AddCheckbox("x550 y40 w230 vOpenThisPageOnStart", "启动时显示设置面板").Value := g_config.Settings.OpenThisPageOnStart
        this.guiObj.AddButton("x550 y70 w230", "肯德基疯狂星期四v我50！").OnEvent("Click", (*) => Run(
            "https://ifdian.net/order/create?user_id=35b7fc88d0d911eb8e6952540025c377"))

        ; 左侧 - 热键设置
        this.guiObj.AddGroupBox("x10 y120 w385 h120", "⌨️ 基础热键").SetFont("w700")
        this.AddHotkeyControl("x30 y150", "显示设置面板", "ShowTip", g_config.Hotkeys.ShowTip)
        this.AddHotkeyControl("x30 y190", "设置鼠标所在窗口置顶", "SetWindowAlwaysOnTop", g_config.Hotkeys.SetWindowAlwaysOnTop)

        ; 刷字数热键
        this.guiObj.AddGroupBox("x10 y250 w385 h160", "📝 刷字数热键").SetFont("w700")
        this.AddHotkeyControl("x30 y290", "逐字输出剪贴板", "TypeClipboardContentByChar", g_config.Hotkeys.TypeClipboardContentByChar)
        this.AddHotkeyControl("x30 y330", "剪贴板无限刷字", "LoopSendTextInClipboard", g_config.Hotkeys.LoopSendTextInClipboard)
        this.AddHotkeyControl("x30 y370", "自定义刷字", "HandleAutoTyping", g_config.Hotkeys.HandleAutoTyping)

        ; 透明度设置热键
        this.guiObj.AddGroupBox("x10 y420 w385 h150", "👁️ 更改鼠标所在窗口的透明度的热键").SetFont("w700")
        this.guiObj.AddText("x30 y445 w120", "修饰键：")

        modKey := g_config.Hotkeys.SetTransparentModifierKey
        cbAlt := this.guiObj.AddCheckbox("x150 y445 w60 vModAlt", "Alt")
        cbAlt.Value := (modKey & ModifierKey.Alt) ? 1 : 0
        cbShift := this.guiObj.AddCheckbox("x210 y445 w60 vModShift", "Shift")
        cbShift.Value := (modKey & ModifierKey.Shift) ? 1 : 0
        cbCtrl := this.guiObj.AddCheckbox("x270 y445 w60 vModCtrl", "Ctrl")
        cbCtrl.Value := (modKey & ModifierKey.Ctrl) ? 1 : 0
        cbWin := this.guiObj.AddCheckbox("x330 y445 w60 vModWin", "Win")
        cbWin.Value := (modKey & ModifierKey.Win) ? 1 : 0

        this.guiObj.AddText("x30 y475 w120", "启用模式：")
        mode := g_config.Hotkeys.SetTransparentMode
        cbNum := this.guiObj.AddCheckbox("x150 y475 w80 vModeNum", "数字键")
        cbNum.Value := (mode & SetTransparentMode.num) ? 1 : 0
        cbPlusMinus := this.guiObj.AddCheckbox("x230 y475 w80 vModePlusMinus", "+/-键")
        cbPlusMinus.Value := (mode & SetTransparentMode.plusMinus) ? 1 : 0
        cbWheel := this.guiObj.AddCheckbox("x310 y475 w80 vModeWheel", "滚轮")
        cbWheel.Value := (mode & SetTransparentMode.wheel) ? 1 : 0

        this.guiObj.AddText("x30 y505 w360", "如果勾选Alt+数字键，则可以按Alt+0-9设置窗口的透明度")
        this.guiObj.AddText("x30 y530 w360", "勾选Alt+“+/-键”，则按Alt+“+”或“-”增减透明度...")

        ; 网址设置
        this.guiObj.AddGroupBox("x405 y120 w385 h230", "🔗 网址设置").SetFont("w700")
        this.guiObj.AddText("x425 y150 w90", "考试平台：")
        this.guiObj.AddEdit("x515 y147 w260 vExamPlatForm", g_config.URLs.ExamPlatForm)

        this.guiObj.AddText("x425 y190 w90", "测评网站：")
        this.guiObj.AddEdit("x515 y187 w260 vCPWebForm", g_config.URLs.CPWebForm)

        this.guiObj.AddText("x425 y230 w90", "考试网盘：")
        this.guiObj.AddEdit("x515 y227 w260 vNAS_AddressForm", g_config.URLs.NAS_AddressForm)

        this.guiObj.AddText("x425 y270 w100", "考试网盘账号：")
        nasAccountEdit := this.guiObj.AddEdit("x515 y267 w200 vNAS_Account", AccountTools.GetBaWayAccount())
        ChangedNasAccFunc := (*) {
            currentSerial := nasAccountEdit.Value
            lastSerial := AccountTools.GetBaWayAccount()
            if (currentSerial != "") {

                if (currentSerial = lastSerial)
                    return

                ; 显示确认对话框
                result := MsgBox("确定要将账号从 " . lastSerial . " 更改为 " . currentSerial . " 吗？","即将更改网盘账号密码", "YesNo")

                if (result = "Yes") {
                    ; 用户确认，更新账号并保存
                    AccountTools.SaveBaWayAccount(nasAccountEdit.Value)
                    MsgBox("账号密码已更新为" currentSerial, "提示", "OK")
                    return
                }
            }
            nasAccountEdit.Value := lastSerial
        }
        nasAccountEdit.OnEvent("LoseFocus", ChangedNasAccFunc)
        this.PressEnterCompleteEdit(nasAccountEdit,(*)=>ControlFocus(this.guiObj.hwnd))
        this.guiObj.AddButton("x720 y267 w55", "末班").OnEvent("Click", (*) {
            currentSerial := nasAccountEdit.Value
            if (currentSerial != "") {
                nextSerial := AccountTools.GetNextSerialNumber(currentSerial)
                
                ; 显示确认对话框
                result := MsgBox("确定要将账号从 " . currentSerial . " 更改为 " . nextSerial . " 吗？","即将更改网盘账号密码", "YesNo")
                
                if (result = "Yes") {
                    ; 用户确认，更新账号并保存
                    nasAccountEdit.Value := nextSerial
                    AccountTools.SaveBaWayAccount(nasAccountEdit.Value)
                    MsgBox("账号密码已更新为" nextSerial, "提示", "OK")
                }
                ; 如果用户选择"No"，则不执行任何操作
            } else {
                MsgBox("当前账号为空，无法进行末班操作。", "提示", "OK")
            }
        })

        this.guiObj.AddText("x425 y310 w90", "作业网盘：")
        this.guiObj.AddEdit("x515 y307 w260 vHomeworkDisk", g_config.URLs.HomeworkDisk)

        ; 快捷打开
        this.guiObj.AddGroupBox("x405 y360 w385 h210", "🚀 快捷打开").SetFont("w700")
        this.guiObj.AddText("x425 y390 w90", "测评号码：")
        cPNumberEdit := this.guiObj.AddEdit("x515 y387 w150", "")
        openCpFunc := (*) {
            if (cPNumberEdit.Value != "") {
                url := g_config.URLs.CPWebForm . cPNumberEdit.Value
                Run(url)
            } else {
                MsgBox("请输入测评号码", "提示", "OK")
            }
        }
        this.PressEnterCompleteEdit(cPNumberEdit,openCpFunc)
        this.guiObj.AddButton("x675 y387 w100", "打开测评").OnEvent("Click", openCpFunc)
        this.guiObj.AddButton("x425 y430 w340", "打开考试平台").OnEvent("Click", (*) => Run(this.guiObj["ExamPlatForm"].Value))
        this.guiObj.AddButton("x425 y470 w165", "打开考试网盘(浏览器)").OnEvent("Click", (*) => Run("https://" . this.guiObj["NAS_AddressForm"].Value))
        this.guiObj.AddButton("x600 y470 w165", "打开考试网盘(文件夹)").OnEvent("Click", (*) => Run("\\" . this.guiObj["NAS_AddressForm"].Value)) ;ahk2\不是转义符！别再改了！
        this.guiObj.AddButton("x425 y510 w340", "打开作业网盘").OnEvent("Click", (*) => Run(this.guiObj["HomeworkDisk"].Value))

        ; 底部按钮
        this.guiObj.AddButton("x30 y585 w220 h40", "退出程序").OnEvent("Click", (*) => this.Exit())
        this.guiObj.AddButton("x290 y585 w220 h40", "保存并重启").OnEvent("Click", (*) => this.SaveAndRestart())
        CloseBtn := this.guiObj.AddButton("x550 y585 w220 h40", "开始使用")
        CloseBtn.OnEvent("Click", (*) => this.OnClose())
        CloseBtn.focus()
    }

    static PressEnterCompleteEdit(editControl,event){
        HotIf (*) => this.guiObj && WinActive(this.guiObj.Hwnd) && this.guiObj.FocusedCtrl = editControl
        Hotkey("Enter", (*) => event())
        HotIf
    }

    static AddHotkeyControl(pos, text, variable, defaultValue) {
        this.guiObj.AddText(pos " w120", text)
        yPos := SubStr(pos, InStr(pos, "y") + 1)
        xPos := SubStr(pos, InStr(pos, "x") + 1, InStr(pos, "y") - InStr(pos, "x") - 1)
        this.guiObj.AddHotkey("x" (xPos + 125) " y" yPos " w230 v" variable, defaultValue)
    }

    static Exit() {
        ; 检查是否有修改
        if (ConfigManager.HasChanges() || AccountTools.GetBaWayAccount() != this.guiObj["NAS_Account"].Value) {
            result := MsgBox("检测到配置已修改，是否保存？", "提示", "YesNoCancel Owner" this.guiObj.Hwnd)
            if (result = "Yes")
                this.SaveAndRestart
            else if (result = "Cancel")
                return
        }
        ExitApp
    }

    static SaveAndRestart() {
        ; 更新并保存到INI文件
        ConfigManager.Save
        ; 重启脚本
        Reload
    }

    ; 关闭窗口时的处理
    static OnClose() {
        ; 检查是否有修改
        if (ConfigManager.HasChanges()) {
            result := MsgBox("检测到配置已修改，是否保存？", "提示", "YesNoCancel Owner" this.guiObj.Hwnd)
            if (result = "Yes")
                this.SaveAndRestart
            else if (result = "Cancel")
                return
        }
        this.guiObj.destroy
        this.guiObj := ""
    }
}