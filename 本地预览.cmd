@echo off
cd /d "%~dp0"
title Local preview - your-blog
set "NODE_EXE=%USERPROFILE%\.dsh\dsh-runtimes\dsh-next-primary-runtime\dependencies\node\bin\node.exe"

REM Supports Astro 5 (astro.js) and Astro 6+ (bin\astro.mjs)
set "ASTRO_CLI=node_modules\astro\astro.js"
if not exist "%ASTRO_CLI%" set "ASTRO_CLI=node_modules\astro\bin\astro.mjs"

echo.
echo  ==========================================
echo   Starting local preview ...
echo   Open in browser:  http://localhost:4321
echo   Files reload automatically. Ctrl+C to stop.
echo  ==========================================
echo.

if exist "%NODE_EXE%" (
  "%NODE_EXE%" "%ASTRO_CLI%" dev
) else (
  echo  [!] built-in Node not found, falling back to system node
  node "%ASTRO_CLI%" dev
)

echo.
echo  Preview stopped.
pause
