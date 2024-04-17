@echo off
setlocal EnableDelayedExpansion

rem Constants
set "CUR_DIR=%~dp0"
set "HUGO_CACHE_DIR=%USERPROFILE%\.cache"

set "FIXIT_VER=0.3.2"
set "FIXIT_PATH=%CUR_DIR%\.cache\FixIt"

set "HUGO_VER=0.125.0"
set "HUGO_PATH=%CUR_DIR%\.cache\hugo.exe"

set "HUGO_SOURCE=%CUR_DIR%\mysite"

goto __main__

rem Function to check status
:go_status
if %1 equ 0 ( echo okay ) else ( echo failed )
exit /b

rem Function for usage instructions
:go_usage
echo Usage: %0 [options]
echo Options:
echo   --install_hugo    Install the hugo extended deb
echo   --install_fixit   Install the hugo theme - FixIt
echo   --run             Run the hugo blog
echo   --help, -h        Show this help message
exit /b

rem Function to install hugo
:go_install_hugo
    for %%I in (%HUGO_PATH%) do set "HUGO_DIR=%%~dpI"

    if exist %HUGO_PATH% (
        set /p "choice=Hugo is already installed. Do you want to force reinstall? (y/n): "
        if /i "!choice!" equ "y" (
            set "FORCE_INSTALL=true"
        ) else if /i "!choice!" equ "n" (
            exit /b
        ) else (
            echo Invalid choice. Exiting.
            exit /b 1
        )
    )

    set "LATEST_URL=https://github.com/gohugoio/hugo/releases/download/v%HUGO_VER%/hugo_extended_%HUGO_VER%_windows-amd64.zip"
    for %%I in (%LATEST_URL%) do set "ARCHIVE_FILE=%HUGO_CACHE_DIR%\%%~nxI"

    if not exist %ARCHIVE_FILE% (
        echo Downloading Hugo exe:
        curl.exe -o "%ARCHIVE_FILE%" -L "%LATEST_URL%" --silent
        call :go_status %errorlevel%
    )

    echo Install Hugo exe:
    powershell Expand-Archive -Path "%ARCHIVE_FILE%" -DestinationPath "%HUGO_CACHE_DIR%" -Force >nul
    mkdir %HUGO_DIR%
    copy  %HUGO_CACHE_DIR%\hugo.exe %HUGO_PATH%
exit /b

rem Function to install fixit
:go_install_fixit
    for %%I in (%FIXIT_PATH%) do set "FIXIT_DIR=%%~dpI"

    if exist %FIXIT_PATH% (
        set /p "choice=FixIt is already installed. Do you want to force reinstall? (y/n): "
        if /i "!choice!" equ "y" (
            set "FORCE_INSTALL=true"
        ) else if /i "!choice!" equ "n" (
            exit /b
        ) else (
            echo Invalid choice. Exiting.
            exit /b 1
        )
    )

    set "LATEST_URL=https://github.com/hugo-fixit/FixIt/archive/refs/tags/v%FIXIT_VER%.zip"
    for %%I in (%LATEST_URL%) do set "ARCHIVE_FILE=%HUGO_CACHE_DIR%\%%~nxI"

    if not exist %ARCHIVE_FILE% (
        echo Downloading Hugo theme - FixIt:
        curl.exe -o "%ARCHIVE_FILE%" -L "%LATEST_URL%" --silent
        call :go_status %errorlevel%
    )

    echo Uncompress Hugo theme - FixIt:
    powershell Expand-Archive -Path "%ARCHIVE_FILE%" -DestinationPath "%HUGO_CACHE_DIR%" -Force >nul
    call :go_status %errorlevel%

    rmdir /s /q "%FIXIT_PATH%"
    mkdir "%FIXIT_DIR%"
    mklink /d "%FIXIT_PATH%" "%HUGO_CACHE_DIR%\FixIt-%FIXIT_VER%"
exit /b

rem Function to run hugo server
:go_run_hugo
    for %%I in (%FIXIT_PATH%) do set "FIXIT_DIR=%%~dpI"

    rmdir /s /q "%HUGO_SOURCE%\public"

    %HUGO_PATH% server -D --source %HUGO_SOURCE% --themesDir %FIXIT_DIR% --bind 127.0.0.1 --port 1313
exit /b

rem Main function
:__main__
if "%~1" equ "--install_hugo" (
    call :go_install_hugo
) else if "%~1" equ "--install_fixit" (
    call :go_install_fixit
) else if "%~1" equ "--run" (
    call :go_run_hugo
) else if "%~1" equ "--help" (
    call :go_usage
) else if "%~1" equ "-h" (
    call :go_usage
) else (
    echo Unknown option: %~1
    call :go_usage
    exit /b 1
)
exit /b
