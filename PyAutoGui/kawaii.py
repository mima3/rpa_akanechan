import time
import pyautogui
import pyperclip
import datetime

# クリップボードを経由する場合
# http://sagantaf.hatenablog.com/entry/2017/10/18/231750
def copipe(string):
    pyperclip.copy(string)
    pyautogui.hotkey('ctrl', 'v')

# 指定の画像が表示されるまで待つ
def waitPicture(f):
    print(f)
    ret = None
    while ret is None:
        ret = pyautogui.locateOnScreen(f, grayscale=False, confidence=.8)
        print (ret)
        if ret is not None:
            return ret
        time.sleep(1)

mainButtons = pyautogui.locateOnScreen('mainbutton.bmp', grayscale=False, confidence=.8)
if mainButtons is None:
    print (u'VOICEROID2の再生ボタンが見つかりません')
    exit()

# テキスト選択
pyautogui.click(mainButtons[0] + 30, mainButtons[1] )

# テキストのクリア
pyautogui.hotkey('ctrl', 'a')
pyautogui.press('del')

# テキストの設定
copipe(u'ｱｶﾈﾁｬﾝｶﾜｲｲﾔｯﾀ')

# 再生
pyautogui.click(mainButtons[0], mainButtons[1] + mainButtons[3] / 2 )

# 読み上げまで待機
time.sleep(0.5)
waitPicture('status.bmp')

# 音声の保存
pyautogui.click(mainButtons[0] +  mainButtons[2], mainButtons[1] + mainButtons[3] / 2 )

wavSave = waitPicture('wavSave.bmp')
pyautogui.click(wavSave[0] + 5, wavSave[1] + wavSave[3] / 2 )

# ファイルの保存
fileSave = waitPicture('fileSave.bmp')
pyautogui.click(fileSave[0], fileSave[1])
copipe(datetime.datetime.now().strftime("%Y%m%d%H%M%S.wav"))
pyautogui.press('enter')

# 情報ダイアログ
info = waitPicture('info.bmp')
pyautogui.click(info[0] + info[2], info[1] + info[3])

# 葵ちゃんしゃべる
time.sleep(0.5)
aoi = pyautogui.locateOnScreen('aoi.bmp', grayscale=False, confidence=.8)
pyautogui.click(aoi[0], aoi[1])

# テキスト設定
pyautogui.click(mainButtons[0] + 30, mainButtons[1] )
pyautogui.hotkey('ctrl', 'a')
pyautogui.press('del')
copipe(u'ｵﾈｴﾁｬﾝｶﾜｲｲﾔｯﾀ')
pyautogui.click(mainButtons[0], mainButtons[1] + mainButtons[3] / 2 )

# 茜ちゃんに戻す
akane = pyautogui.locateOnScreen('akane.bmp', grayscale=False, confidence=.8)
pyautogui.click(akane[0], akane[1])
