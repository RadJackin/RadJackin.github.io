@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 构建静态站
set "NODE_EXE=%USERPROFILE%\.dsh\dsh-runtimes\dsh-next-primary-runtime\dependencies\node\bin\node.exe"

echo.
echo  正在生成可上线的静态文件（输出到 dist 文件夹）...
echo.

if not exist "%NODE_EXE%" (
  echo  [!] 没找到内置 Node，改用系统 node
  node node_modules\astro\astro.js build
) else (
  "%NODE_EXE%" node_modules\astro\astro.js build
)

echo.
echo  完成。静态文件在 dist 文件夹里，可以整个拖到 Vercel / Cloudflare Pages 发布。
pause
