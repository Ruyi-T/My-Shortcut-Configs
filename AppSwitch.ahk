#Requires AutoHotkey v2.0
#SingleInstance Force

; AutoHotkey 脚本：AppSwitcher.ahk
; 功能说明：
; 1.通过 Alt + 快捷键 启动或切换常用应用
; 2.最小化当前窗口及恢复上次最小化窗口
; 3.音量调节和媒体控制

; 全局变量：用于存储上次通过 Alt+X 最小化的窗口句柄
global lastMinimizedHwnd := ""

; 应用路径（请根据你实际的安装路径修改）
explorerPath := "explorer.exe"  ; 资源管理器
EdgePath := "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
VSCodePath := "D:\MyAPP\Microsoft VS Code\Code.exe"
WPSPath := "D:\MyAPP\WPS Office\ksolaunch.exe"
ObsidianPath := "D:\MyAPP\Obsidian\Obsidian.exe"
ZenPath := "C:\Program Files\Zen Browser\zen.exe"
CherryStudioPath := "D:\MyAPP\Cherry Studio\Cherry Studio.exe"
ChromePath := "C:\Program Files\Google\Chrome\Application\chrome.exe"
KuGouPath := "D:\KuGou\KGMusic\KuGou.exe"
QQPath := "D:\QQ\QQ\QQ.exe"

; 快捷键绑定 Alt + ...
!q:: RunOrActivate(QQPath, "ahk_exe QQ.exe")            ; Alt + Q : QQ
!w:: RunOrActivate(WPSPath, "ahk_exe ksolaunch.exe")    ; Alt + W : WPS
!e:: RunOrActivate(VSCodePath, "ahk_exe Code.exe")      ; Alt + E : VS Code
!r:: RunOrActivate(KuGouPath, "ahk_exe KuGou.exe")      ; Alt + R : KuGou 音乐

!f:: RunOrActivate(explorerPath, "ahk_class CabinetWClass")  ; Alt + F : 资源管理器 -- file文件
!d:: RunOrActivate(ObsidianPath, "ahk_exe Obsidian.exe")     ; Alt + D : Obsidian笔记
!s:: RunOrActivate(ChromePath, "ahk_exe chrome.exe")         ; Alt + S : Chrome浏览器 -- search搜索
;Alt + A : 网页翻译（沉浸式翻译）

!z:: RunOrActivate(ZenPath, "ahk_exe zen.exe")                      ; Alt + Z : Zen浏览器
!c:: RunOrActivate(CherryStudioPath, "ahk_exe Cherry Studio.exe")   ; Alt + C : Cherry Studio
; Alt + V : 剪贴板(uTools)
; Alt + X : 最小化当前活动窗口

; 在脚本启动时强制关闭大写锁定状态，防止开机后大写处于锁定状态，默认输入大写
SetCapsLockState "Off"

; 将 Caps Lock 映射为 Ctrl
CapsLock::Ctrl

; Alt + X : 最小化当前活动窗口，并保存其句柄
!x:: {
    ; 确保不是桌面或任务栏等特殊窗口
    local currentActiveHwnd := WinGetID("A") ;
    if (currentActiveHwnd != 0 && WinGetTitle(currentActiveHwnd) != "Program Manager" && WinGetClass(currentActiveHwnd) !=
    "Program") {
        lastMinimizedHwnd := currentActiveHwnd
    } else {
        lastMinimizedHwnd := "" ; 如果当前活动窗口不是一个普通应用窗口，则不保存
    }

    WinMinimize "A" ; 最小化当前活动窗口
}

; Alt + Shift + X : 恢复上次最小化的窗口
!+x:: {
    ; 检查是否有上次最小化的窗口句柄，并且该窗口仍然存在
    if (lastMinimizedHwnd && WinExist(lastMinimizedHwnd)) {
        ; 检查该窗口当前是否处于最小化状态 (WinMin 返回 1 如果最小化，否则返回 0)
        if (WinGetMinMax(lastMinimizedHwnd) == -1) {
            try {
                WinRestore lastMinimizedHwnd ; 恢复窗口
                WinActivate lastMinimizedHwnd ; 激活窗口，使其获得焦点
            }
        }
        ; 无论是恢复成功还是失败，都清空句柄，防止下次重复恢复同一个窗口
        ; 这样下次 Alt+Shift+X 将尝试恢复一个新的最小化窗口 (如果 Alt+X 再次使用)
        lastMinimizedHwnd := ""
    }
}

; 函数：激活窗口或运行程序
RunOrActivate(path, winId) {
    if WinExist(winId) {
        try WinActivate
    } else {
        try Run(path)
    }
}

; 函数：最小化窗口
MinimizeWindow(winId) {
    if WinExist(winId) {
        try WinMinimize
    }
}

; 音量控制 & 媒体控制
!WheelUp:: AdjustVolume(2)     ; Alt+滚轮上：增大音量
!WheelDown:: AdjustVolume(-2)  ; Alt+滚轮下：减小音量
!XButton1::Media_Play_Pause    ; Alt+鼠标侧键：播放/暂停 (XButton1后侧键，XButton2前侧键)

; 音量调节函数
AdjustVolume(amount) {
    if (amount > 0) {
        ; 对于正数，我们希望传递像 "+2" 这样的字符串
        SoundSetVolume "+" . amount
    } else if (amount < 0) {
        ; 对于负数，我们希望传递像 "-2" 这样的字符串
        ; "" . amount 会将数字 amount（例如 -2）转换成字符串 "-2"
        SoundSetVolume "" . amount
    }
    ; 如果 amount 是 0，此函数将不执行任何操作

    ; 获取当前音量
    currentVolume := SoundGetVolume()
    ; 四舍五入音量值，使其更易读
    displayVolume := Round(currentVolume)

    ; 创建GUI并设置样式（每次调整都会新建）
    myGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    myGui.BackColor := "333333"  ; 背景色
    myGui.Margin := 2              ; 边框厚度

    myGui.SetFont("s20 Bold c3A8BFF", "Noto Sans SC")  ; 字体大小20，蓝色

    ; 添加文本控件（原有部分）
    myGui.Add("Text", "w150 h40 Center", "音量: " displayVolume "%")

    ; 添加进度条控件（新增部分）
    progressOpts := "w150 h10 c3183e0 Background424242 -Theme Range0-100"
    progressCtrl := myGui.Add("Progress", progressOpts, displayVolume)

    myGui.Show("AutoSize Center")

    ; 定义圆角半径（按需调整）
    r := 10  ; 圆角半径（建议8-15之间）
    WinGetClientPos(, , &w, &h, myGui.Hwnd)
    region := DllCall("CreateRoundRectRgn", "int", 0, "int", 0, "int", w, "int", h, "int", r, "int", r)
    DllCall("SetWindowRgn", "ptr", myGui.Hwnd, "ptr", region, "int", 1)

    ; 设置计时器销毁GUI（替换原有清除ToolTip）
    SetTimer () => myGui.Destroy(), -1000

}

; 媒体控制
Media_Play_Pause() {
    Send "{Media_Play_Pause}"
}
