; win32と画像マッチングでしか操作できない
; 以下でUiAutomationを使う試みがされているがCOMのラップを書くくらいならVBAでやる
; https://www.autohotkey.com/boards/viewtopic.php?t=28866
if WinExist("VOICEROID2")
    WinActivate  ; Uses the last found window.

; ret := ControlSetText, TextBox1, test
;WinMenuSelectItem, VOICEROID2*, , テキスト,再生
Sleep 500
Send ^a
Send {Del}
SendInput akanechankawaiiyatta-
Send {Enter}
Send {F5}

; もう無理・・・