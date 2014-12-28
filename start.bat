@echo off
REM 設定 V 硬碟代號與 data 目錄對應
set Disk=v
set Netbeans=z
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
REM Lua 相關設定
set LUA_DEV=%Disk%:\IDE\Lua
set LUA_PATH="?;?.lua;%Disk%:\IDE\Lua\lua\?.lua;%Disk%:\IDE\Lua\lua\luarocks\?.lua"
REM Node.js 相關設定
set NODE_PATH=%Disk%:\IDE\nodejs\node_modules\npm\node_modules;%Disk%:IDE\nodejs\node_modules\npm
REM 設定 Jdk 路徑, 特別注意 CLASSPATH 後的分號, 一定要有
set JAVA_HOME=%Netbeans%:\jdk1.8.0_05
set CLASSPATH=.;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\lib\tools.jar;%Disk%:\pfc.jar;"D:\Creo2\Common Files\M040\i486_nt\obj\JRE\lib";
set PRO_JAVA_COMMAND=%Netbeans%:jdk1.8.0_05\bin\java
set jlink_java_command=%Netbeans%:\jdk1.8.0_05\bin\java
REM kivy 相關設定
set GST_REGISTRY=%Disk%:\apps\gstreamer\registry.bin
set GST_PLUGIN_PATH=%Disk%:\apps\gstreamer\lib\gstreamer-1.0
set path7=%Disk%:\apps\gstreamer\bin;%Disk%:\IDE\MinGW\bin;%Disk%:\commands\tools;
set PKG_CONFIG_PATH=%Disk%:\apps\gstreamer\lib\pkgconfig;%PKG_CONFIG_PATH%
REM set PYTHONPATH=%Disk%:\commands\tools\kivy;
set kivy_paths_initialized=1
REM  設定 QT 相關, path 必須加上 %Disk%:\IDE\Python34\Lib\site-packages\PyQt4;
set QT_QPA_PLATFORM_PLUGIN_PATH=%Disk%:\IDE\Python34\Lib\site-packages\PyQ4\plugins\platforms"
REM 其他路徑設定
set path1=%PATH%;%Disk%:\IDE\Python34;%Disk%:\IDE\Python34\Scripts;%Disk%:\apps\gnuplot\binary;
set path2=%Disk%:\IDE\Python34\Lib\site-packages\pywin32_system32;%Disk%:\IDE\Lua;%Disk%:\IDE\Lua\clibs;
set path3=%Netbeans%:\C\MinGW\bin;%Netbeans%:\C\MinGW\msys\1.0\bin;%Disk%:\IDE\php-5.5.9-nts-Win32-VC11-x86;
REM for Yii and git
set path4=%Disk%:\www\yii-1.1.14\framework;%Disk%:\apps\Git\bin;%Disk%:\apps\dot\bin;
REM for LibreOfficePortable
set path5=%Disk%:\apps\LibreOfficePortable\App\libreoffice\program;%Disk%:\IDE\nodejs;%Disk%:\apps\pandoc;
set path6=%Disk%:\apps\GoogleChromePortable;%Disk%:\apps\portableLatex\MiKTeX\texmf\miktex\bin;%Disk%:\IDE\Python34\Lib\site-packages\PyQt4;
path=%path7%;%path1%;%path2%;%path3%;%path4%;%path5%;%path6%;
REM 使用隱藏指令畫面的方式啟動 nginx www 伺服器
REM 若要啟動 nginx 啟動以下五行
REM cd wwwServers
REM cd nginx-1.2.3
REM start /MIN nginx.exe -c %Disk%:\wwwServers\nginx-1.2.3\conf\nginx.conf
REM start %Disk%:\commands\9000.vbs
REM start %Disk%:\commands\9002.vbs
start /MIN %Disk%:\IDE\SciTE\SciTE.exe
cd ..
cd ..
REM 啟動 mysql
start %Disk%:\apps\mysql\bin\mysqld1.exe
start /MIN cmd.exe
REM 啟動 node.js
REM start %Disk%:\IDE\nodejs\node.exe
REM C:\WINDOWS\system32\cmd.exe /k %Disk%:\IDE\nodejs\nodejsvars.bat
REM 啟動 Leo 編輯器
%Disk%:\IDE\Python34\python.exe %Disk%:\commands\launchLeo.py
Exit
