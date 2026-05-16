@echo off
setlocal enabledelayedexpansion

set "REPO=cielthephantom2/Shapeofdream"
set "BRANCH=main"
set "ZIP_URL=https://github.com/cielthephantom2/Shapeofdream/archive/refs/heads/%BRANCH%.zip"
set "API_URL=https://api.github.com/repos/%REPO%/commits/%BRANCH%"

:: TARGET_DIR tự động lấy đường dẫn của thư mục đang chứa file .bat này
set "TARGET_DIR=%~dp0"
set "GAME_EXE=Shape of Dreams.exe"
set "VERSION_FILE=%TARGET_DIR%.modversion"

set "TEMP_ZIP=%TEMP%\Shapeofdream.zip"
set "TEMP_EXTRACT=%TEMP%\Shapeofdream_extract"

echo Checking for Mod updates on GitHub...

for /f "delims=" %%I in ('powershell -Command "(Invoke-RestMethod -Uri '%API_URL%' -Headers @{'User-Agent'='ModUpdater'}).sha" 2^>nul') do set "LATEST_SHA=%%I"

if "%LATEST_SHA%"=="" (
    echo [Warning] Cannot check for updates. Please check your internet connection.
    goto :RunGame
)

set "LOCAL_SHA="
if exist "%VERSION_FILE%" (
    set /p LOCAL_SHA=<"%VERSION_FILE%"
)

if "%LATEST_SHA%"=="%LOCAL_SHA%" (
    echo [OK] The current Mod is up to date. Skipping download!
    goto :RunGame
)

echo [!] New Mod version detected! Downloading...
powershell -Command "Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile '%TEMP_ZIP%'"

echo [!] Extracting files...
if exist "%TEMP_EXTRACT%" rmdir /s /q "%TEMP_EXTRACT%"
powershell -Command "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%TEMP_EXTRACT%' -Force"

echo [!] Installing files to the current folder...
:: Copy thẳng toàn bộ nội dung đã giải nén vào thư mục chứa file bat
xcopy /E /Y /I "%TEMP_EXTRACT%\Shapeofdream-%BRANCH%\*" "%TARGET_DIR%"

echo [!] Cleaning up temporary files...
del /q "%TEMP_ZIP%"
rmdir /s /q "%TEMP_EXTRACT%"

echo %LATEST_SHA%> "%VERSION_FILE%"
echo [OK] Mod/Files updated successfully!

:RunGame
echo.
echo Starting Shape of Dreams...
:: Thêm %TARGET_DIR% trước tên file exe để đảm bảo luôn trỏ đúng đường dẫn
if exist "%TARGET_DIR%%GAME_EXE%" (
    start "" "%TARGET_DIR%%GAME_EXE%"
) else (
    echo [Error] Cannot find "%GAME_EXE%". Is this .bat file in the same folder as the game?
    pause
)