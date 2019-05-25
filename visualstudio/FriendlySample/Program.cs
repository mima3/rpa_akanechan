using Codeer.Friendly;
using Codeer.Friendly.Windows;
using Codeer.Friendly.Windows.Grasp;
using RM.Friendly.WPFStandardControls;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Codeer.Friendly.Windows.NativeStandardControls;
using Codeer.Friendly.Dynamic;

namespace AkanechanKawaii
{
    class Program
    {
        static void Main(string[] args)
        {
            // プロセスの取得
            Process[] ps = Process.GetProcessesByName("VoiceroidEditor");
            if (ps.Length == 0)
            {
                Console.Error.WriteLine("VOICEROID2を起動してください");
                return;
            }

            // WindowsAppFriendをプロセスから作成する
            // 接続できない旨のエラーの場合、別のプロセスでテスト対象のプロセスを操作している場合がある。
            // TestAssistant使いながら動作できないようなので、注意。
            var app = new WindowsAppFriend(ps[0]);

            var mainWindow = WindowControl.FromZTop(app);

            // 茜ちゃんしゃべる
            WPFTextBox txtMessage = new WPFTextBox(mainWindow.IdentifyFromLogicalTreeIndex(0, 4, 3, 5, 3, 0, 2));
            txtMessage.EmulateChangeText("ｱｶﾈﾁｬﾝｶﾜｲｲﾔｯﾀ");

            WPFButtonBase btnPlay = new WPFButtonBase(mainWindow.IdentifyFromLogicalTreeIndex(0, 4, 3, 5, 3, 0, 3, 0));
            btnPlay.EmulateClick();

            // ステータスバーを監視してしゃべり終わるまでまつ
            String sts;
            do
            {
                System.Threading.Thread.Sleep(500);
                var txtStatusItem = mainWindow.IdentifyFromVisualTreeIndex(0, 0, 0, 0, 2, 0, 0, 0, 4, 0, 0, 0).Dynamic(); ;
                sts = txtStatusItem.Text.ToString();
            } while (!sts.Equals("テキストの読み上げは完了しました。"));

            // 保存ボタン押下
            // ダイアログが表示されると引数なしのEmulateClickだと止まるのでAsyncオブジェクトを渡しておく
            var async = new Async();
            WPFButtonBase btnSave = new WPFButtonBase(mainWindow.IdentifyFromLogicalTreeIndex(0, 4, 3, 5, 3, 0, 3, 5));
            btnSave.EmulateClick(async);

            // 音声保存ダイアログ操作
            var dlgSaveWav = mainWindow.WaitForNextModal();
            var asyncSaveWin = new Async();
            WPFButtonBase buttonOK = new WPFButtonBase(dlgSaveWav.IdentifyFromLogicalTreeIndex(0, 1, 0));
            buttonOK.EmulateClick(asyncSaveWin);

            // ファイル名指定後の保存
            var asyncSaveFile = new Async();
            var dlgFileSave = dlgSaveWav.WaitForNextModal();
            NativeEdit editFileName = new NativeEdit(dlgFileSave.IdentifyFromZIndex(11, 0, 4, 0, 0));
            editFileName.EmulateChangeText(System.DateTime.Now.ToString("yyyymMMddhhmmss") + ".wav");

            NativeButton btnSaveOk = new NativeButton(dlgFileSave.IdentifyFromDialogId(1));
            btnSaveOk.EmulateClick(asyncSaveFile);
            
            // 情報ダイアログが表示されるまで待機してOKを押下
            var dlgInfo = WindowControl.WaitForIdentifyFromWindowText(app, "情報");
            NativeButton btn = new NativeButton(dlgInfo.IdentifyFromWindowText("OK"));
            btn.EmulateClick();


            //非同期で実行した保存ボタン押下の処理が完全に終了するのを待つ
            asyncSaveFile.WaitForCompletion();
            asyncSaveWin.WaitForCompletion();
            async.WaitForCompletion();


            // 葵ちゃんに切り替えてしゃべる
            // UIAutomationだと葵ちゃん切り替えが行えない。
            WPFListView ListView = new WPFListView(mainWindow.IdentifyFromLogicalTreeIndex(0, 4, 3, 3, 0, 1, 0, 2));
            ListView.EmulateChangeSelectedIndex(1);
            txtMessage.EmulateChangeText("ｵﾈｴﾁｬﾝｶﾜｲｲﾔｯﾀ");
            btnPlay.EmulateClick();
            ListView.EmulateChangeSelectedIndex(0);

        }
    }
}
