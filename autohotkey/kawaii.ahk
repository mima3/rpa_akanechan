; win32�Ɖ摜�}�b�`���O�ł�������ł��Ȃ�
; �ȉ���UiAutomation���g�����݂�����Ă��邪COM�̃��b�v���������炢�Ȃ�VBA�ł��
; https://www.autohotkey.com/boards/viewtopic.php?t=28866
if WinExist("VOICEROID2")
    WinActivate  ; Uses the last found window.

; ret := ControlSetText, TextBox1, test
;WinMenuSelectItem, VOICEROID2*, , �e�L�X�g,�Đ�
Sleep 500
Send ^a
Send {Del}
SendInput akanechankawaiiyatta-
Send {Enter}
Send {F5}

; ���������E�E�E