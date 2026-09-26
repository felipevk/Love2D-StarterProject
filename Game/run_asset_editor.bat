@echo off
start "" "..\love-11.5-win64\love.exe" . --editor assets

if errorlevel 1 (
    echo Failed to launch Love2D.
    pause
)