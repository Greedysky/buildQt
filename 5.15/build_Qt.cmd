@echo off
setlocal EnableExtensions

if "%~1"=="" goto :usage
if "%~2"=="" goto :usage
if "%~3"=="" goto :usage

set "LINK_MODE=%~1"
set "FLAVOR=%~2"
set "ARCHITECTURE=%~3"

if /i not "%LINK_MODE%"=="shared" if /i not "%LINK_MODE%"=="static" goto :usage
if /i not "%FLAVOR%"=="full" if /i not "%FLAVOR%"=="rp" goto :usage
if /i not "%ARCHITECTURE%"=="x86" if /i not "%ARCHITECTURE%"=="x64" goto :usage

set "QT_VERSION=5.15.19"
set "FLAVOR_SUFFIX="
if /i "%FLAVOR%"=="rp" set "FLAVOR_SUFFIX=_RP"
set "STATIC_RUNTIME="
if /i "%LINK_MODE%"=="static" set "STATIC_RUNTIME=-static-runtime"

if /i "%ARCHITECTURE%"=="x86" (
    set "MINGW_DIR=mingw810_32"
) else (
    set "MINGW_DIR=mingw810_64"
)
set "MinGW_VERSION=%MINGW_DIR%%FLAVOR_SUFFIX%"
set "MINGW_BIN=D:\a\buildQt\Tools\%MINGW_DIR%\bin"

set "PATH=%MINGW_BIN%;D:\a\buildQt\Strawberry\c\bin;D:\a\buildQt\Strawberry\perl\site\bin;D:\a\buildQt\Strawberry\perl\bin;%PATH%"
set "CC=%MINGW_BIN%\gcc.exe"
set "CXX=%MINGW_BIN%\g++.exe"
set "QT_PATH=D:\a\buildQt\Qt"
set "SRC_ROOT=%QT_PATH%\%QT_VERSION%"
set "INSTALL_DIR=%QT_PATH%\%QT_VERSION%-%LINK_MODE%\%MinGW_VERSION%"
set "BUILD_DIR=%QT_PATH%\%QT_VERSION%\build-%MinGW_VERSION%"
set "NUM_THRED=%NUMBER_OF_PROCESSORS%"

if exist "%BUILD_DIR%\nul" rmdir /s /q "%BUILD_DIR%" || exit /b 1
mkdir "%BUILD_DIR%" || exit /b 1
cd /d "%BUILD_DIR%" || exit /b 1

if /i "%FLAVOR%"=="rp" goto :build_rp

set "SRC_QT=%SRC_ROOT%\qt-everywhere-src-%QT_VERSION%"
set "PATH=%SRC_QT%\qtbase\bin;%SRC_QT%\gnuwin32\bin;%PATH%"
call "%SRC_QT%\configure.bat" -%LINK_MODE% %STATIC_RUNTIME% -release -prefix "%INSTALL_DIR%" -nomake examples -nomake tests -skip qtwebengine -opensource -confirm-license -qt-libpng -qt-libjpeg -qt-zlib -qt-pcre -qt-freetype -schannel -opengl desktop -platform win32-g++ || exit /b 1
mingw32-make -j%NUM_THRED% || exit /b 1
mingw32-make install || exit /b 1
goto :install_config

:build_rp
set "QMAKE_PATH=%INSTALL_DIR%\bin\qmake.exe"
mkdir build-qtbase || exit /b 1
cd build-qtbase || exit /b 1
call "%SRC_ROOT%\qtbase-everywhere-src-%QT_VERSION%\configure.bat" -%LINK_MODE% %STATIC_RUNTIME% -release -nomake examples -prefix "%INSTALL_DIR%" -opensource -confirm-license -qt-libpng -qt-libjpeg -qt-zlib -qt-pcre -qt-freetype -schannel -recheck-all -opengl desktop -platform win32-g++ || exit /b 1
mingw32-make -j%NUM_THRED% || exit /b 1
mingw32-make install || exit /b 1
cd .. || exit /b 1

call :build_qt5_module qttools || exit /b 1
call :build_qt5_module qttranslations || exit /b 1
call :build_qt5_module qtsvg || exit /b 1
goto :install_config

:build_qt5_module
set "MODULE=%~1"
mkdir "build-%MODULE%" || exit /b 1
cd "build-%MODULE%" || exit /b 1
"%QMAKE_PATH%" "%SRC_ROOT%\%MODULE%-everywhere-src-%QT_VERSION%\%MODULE%.pro" || exit /b 1
mingw32-make -j%NUM_THRED% || exit /b 1
mingw32-make install || exit /b 1
cd .. || exit /b 1
exit /b 0

:install_config
copy /Y "%~dp0..\qt.conf" "%INSTALL_DIR%\bin" || exit /b 1
endlocal
exit /b 0

:usage
echo Usage: %~nx0 shared^|static full^|rp x86^|x64
exit /b 1
