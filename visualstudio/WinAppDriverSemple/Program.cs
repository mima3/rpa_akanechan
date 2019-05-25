using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using OpenQA.Selenium.Appium.Windows;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium;
using System.Globalization;

namespace WinAppDriverSemple
{

    class Program
    {
        static WindowsDriver<WindowsElement> desktopSession;
        private const string WindowsApplicationDriverUrl = "http://127.0.0.1:4723/";

        // 指定の要素が検索できるまで待機する
        public static WindowsElement WaitElementByAbsoluteXPath(WindowsDriver<WindowsElement> root, string xPath, int nTryCount = 15)
        {
            WindowsElement uiTarget = null;

            while (nTryCount-- > 0)
            {
                try
                {
                    uiTarget = root.FindElementByXPath(xPath);
                }
                catch
                {
                }

                if (uiTarget != null)
                {
                    break;
                }
                else
                {
                    System.Threading.Thread.Sleep(500);
                }
            }

            return uiTarget;
        }


        static void Main(string[] args)
        {
            // DesktopからVOCAROID2を検索
            DesiredCapabilities desktopCapabilities = new DesiredCapabilities();
            desktopCapabilities.SetCapability("app", "Root");
            desktopCapabilities.SetCapability("deviceName", "WindowsPC");
            desktopSession = new WindowsDriver<WindowsElement>(new Uri(WindowsApplicationDriverUrl), desktopCapabilities);
            String hwnd;
            WindowsElement appElem;
            appElem = desktopSession.FindElementByName("VOICEROID2");
            hwnd = appElem.GetAttribute("NativeWindowHandle");
            if (hwnd.Equals("0"))
            {
                appElem = desktopSession.FindElementByName("VOICEROID2*");
                hwnd = appElem.GetAttribute("NativeWindowHandle");
            }
            DesiredCapabilities appCapabilities = new DesiredCapabilities();
            hwnd = int.Parse(hwnd).ToString("x");
            appCapabilities.SetCapability("appTopLevelWindow", hwnd);
            WindowsDriver<WindowsElement> appSession = new WindowsDriver<WindowsElement>(new Uri(WindowsApplicationDriverUrl), appCapabilities);

            // しゃべらせる
            var txtMsg = appSession.FindElementByXPath("//Edit[@AutomationId=\"TextBox\"]");
            txtMsg.Click();
            // 英語キーボードじゃないと記号が旨く送信できない(Seleniumの仕様っぽい）
            txtMsg.SendKeys(Keys.LeftControl + "a");
            txtMsg.SendKeys(Keys.Delete);
            txtMsg.SendKeys("ｱｶﾈﾁｬﾝｶﾜｲｲﾔｯﾀ");

            var btnPlay = appSession.FindElementByXPath("//Button[@ClassName=\"Button\"]/Text[@ClassName=\"TextBlock\"][@Name=\"再生\"]");
            btnPlay.Click();

            // 保存開始
            var statusBar = WaitElementByAbsoluteXPath(appSession, "//StatusBar[@ClassName =\"StatusBar\"]/Text[@ClassName=\"StatusBarItem\"][@Name=\"テキストの読み上げは完了しました。\"]/Text[@ClassName=\"TextBlock\"][@Name=\"テキストの読み上げは完了しました。\"]");
            if (statusBar == null)
            {
                Console.Error.WriteLine("読み上げ失敗");
                return;
            }

            var btnSave = appSession.FindElementByXPath("//Button[@ClassName=\"Button\"]/Text[@ClassName=\"TextBlock\"][@Name=\"音声保存\"]");
            btnSave.Click();


            // 音声保存画面でOK押下
            var btnSaveOk = appSession.FindElementByXPath("//Window[@ClassName =\"Window\"][@Name=\"音声保存\"]/Button[@ClassName=\"Button\"][@Name=\"OK\"]");
            btnSaveOk.Click();

            // 名前を付けて保存
            var txtFileName = appSession.FindElementByXPath("//Window[@ClassName=\"#32770\"][@Name=\"名前を付けて保存\"]/Pane[@ClassName=\"DUIViewWndClassName\"]/ComboBox[@Name=\"ファイル名:\"][@AutomationId=\"FileNameControlHost\"]/Edit[@ClassName=\"Edit\"][@Name=\"ファイル名:\"]");
            String hankakuKey = Convert.ToString(Convert.ToChar(0xE0 + 244, CultureInfo.InvariantCulture), CultureInfo.InvariantCulture);
            // 英字キーボードだと以下のキーで半角全角切り替えになる
            txtFileName.SendKeys("`"); // 0xFF40

            txtFileName.SendKeys(Keys.LeftControl + "a");
            txtFileName.SendKeys(Keys.Delete);
            //
            txtFileName.SendKeys(System.DateTime.Now.ToString("yyyymMMddhhmmss") + ".wav");
            txtFileName.SendKeys(Keys.Enter);


            //
            var infoOk = WaitElementByAbsoluteXPath(appSession, "//Window[@ClassName=\"#32770\"][@Name=\"情報\"]/Button[@ClassName=\"Button\"][@Name=\"OK\"]");
            infoOk.Click();

        }
    }
}
