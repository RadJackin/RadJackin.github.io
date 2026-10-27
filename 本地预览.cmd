@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 本地预览 - 写文章时用这个
set "NODE_EXE=%USERPROFILE%\.dsh\dsh-runtimes\dsh-next-primary-runtime\dependencies\node\bin\node.exe"

echo.
echo  ============================================
echo   正在启动本地预览...
echo   浏览器打开 http://localhost:4321
echo   改文章会自动刷新；按 Ctrl+C 停止
echo  ============================================
echo.

if not exist "%NODE_EXE%" (
  echo  [!] 没找到内置 Node，改用系统 node
  node node_modules\astro\astro.js dev
) else (
  "%NODE_EXE%" node_modules\astro\astro.js dev
)

echo.
echo  预览已停止。
pause
