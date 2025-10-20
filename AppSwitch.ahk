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

; 在脚本启动时强制关闭大写锁定状态，防止开机后大写处于锁定状态，导致默认输入大写
SetCapsLockState "Off"

; 将 CapsLock键 映射为 Ctrl键
CapsLock::Ctrl

; Alt + X : 最小化当前活动窗口，并保存其句柄
!x:: {
    global lastMinimizedHwnd  ; 声明使用全局变量

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
    global lastMinimizedHwnd  ; 声明使用全局变量

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
!WheelUp:: AdjustVolume(2)      ; Alt+滚轮向上：增大音量
!WheelDown:: AdjustVolume(-2)   ; Alt+滚轮向下：减小音量
!MButton:: ToggleMute()         ; Alt+鼠标中键：静音/恢复
!XButton1:: Media_Play_Pause()  ; Alt+鼠标侧键：播放/暂停 (XButton1后侧键，XButton2前侧键)

; 音量调节函数
AdjustVolume(amount) {
    ; amount: 需要调整的音量值，正数增加，负数减少，2的整数倍
    if (amount > 0) {
        loop amount // 2 {  ; 循环执行
            Send "{Volume_Up}" ;默认音量+2
        }
    } else if (amount < 0) {
        loop (-amount) // 2 {
            Send "{Volume_Down}" ;默认音量-2
        }
    }
}

; 切换静音
ToggleMute() {
    ; 切换系统静音（发送媒体键）
    Send "{Volume_Mute}"
}

; 媒体控制
Media_Play_Pause() {
    Send "{Media_Play_Pause}"
}
