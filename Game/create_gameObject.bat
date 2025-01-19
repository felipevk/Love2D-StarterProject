@echo off
:: Check if the filename is provided
if "%~1"=="" (
    echo Usage: %~nx0 filename
    exit /b
)

:: Set the filename with a .lua extension
set "filename=%~1.lua"

:: Check if the file already exists
if exist "%filename%" (
    echo File "%filename%" already exists.
    exit /b
)

:: Write the Lua template to the file
:: Had to output each line one by one because using the echo block with variables wasn't working
echo local %~1 = GameObject:extend()>> "objects\%filename%"
echo.>> "objects\%filename%"
echo function %~1:new(area, x, y, opts)>> "objects\%filename%"
echo     %~1.super.new(self, area, x, y, opts)>> "objects\%filename%"
echo end>> "objects\%filename%"
echo.>> "objects\%filename%"
echo function %~1:update(dt)>> "objects\%filename%"
echo     %~1.super.update(self, dt)>> "objects\%filename%"
echo end >> "objects\%filename%"
echo.>> "objects\%filename%"
echo function %~1:draw()>> "objects\%filename%"
echo.>> "objects\%filename%"
echo end>> "objects\%filename%"
echo.>> "objects\%filename%"
echo function %~1:destroy()>> "objects\%filename%"
echo    %~1.super.destroy(self)>> "objects\%filename%"
echo end>> "objects\%filename%"
echo.>> "objects\%filename%"
echo return %~1>> "objects\%filename%"

echo File "%filename%" has been created.