@echo off
set Disk=v
REM 關閉 mongoose
REM taskkill /IM mongoose.exe /F
REM 關閉 nginx
REM taskkill /IM nginx.exe /F
REM 關閉 SciTE
taskkill /IM SciTE.exe /F
REM 關閉 python
taskkill /IM python.exe /F
REM 關閉 php-cgi.exe
REM taskkill /IM php-cgi.exe /F
REM 關閉 mysqld1.exe
taskkill /IM mysqld1.exe /F
REM 清除 log 資料
REM 清除 log 資料
path=%PATH%;
REM del /Q /F  V:\wwwServers\logs\*.*
REM del /Q /F V:\wwwServers\nginx-1.2.3\logs\*.*
REM del /Q /F V:\www\cmsimplexh_20130809\cmsimple\log.txt
del /Q /F  V:\tmp\*.*
REM copy V:\www\cmsimplexh_20130809\cmsimple\log_clean.txt V:\www\cmsimpleSpring2013\cmsimple\log.txt
path=%PATH%;
del /Q /F  V:\tmp\*.*
REM 終止虛擬硬碟與目錄的對應
subst %Disk%: /D
REM 關閉 node.exe
taskkill /IM node.exe /F
taskkill /IM conhost.exe /F
REM 關閉 cmd 指令視窗
taskkill /IM cmd.exe /F
EXIT
