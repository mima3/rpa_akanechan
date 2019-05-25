Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-type -AssemblyName System.Windows.Forms

$source = @"
using System;
using System.Windows.Automation;
public class AutomationHelper
{
    public static AutomationElement RootElement
    {
        get
        {
            return AutomationElement.RootElement;
        }
    }

    public static AutomationElement GetMainWindowByTitle(string title) {
        PropertyCondition cond = new PropertyCondition(AutomationElement.NameProperty, title);
        return RootElement.FindFirst(TreeScope.Children, cond);
    }
    
    public static AutomationElement ChildWindowByTitle(AutomationElement parent , string title) {
        try {
            PropertyCondition cond = new PropertyCondition(AutomationElement.NameProperty, title);
            return parent.FindFirst(TreeScope.Children, cond);
        } catch {
            return null;
        }
    }

    public static AutomationElement WaitChildWindowByTitle(AutomationElement parent, string title, int timeout = 10) {
        DateTime start = DateTime.Now;
        while (true) {
            AutomationElement ret = ChildWindowByTitle(parent, title);
            if (ret != null) {
                return ret;
            }
            TimeSpan ts = DateTime.Now - start;
            if (ts.TotalSeconds > timeout) {
               return null;
            }
            System.Threading.Thread.Sleep(100);
        }
    }
}
"@
Add-Type -TypeDefinition $source -ReferencedAssemblies("UIAutomationClient", "UIAutomationTypes")

# 5.0以降ならusingで記載した方が楽。
$autoElem = [System.Windows.Automation.AutomationElement]

# ウィンドウ以下で指定の条件に当てはまるコントロールを全て列挙
function findAllElements($form, $condProp, $condValue) {
    $cond = New-Object -TypeName System.Windows.Automation.PropertyCondition($condProp, $condValue)
	return $form.FindAll([System.Windows.Automation.TreeScope]::Element -bor [System.Windows.Automation.TreeScope]::Descendants, $cond)
}

# ウィンドウ以下で指定の条件に当てはまるコントロールを１つ取得
function findFirstElement($form, $condProp, $condValue) {
    $cond = New-Object -TypeName System.Windows.Automation.PropertyCondition($condProp, $condValue)
	return $form.FindFirst([System.Windows.Automation.TreeScope]::Element -bor [System.Windows.Automation.TreeScope]::Descendants, $cond)
}

# 要素をValuePatternに変換
function convertValuePattern($elem) {
	return $elem.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern) -as [System.Windows.Automation.ValuePattern]
}

# 指定の要素をボタンとみなして押下する
function pushButton($form, $index) {
    $buttonElemes = findAllElements $form $autoElem::ClassNameProperty "Button"
    $invElm = $buttonElemes[$index].GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern) -as [System.Windows.Automation.InvokePattern]
    $invElm.Invoke()
}

# 指定のAutomationIDのボタンを押下
function pushButtonById($form, $id) {
    $buttonElem = findFirstElement $form $autoElem::AutomationIdProperty $id
    $invElm = $buttonElem.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern) -as [System.Windows.Automation.InvokePattern]
    $invElm.Invoke()
}

# 指定の内容をしゃべらせる
function speakText($mainForm, $message) {
	try {
		# テキストの検索
		$textboxElems = findAllElements $mainForm $autoElem::ClassNameProperty "TextBox"
		$messageValuePtn = convertValuePattern $textboxElems[0]
		$messageValuePtn.SetValue($message);
		
		# 音声保存ボタン押下
		pushButton $mainForm 0

		# 読み上げ中は待機
		$cond = New-Object -TypeName System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, "テキストの読み上げは完了しました。")
		do
		{
		  Start-Sleep -m 500 
		  $elems = $mainForm.FindAll([System.Windows.Automation.TreeScope]::Element -bor [System.Windows.Automation.TreeScope]::Descendants, $cond)
		}
		while ($elems.Count -eq 0)

		return $True
	} catch {
	    Write-Error "ファイルの保存に失敗しました"
	    $_
		return $False
	}
}

# しゃべる内容を設定後指定のファイルに保存
function saveText($mainForm , $message, $outPath) {
	try {
		# テキストの検索
		$textboxElems = findAllElements $mainForm $autoElem::ClassNameProperty "TextBox"
		$messageValuePtn = convertValuePattern $textboxElems[0]
		$messageValuePtn.SetValue($message);

		# 音声保存ボタン押下
		pushButton $mainForm 4
		
		#音声保存ウィンドウが表示される可能性
		$saveWvForm = [AutomationHelper]::WaitChildWindowByTitle($mainForm, "音声保存", 2)
		pushButton $saveWvForm 0

		#名前を付けて保存
		$saveFileForm = [AutomationHelper]::WaitChildWindowByTitle($saveWvForm, "名前を付けて保存", 5)
		if ($saveFileForm -eq $null) {
			return $False;
		}
		$txtFilePathElem = findFirstElement $saveFileForm $autoElem::AutomationIdProperty "1001"
		$txtFilePathValuePtn = convertValuePattern $txtFilePathElem
		$txtFilePathValuePtn.SetValue($outPath);
		[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
		#エンターでないとコンボボックスが効いて、元に戻る。
		#pushButtonById $saveFileForm "1"

		# ここでファイルの上書きがtxtとwav分でる可能性があるが、ファイル名を一意にすることで回避すること

		# 情報ポップアップがでるまで待機
		$infoWin = [AutomationHelper]::WaitChildWindowByTitle($saveWvForm, "情報", 60)
		if ($infoWin -eq $null) {
			return $False;
		}
		pushButton $infoWin 0
		return $True
	}
	catch {
	    Write-Error "ファイルの保存に失敗しました"
	    $_
		return $False
	}
	
}

# メイン処理
$mainForm = [AutomationHelper]::GetMainWindowByTitle("VOICEROID2")
if ($mainForm -eq $null) {
    $mainForm = [AutomationHelper]::GetMainWindowByTitle("VOICEROID2*")
}
if ($mainForm -eq $null) {
    Write-Error "VOICEROID2を起動してください"
    exit 1
}

# しゃべる
$ret = speakText $mainForm 'ｱｶﾈﾁｬﾝｶﾜｲｲﾔｯﾀ'
if ($ret -eq $False ) {
	exit
}

# 保存する
$fileName =  Get-Date -Format "yyyyMMddHHmmss.wav"
saveText $mainForm 'ｱｶﾈﾁｬﾝｶﾜｲｲﾔｯﾀ' $fileName
