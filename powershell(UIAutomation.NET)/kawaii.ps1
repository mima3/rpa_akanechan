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

# 5.0�ȍ~�Ȃ�using�ŋL�ڂ��������y�B
$autoElem = [System.Windows.Automation.AutomationElement]

# �E�B���h�E�ȉ��Ŏw��̏����ɓ��Ă͂܂�R���g���[����S�ė�
function findAllElements($form, $condProp, $condValue) {
    $cond = New-Object -TypeName System.Windows.Automation.PropertyCondition($condProp, $condValue)
	return $form.FindAll([System.Windows.Automation.TreeScope]::Element -bor [System.Windows.Automation.TreeScope]::Descendants, $cond)
}

# �E�B���h�E�ȉ��Ŏw��̏����ɓ��Ă͂܂�R���g���[�����P�擾
function findFirstElement($form, $condProp, $condValue) {
    $cond = New-Object -TypeName System.Windows.Automation.PropertyCondition($condProp, $condValue)
	return $form.FindFirst([System.Windows.Automation.TreeScope]::Element -bor [System.Windows.Automation.TreeScope]::Descendants, $cond)
}

# �v�f��ValuePattern�ɕϊ�
function convertValuePattern($elem) {
	return $elem.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern) -as [System.Windows.Automation.ValuePattern]
}

# �w��̗v�f���{�^���Ƃ݂Ȃ��ĉ�������
function pushButton($form, $index) {
    $buttonElemes = findAllElements $form $autoElem::ClassNameProperty "Button"
    $invElm = $buttonElemes[$index].GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern) -as [System.Windows.Automation.InvokePattern]
    $invElm.Invoke()
}

# �w���AutomationID�̃{�^��������
function pushButtonById($form, $id) {
    $buttonElem = findFirstElement $form $autoElem::AutomationIdProperty $id
    $invElm = $buttonElem.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern) -as [System.Windows.Automation.InvokePattern]
    $invElm.Invoke()
}

# �w��̓��e������ׂ点��
function speakText($mainForm, $message) {
	try {
		# �e�L�X�g�̌���
		$textboxElems = findAllElements $mainForm $autoElem::ClassNameProperty "TextBox"
		$messageValuePtn = convertValuePattern $textboxElems[0]
		$messageValuePtn.SetValue($message);
		
		# �����ۑ��{�^������
		pushButton $mainForm 0

		# �ǂݏグ���͑ҋ@
		$cond = New-Object -TypeName System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, "�e�L�X�g�̓ǂݏグ�͊������܂����B")
		do
		{
		  Start-Sleep -m 500 
		  $elems = $mainForm.FindAll([System.Windows.Automation.TreeScope]::Element -bor [System.Windows.Automation.TreeScope]::Descendants, $cond)
		}
		while ($elems.Count -eq 0)

		return $True
	} catch {
	    Write-Error "�t�@�C���̕ۑ��Ɏ��s���܂���"
	    $_
		return $False
	}
}

# ����ׂ���e��ݒ��w��̃t�@�C���ɕۑ�
function saveText($mainForm , $message, $outPath) {
	try {
		# �e�L�X�g�̌���
		$textboxElems = findAllElements $mainForm $autoElem::ClassNameProperty "TextBox"
		$messageValuePtn = convertValuePattern $textboxElems[0]
		$messageValuePtn.SetValue($message);

		# �����ۑ��{�^������
		pushButton $mainForm 4
		
		#�����ۑ��E�B���h�E���\�������\��
		$saveWvForm = [AutomationHelper]::WaitChildWindowByTitle($mainForm, "�����ۑ�", 2)
		pushButton $saveWvForm 0

		#���O��t���ĕۑ�
		$saveFileForm = [AutomationHelper]::WaitChildWindowByTitle($saveWvForm, "���O��t���ĕۑ�", 5)
		if ($saveFileForm -eq $null) {
			return $False;
		}
		$txtFilePathElem = findFirstElement $saveFileForm $autoElem::AutomationIdProperty "1001"
		$txtFilePathValuePtn = convertValuePattern $txtFilePathElem
		$txtFilePathValuePtn.SetValue($outPath);
		[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
		#�G���^�[�łȂ��ƃR���{�{�b�N�X�������āA���ɖ߂�B
		#pushButtonById $saveFileForm "1"

		# �����Ńt�@�C���̏㏑����txt��wav���ł�\�������邪�A�t�@�C��������ӂɂ��邱�Ƃŉ�����邱��

		# ���|�b�v�A�b�v���ł�܂őҋ@
		$infoWin = [AutomationHelper]::WaitChildWindowByTitle($saveWvForm, "���", 60)
		if ($infoWin -eq $null) {
			return $False;
		}
		pushButton $infoWin 0
		return $True
	}
	catch {
	    Write-Error "�t�@�C���̕ۑ��Ɏ��s���܂���"
	    $_
		return $False
	}
	
}

# ���C������
$mainForm = [AutomationHelper]::GetMainWindowByTitle("VOICEROID2")
if ($mainForm -eq $null) {
    $mainForm = [AutomationHelper]::GetMainWindowByTitle("VOICEROID2*")
}
if ($mainForm -eq $null) {
    Write-Error "VOICEROID2���N�����Ă�������"
    exit 1
}

# ����ׂ�
$ret = speakText $mainForm '�����ݶܲ�ԯ�'
if ($ret -eq $False ) {
	exit
}

# �ۑ�����
$fileName =  Get-Date -Format "yyyyMMddHHmmss.wav"
saveText $mainForm '�����ݶܲ�ԯ�' $fileName
