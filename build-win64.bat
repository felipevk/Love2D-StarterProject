@echo off
set loveVer=11.5
set loveFolder=love-%loveVer%-win64
set buildFolder=bin\%~n1-win64

if not exist %loveFolder%\ (
	echo This script requires love version %loveVer%
	goto :eof
)
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

:: copy lua dlls and license
xcopy %loveFolder%\license.txt %buildFolder%
for %%I in (%loveFolder%\*.dll) do (
	xcopy %%I %buildFolder%
)

:: zip project files and change extension to .love
cd %1\
7z.exe a -r "..\%buildFolder%\%~n1.zip" 
cd ../
ren %buildFolder%\%~n1.zip %~n1.love 

:: combine love.exe with .love file to final game exe
copy /b %loveFolder%\love.exe+%buildFolder%\%~n1.love "%buildFolder%\%~n1.exe"
del %buildFolder%\%~n1.love

:eof
pause