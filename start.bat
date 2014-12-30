@echo off
REM 設定 V 硬碟代號與 data 目錄對應
set Disk=v
subst %Disk%: "data"
REM 設定 leo 相關對應 Home 位置
set HomePath=%Disk%:\home
set HomeDrive=%Disk%:\home
set Home=%Disk%:\home
REM 將後續的指令執行, 以 %Disk% 為主
%Disk%:
REM 設定 PYTHONPATH
set PYTHONPATH=%Disk%:\IDE\Python34
REM 設定 Leo 所用的編輯器
set LEO_EDITOR=%Disk%:\IDE\SciTE\SciTE.exe
REM 其他路徑設定
set path1=%PATH%;%Disk%:\IDE\Python34;%Disk%:\IDE\Python34\Scripts;
REM for git
set path2=%Disk%:\apps\Git\bin;%Disk%:\apps\miktex-portable\miktex\bin;%Disk%:\IDE\Python34\Lib\site-packages\PyQt4;
path=%path1%;%path2%;
start /MIN %Disk%:\IDE\SciTE\SciTE.exe
REM 啟動 mysql
start %Disk%:\apps\mysql\bin\mysqld1.exe
start /MIN cmd.exe
REM 啟動 Leo 編輯器
%Disk%:\IDE\Python34\python.exe %Disk%:\commands\launchLeo.py
Exit
