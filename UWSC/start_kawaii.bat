@echo off
REM ���t�̎擾�͈ȉ��Q�l
REM http://hiroto1979.hatenablog.jp/entry/2017/10/14/003418
REM UWSC�̃p�X�͊��ɍ��킹�ĕύX���邱��

REM ���t��yyyy/mm/dd�`���Ŏ擾����
set d=%date%

REM ���t��N�A���A���ɕ�������
set yyyy=%d:~-10,4%
set mm=%d:~-5,2%
set dd=%d:~-2,2%

REM ���Ԃ�hh:mn:ss�`���Ŏ擾����
REM �����time�R�}���h�Ɠ���邾�����ƁAhh:mn:ss�`���Ŏ擾�ł��Ȃ����Ƃɒ���
set t=%time: =0%

REM ���Ԃ����A���A�b�ɕ�������
set hh=%t:~0,2%
set mn=%t:~3,2%
set ss=%t:~6,2%

echo %yyyy%%mm%%dd%_%hh%%mn%%ss%.wav
c:\tool\uwsc\uwsc kawaii.uws "%yyyy%%mm%%dd%_%hh%%mn%%ss%.wav"