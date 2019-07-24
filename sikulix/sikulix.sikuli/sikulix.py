import datetime
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
#マルチディスプレイの場合は、１のディスプレイじゃないと動かない模様

# Trueに設定した場合、スクリプトが実行されると、Sikuliはアクションが実行される前にそ
# のアクションが発生する場所に視覚効果（点滅する二重線の赤い丸）を表示します。
# 標準で2秒
setShowActions(False)

# 茜ちゃんしゃべる
click(Pattern("1558790034069.png").targetOffset(-174,-16))
type('a', Key.CTRL)
type(Key.DELETE)
paste(u"ｱｶﾈﾁｬﾝｶﾜｲｲﾔｯﾀ")

click(Pattern("1558790034069.png").targetOffset(-162,14))
wait(2)

wait("1558790542060.png")
click(Pattern("1558790034069.png").targetOffset(121,16))

# 音声保存画面
click(Pattern("1558790796902.png").targetOffset(-39,2))

# 名前を付けて保存
click(Pattern("1558790905402.png").targetOffset(-45,-35))
type('a', Key.CTRL)
type(Key.DELETE)
paste(datetime.datetime.now().strftime("%Y%m%d%H%M%S.wav"))
type(Key.ENTER)
click(Pattern("1558790905402.png").targetOffset(-41,38))

# 情報のOKボタンクリック
click(Pattern("1558791076872.png").targetOffset(87,50))

# 消えるまでまつ
# 時間が読めない場合はregionとってexistsで消えるまで見る
wait(1)

# 葵ちゃん
click("1558791449664.png")
click(Pattern("1558790034069.png").targetOffset(-174,-16))
type('a', Key.CTRL)
type(Key.DELETE)
paste(u"ｵﾈｴﾁｬﾝｶﾜｲｲﾔｯﾀ")

click(Pattern("1558790034069.png").targetOffset(-162,14))
wait(2)

click("1558791495218.png")
