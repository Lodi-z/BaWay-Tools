; AccountTools.ahk
; 网盘账号管理功能

class AccountTools {
    ; 获取八维网盘账号
    static GetBaWayAccount() {
        Target := g_config.URLs.NAS_AddressForm
        Output := ""
        TempFile := A_Temp "\cmdkey_output.txt"
        RunWait "cmd.exe /c cmdkey /list > " TempFile, , "Hide"
        Output := FileRead(TempFile)
        FileDelete(TempFile)
        Found := false
        loop parse Output, "`n", "`r" {
            if Found {
                if InStr(A_LoopField, "用户:") {
                    UserName := Trim(StrSplit(A_LoopField, ":")[2])
                    return UserName
                }
            }
            if InStr(A_LoopField, Target) {
                Found := true
            }
        }
        return ""
    }

    ; 保存八维网盘账号
    static SaveBaWayAccount(account) {
        if (account = "")
            return false

        Target := g_config.URLs.NAS_AddressForm

        ; 先删除旧的凭证（如果存在）
        RunWait "cmd.exe /c cmdkey /delete:" Target, , "Hide"

        ; 添加新凭证
        RunWait "cmd.exe /c cmdkey /add:" Target " /user:" account " /pass:" account, , "Hide"
        return true
    }

    ; 原有的更改账号功能（保留向后兼容）
    static ChangeBaWayAccount() {
        DefaultAccount := this.GetBaWayAccount()
        InputBoxObj := InputBox(
            "\n请输入当前账号（账号和密码相同），\n\n格式 :(学院首字母)yx(班级)22xxA-(具体分类)yuanyuzhou\n\n你的当前账号: ",
            "设置八维网盘账号", , DefaultAccount
        )
        if (InputBoxObj.Result = "OK" && InputBoxObj.Value != "") {
            if this.SaveBaWayAccount(InputBoxObj.Value)
                MsgBox("用户凭证已成功设置！重启或者等待一段时间后生效。")
        }
        else {
            TrayTip("操作已取消或输入无效。", "提示")
        }
    }
    ; 有参有返方法：根据当前序列号生成下一个序列号
    static GetNextSerialNumber(currentSerial) {
        ; 使用正则表达式解析序列号格式：字母+年份(2位)+月份(2位)+字母+名称
        if (RegExMatch(currentSerial, "([A-Za-z]+)(\d{2})(\d{2})([A-Za-z]*)-(.+)", &match)) {
            prefix := match[1]  ; 前缀字母部分，如 "yx"
            year := Integer(match[2])  ; 年份后两位，如 23
            month := Integer(match[3])  ; 月份，如 06
            middle := match[4]  ; 中间字母部分，如 "A"
            suffix := match[5]  ; 后缀名称部分，如 "yuanyuzhou"

            ; 月份递增
            month += 1

            ; 处理跨年情况
            if (month > 12) {
                month := 1
                year += 1

                ; 处理世纪更替（如果年份超过99，回到00）
                if (year > 99) {
                    year := 0
                }
            }

            ; 格式化新的序列号
            newYear := Format("{:02d}", year)
            newMonth := Format("{:02d}", month)

            return prefix . newYear . newMonth . middle . "-" . suffix
        }

        ; 如果格式不匹配，返回原始值或抛出错误
        return currentSerial
    }
}