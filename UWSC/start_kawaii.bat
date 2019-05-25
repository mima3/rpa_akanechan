@echo off
REM 日付の取得は以下参考
REM http://hiroto1979.hatenablog.jp/entry/2017/10/14/003418
REM UWSCのパスは環境に合わせて変更すること

REM 日付をyyyy/mm/dd形式で取得する
set d=%date%

REM 日付を年、月、日に分解する
set yyyy=%d:~-10,4%
set mm=%d:~-5,2%
set dd=%d:~-2,2%

REM 時間をhh:mn:ss形式で取得する
REM たんにtimeコマンドと入れるだけだと、hh:mn:ss形式で取得できないことに注意
set t=%time: =0%

REM 時間を時、分、秒に分解する
set hh=%t:~0,2%
set mn=%t:~3,2%
set ss=%t:~6,2%

echo %yyyy%%mm%%dd%_%hh%%mn%%ss%.wav
c:\tool\uwsc\uwsc kawaii.uws "%yyyy%%mm%%dd%_%hh%%mn%%ss%.wav"