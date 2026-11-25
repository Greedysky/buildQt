@echo off
setlocal EnableExtensions

call :main %*
exit /b

:main
if "%~1"=="" goto :usage
if "%~2"=="" goto :usage
if /i not "%~3"=="x64" goto :usage

set "LINK_MODE=%~1"
set "FLAVOR=%~2"
if /i not "%LINK_MODE%"=="shared" if /i not "%LINK_MODE%"=="static" goto :usage
if /i not "%FLAVOR%"=="full" if /i not "%FLAVOR%"=="rp" goto :usage

set "QT_VERSION=6.8.5"
set "MinGW_VERSION=mingw1310_64"
set "FLAVOR_SUFFIX="
if /i "%FLAVOR%"=="rp" set "FLAVOR_SUFFIX=_RP"
set "MinGW_VERSION=%MinGW_VERSION%%FLAVOR_SUFFIX%"
set "STATIC_RUNTIME="
if /i "%LINK_MODE%"=="static" set "STATIC_RUNTIME=-static-runtime"

set "PATH=D:\a\buildQt\Tools\%MinGW_VERSION%\bin;D:\a\buildQt\ninja;D:\a\buildQt\Strawberry\c\bin;D:\a\buildQt\Strawberry\perl\site\bin;D:\a\buildQt\Strawberry\perl\bin;%PATH%"
set "QT_PATH=D:\a\buildQt\Qt"
set "SRC_ROOT=%QT_PATH%\%QT_VERSION%"
set "INSTALL_DIR=%QT_PATH%\%QT_VERSION%-%LINK_MODE%\%MinGW_VERSION%"
set "BUILD_DIR=%QT_PATH%\%QT_VERSION%\build-%MinGW_VERSION%"

if exist "%BUILD_DIR%\nul" rmdir /s /q "%BUILD_DIR%" || exit /b 1
mkdir "%BUILD_DIR%" || exit /b 1
cd /d "%BUILD_DIR%" || exit /b 1

if /i "%FLAVOR%"=="rp" goto :build_rp

set "SRC_QT=%SRC_ROOT%\qt-everywhere-src-%QT_VERSION%"
call "%SRC_QT%\configure.bat" -%LINK_MODE% %STATIC_RUNTIME% -release -prefix "%INSTALL_DIR%" -nomake examples -nomake tests -skip qtwebengine -opensource -confirm-license -qt-libpng -qt-libjpeg -qt-zlib -qt-pcre -qt-freetype -qt-harfbuzz -qt-webp -qt-tiff -schannel -opengl desktop -platform win32-g++ || exit /b 1
cmake --build . --parallel || exit /b 1
ninja install || exit /b 1
goto :install_config

:build_rp
mkdir build-qtbase || exit /b 1
cd build-qtbase || exit /b 1
call "%SRC_ROOT%\qtbase-everywhere-src-%QT_VERSION%\configure.bat" -%LINK_MODE% %STATIC_RUNTIME% -release -nomake examples -prefix "%INSTALL_DIR%" -opensource -confirm-license -qt-libpng -qt-libjpeg -qt-zlib -qt-pcre -qt-freetype -schannel -opengl desktop -platform win32-g++ || exit /b 1
cmake --build . --parallel || exit /b 1
ninja install || exit /b 1
cd .. || exit /b 1

call :build_qt6_module qttools || exit /b 1
call :build_qt6_module qttranslations || exit /b 1
call :build_qt6_module qtsvg || exit /b 1
goto :install_config

:build_qt6_module
set "MODULE=%~1"
mkdir "build-%MODULE%" || exit /b 1
cd "build-%MODULE%" || exit /b 1
cmake "%SRC_ROOT%\%MODULE%-everywhere-src-%QT_VERSION%" -G "Ninja" -DCMAKE_INSTALL_PREFIX="%INSTALL_DIR%" -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="%INSTALL_DIR%" || exit /b 1
cmake --build . --parallel || exit /b 1
ninja install || exit /b 1
cd .. || exit /b 1
exit /b 0

:install_config
copy /Y "%~dp0..\qt.conf" "%INSTALL_DIR%\bin" || exit /b 1
exit /b 0

:usage
echo Usage: %~nx0 shared^|static full^|rp x64
exit /b 1
