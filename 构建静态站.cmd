@echo off
cd /d "%~dp0"
title Build static site
set "NODE_EXE=%USERPROFILE%\.dsh\dsh-runtimes\dsh-next-primary-runtime\dependencies\node\bin\node.exe"

REM Supports Astro 5 (astro.js) and Astro 6+ (bin\astro.mjs)
set "ASTRO_CLI=node_modules\astro\astro.js"
if not exist "%ASTRO_CLI%" set "ASTRO_CLI=node_modules\astro\bin\astro.mjs"

echo.
echo  Building static files into .\dist ...
echo.

if exist "%NODE_EXE%" (
  "%NODE_EXE%" "%ASTRO_CLI%" build
) else (
  echo  [!] built-in Node not found, falling back to system node
  node "%ASTRO_CLI%" build
)

echo.
echo  Done. The ready-to-upload files are in the dist folder.
echo  Drag the whole dist folder to Vercel / Cloudflare Pages if you like.
pause
