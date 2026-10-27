@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
title Publish to GitHub Pages

echo.
echo  ==================================================
echo    Publish this blog to GitHub Pages
echo    First run : login to GitHub (one time)
echo    Later runs: build + commit + push
echo  ==================================================
echo.

where gh >nul 2>nul
if errorlevel 1 (
  echo  [!] GitHub CLI ^(gh^) not found.
  echo      Install it in PowerShell:  winget install GitHub.cli
  pause
  exit /b 1
)

gh auth status >nul 2>nul
if errorlevel 1 (
  echo  Login to GitHub ^(one time only^).
  echo  Copy the 8-character code shown here and paste it in the browser.
  echo.
  gh auth login --hostname github.com --git-protocol https --web
  if errorlevel 1 (
    echo  [!] Login failed, please try again.
    pause
    exit /b 1
  )
)

for /f "delims=" %%i in ('gh api user --jq .login 2^>nul') do set "GHUSER=%%i"
for /f "delims=" %%i in ('gh api user --jq .name 2^>nul') do set "GHNAME=%%i"
for /f "delims=" %%i in ('gh api user --jq .email 2^>nul') do set "GHEMAIL=%%i"

if "!GHUSER!"=="" (
  echo  [!] Cannot read your GitHub username. Please run again after login.
  pause
  exit /b 1
)
if "!GHNAME!"=="" set "GHNAME=!GHUSER!"
if "!GHEMAIL!"=="" set "GHEMAIL=!GHUSER!@users.noreply.github.com"

echo  Logged in as: !GHUSER!
echo.

set "REPO="
set "REMOTE="
if exist ".git" (
  for /f "delims=" %%i in ('git remote get-url origin 2^>nul') do set "REMOTE=%%i"
)
if defined REMOTE (
  for /f "delims=" %%i in ('gh repo view --json name -q .name 2^>nul') do set "REPO=%%i"
)
if defined REPO if not "!REPO!"=="" goto :repo_ready

set /p "REPO=Repo name ^(press Enter for !GHUSER!.github.io^): "
if "!REPO!"=="" set "REPO=!GHUSER!.github.io"

:repo_ready
set "SITEURL=https://!GHUSER!.github.io/"
if /i not "!REPO!"=="!GHUSER!.github.io" set "SITEURL=https://!GHUSER!.github.io/!REPO!/"
echo  Site URL: !SITEURL!
echo.

set "SITE_URL=!SITEURL!"
git config user.name "!GHNAME!"
git config user.email "!GHEMAIL!"
git config --local http.sslVerify false

if not exist ".git" git init -b main >nul

set "NODE_EXE=%USERPROFILE%\.dsh\dsh-runtimes\dsh-next-primary-runtime\dependencies\node\bin\node.exe"
set "ASTRO_CLI=node_modules\astro\astro.js"
if not exist "%ASTRO_CLI%" set "ASTRO_CLI=node_modules\astro\bin\astro.mjs"

echo  [1/3] Building ...
if exist "%NODE_EXE%" (
  "%NODE_EXE%" "%ASTRO_CLI%" build
) else (
  node "%ASTRO_CLI%" build
)
if errorlevel 1 (
  echo  [!] Build failed. Scroll up to see the error.
  pause
  exit /b 1
)

echo  [2/3] Copying dist to docs ...
robocopy dist docs /MIR /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 (
  echo  [!] Copy failed.
  pause
  exit /b 1
)
if exist "docs\.gitkeep" del "docs\.gitkeep"

echo  [3/3] Commit and push ...
git add -A
git commit -m "Publish %date% %time%" >nul 2>nul
if errorlevel 1 echo  (no content changes)

gh repo view "!GHUSER!/!REPO!" >nul 2>nul
if errorlevel 1 (
  echo  Creating repo !GHUSER!/!REPO! ...
  gh repo create "!REPO!" --public --source=. --remote=origin
  if errorlevel 1 (
    echo  [!] Failed to create the repo. Network issue, or the name is taken.
    pause
    exit /b 1
  )
)

git remote remove origin >nul 2>nul
git remote add origin "https://github.com/!GHUSER!/!REPO!.git"
git push -u origin main
if errorlevel 1 (
  echo  [!] Push failed. Check your network and run again.
  pause
  exit /b 1
)

echo.
echo  ==================================================
echo   Published! Open in 1-2 minutes:
echo.
echo     !SITEURL!
echo.
echo   Repo: https://github.com/!GHUSER!/!REPO!
echo  ==================================================
echo.
echo  Tip: next time you publish, just double-click this file again.
echo.
pause
