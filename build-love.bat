@echo off
set "gameName=%~2"
if not defined gameName set "gameName=%~n1"
set buildFolder=bin\%gameName%-love

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


:: zip project files and change extension to .love
cd %1\
7z.exe a -r "..\%buildFolder%\%gameName%.zip" 
cd ../
ren %buildFolder%\%gameName%.zip %gameName%.love 

:eof
exit /b 0