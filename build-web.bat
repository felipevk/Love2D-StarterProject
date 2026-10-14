@echo off
set "gameName=%~2"
if not defined gameName set "gameName=%~n1"
set buildFolder=bin\%gameName%-web
set tempFolder=bin\temp

if "%~1"=="" (
	echo This script requires a valid folder name
	goto :eof
)
if not exist %1\ (
	echo This script requires a valid folder name
	goto :eof
)
if not exist %1\main.lua (
	echo Missing %1\main.lua
	goto :eof
)
if not exist bin\ (
	mkdir bin
)
if exist %buildFolder%\ (
	rmdir /s /q %buildFolder%
)
mkdir %buildFolder%

if not exist %tempFolder% (
	mkdir %tempFolder%
)

:: zip project files and change extension to .love
cd %1\
7z.exe a -r "..\%tempFolder%\%~n1.zip" 
cd ../
ren %tempFolder%\%~n1.zip %gameName%.love 

call love.js.cmd %tempFolder%\%gameName%.love %buildFolder% -c -m 67108864 -t %gameName%

rmdir /s /q "%tempFolder%"

:eof
exit /b 0