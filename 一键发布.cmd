@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"
title 一键发布到 GitHub Pages

echo.
echo  ==================================================
echo    一键发布到 GitHub Pages
echo    第一次：引导你登录 GitHub（只需一次）
echo    之后  ：自动提交 ^+ 推送 ^+ 重新部署
echo  ==================================================
echo.

where gh >nul 2>nul
if errorlevel 1 (
  echo  [!] 没找到 GitHub CLI。
  echo      请先在 PowerShell 里运行： winget install GitHub.cli
  echo      装完重新打开这个窗口再双击本脚本。
  pause
  exit /b 1
)

gh auth status >nul 2>nul
if errorlevel 1 (
  echo  需要先登录 GitHub（只需一次）。
  echo  接下来会打开浏览器，把终端里显示的 8 位代码粘贴进去即可。
  echo.
  gh auth login --hostname github.com --git-protocol https --web
  if errorlevel 1 (
    echo  [!] 登录失败，请重试。
    pause
    exit /b 1
  )
)

for /f "delims=" %%i in ('gh api user --jq .login 2^>nul') do set "GHUSER=%%i"
for /f "delims=" %%i in ('gh api user --jq .name 2^>nul') do set "GHNAME=%%i"
for /f "delims=" %%i in ('gh api user --jq .email 2^>nul') do set "GHEMAIL=%%i"

if "!GHUSER!"=="" (
  echo  [!] 读不到 GitHub 用户名，请重新运行并确认登录成功。
  pause
  exit /b 1
)
if "!GHNAME!"=="" set "GHNAME=!GHUSER!"
if "!GHEMAIL!"=="" set "GHEMAIL=!GHUSER!@users.noreply.github.com"

echo  已登录：!GHUSER!
echo.

set "REPO="
set "REMOTE="
if exist ".git" (
  for /f "delims=" %%i in ('git remote get-url origin 2^>nul') do set "REMOTE=%%i"
)
if defined REMOTE (
  for /f "delims=" %%i in ('gh repo view --json name -q .name 2^>nul') do set "REPO=%%i"
)

if not defined REPO (
  set /p "REPO=仓库名（直接回车用 !GHUSER!.github.io）："
  if "!REPO!"=="" set "REPO=!GHUSER!.github.io"
)

if /i not "!REPO!"=="!GHUSER!.github.io" (
  echo.
  echo  [!] 提醒：仓库名不是 !GHUSER!.github.io，
  echo      博客会挂在 https://!GHUSER!.github.io/!REPO!/ 子路径下，
  echo      站内链接需要额外配置。想零配置，建议用默认名。
  echo.
)

set "SITEURL=https://!GHUSER!.github.io"
if /i not "!REPO!"=="!GHUSER!.github.io" set "SITEURL=https://!GHUSER!.github.io/!REPO!"

echo  站点地址：!SITEURL!
echo.

git config user.name "!GHNAME!"
git config user.email "!GHEMAIL!"

if not exist ".git" (
  git init -b main >nul
)

git add -A
git commit -m "更新博客：%date% %time%" >nul 2>nul
if errorlevel 1 echo  （没有新的改动，继续部署）

gh repo view "!GHUSER!/!REPO!" >nul 2>nul
if errorlevel 1 (
  echo  正在创建仓库 !GHUSER!/!REPO! ...
  gh repo create "!REPO!" --public --source=. --remote=origin
  if errorlevel 1 (
    echo  [!] 创建仓库失败。可能是网络问题，或仓库名已被占用。
    pause
    exit /b 1
  )
)

git remote remove origin >nul 2>nul
git remote add origin "https://github.com/!GHUSER!/!REPO!.git"

echo  正在设置站点地址变量 SITE_URL ...
gh variable set SITE_URL --repo "!GHUSER!/!REPO!" --body "!SITEURL!" >nul 2>nul

echo  正在开启 GitHub Pages（Actions 构建）...
gh api -X POST "repos/!GHUSER!/!REPO!/pages" -f build_type=workflow >nul 2>nul
if errorlevel 1 (
  gh api -X PUT "repos/!GHUSER!/!REPO!/pages" -f build_type=workflow >nul 2>nul
)

echo  正在推送代码，触发自动构建...
git push -u origin main
if errorlevel 1 (
  echo  [!] 推送失败。请检查网络，或重新运行本脚本。
  pause
  exit /b 1
)

echo.
echo  ==================================================
echo   已推送！GitHub 正在自动构建，约 1～2 分钟后可访问：
echo.
echo     !SITEURL!
echo.
echo   查看构建进度： https://github.com/!GHUSER!/!REPO!/actions
echo  ==================================================
echo.
echo  提示：以后再发新文章，双击本脚本即可，不用再登录。
echo.
pause
