@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
title Publish to GitHub Pages

echo.
echo  ==================================================
echo    Publish this blog to GitHub Pages
echo    First run : login to GitHub (one time)
echo    Later runs: commit + push + auto deploy
echo  ==================================================
echo.

where gh >nul 2>nul
if errorlevel 1 (
  echo  [!] GitHub CLI ^(gh^) not found.
  echo      Install it in PowerShell:  winget install GitHub.cli
  echo      Then reopen this window and run this script again.
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
if /i not "!REPO!"=="!GHUSER!.github.io" (
  echo.
  echo  [!] Note: the repo name is not !GHUSER!.github.io,
  echo      so the blog will live under the /!REPO!/ sub-path
  echo      and internal links need extra config.
  echo.
)

set "SITEURL=https://!GHUSER!.github.io"
if /i not "!REPO!"=="!GHUSER!.github.io" set "SITEURL=https://!GHUSER!.github.io/!REPO!"

echo  Site URL: !SITEURL!
echo.

git config user.name "!GHNAME!"
git config user.email "!GHEMAIL!"

if not exist ".git" (
  git init -b main >nul
)

git add -A
git commit -m "Update blog %date% %time%" >nul 2>nul
if errorlevel 1 echo  (no new changes, continue)

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

echo  Setting SITE_URL variable ...
gh variable set SITE_URL --repo "!GHUSER!/!REPO!" --body "!SITEURL!" >nul 2>nul

echo  Enabling GitHub Pages ^(GitHub Actions build^) ...
gh api -X POST "repos/!GHUSER!/!REPO!/pages" -f build_type=workflow >nul 2>nul
if errorlevel 1 (
  gh api -X PUT "repos/!GHUSER!/!REPO!/pages" -f build_type=workflow >nul 2>nul
)

echo  Pushing code, this triggers the build ...
git push -u origin main
if errorlevel 1 (
  echo  [!] Push failed. Check your network and run again.
  pause
  exit /b 1
)

echo.
echo  ==================================================
echo   Pushed! GitHub is building now.
echo   Wait 1-2 minutes, then open:
echo.
echo     !SITEURL!
echo.
echo   Build progress:
echo     https://github.com/!GHUSER!/!REPO!/actions
echo  ==================================================
echo.
echo  Tip: next time you publish, just double-click this file again.
echo.
pause
