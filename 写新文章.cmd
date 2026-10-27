@echo off
cd /d "%~dp0"
title New post
echo.
echo  ==========================================
echo   Opening the posts folder ...
echo   Create a new .md file, then copy the
echo   template from the templates folder.
echo  ==========================================
echo.
start "" "%~dp0src\content\posts"
timeout /t 1 >nul
start "" "%~dp0templates"
echo  Steps:
echo   1. Copy templates\?????.md  (Chinese name, sorry - it is the template)
echo   2. Paste into src\content\posts\ as 2026-11-01-my-post.md
echo   3. Edit title / description / date / tags and write the body
echo   4. Double-click ????.cmd to go live
echo.
pause
