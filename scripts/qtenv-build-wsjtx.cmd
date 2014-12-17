::-----------------------------------------------------------------------------::
:: Name .........: qtenv-build-wsjtx.cmd
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Build script for WSJTX
:: Project URL ..: http://sourceforge.net/projects/wsjt/
:: Usage ........: This file is run from within qtenv.cmd
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: qtenv-build-wsjtx.cmd is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: qtenv-build-wsjtx.cmd is distributed in the hope that it will be useful, but WITHOUT
:: ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
:: FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
:: details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-----------------------------------------------------------------------------::

:: ENVIRONMENT
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
SET LANG=en_US
COLOR 0B

:: TEST DOUBLE CLICK, if YES, GOTO ERROR MESSAGE
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI CALL GOTO DOUBLE_CLICK_ERROR

:: PATH VARIABLES
SET based=C:\JTSDK
SET cmk=%based%\cmake\bin
SET tools=%based%\tools\bin
SET hl3=%based%\hamlib3\bin
SET fft=%based%\fftw3f
SET nsi=%based%\nsis
SET gccd=%based%\qt5\Tools\mingw48_32\bin
SET qt5d=%based%\qt5\5.2.1\mingw48_32\bin
SET qt5a=%based%\qt5\5.2.1\mingw48_32\plugins\accessible
SET at5p=%based%\qt5\5.2.1\mingw48_32\plugins\platforms
SET scr=%based%\scripts
SET srcd=%based%\src
SET svnd=%based%\subversion\bin
SET LIBRARY_PATH=""
SET PATH=%based%;%cmk%;%tools%;%hl3%;%hl2%;%fft%;%gccd%;%qt5d%;%qt5a%;%qt5p%;%nsi%;%inno%;%srcd%;%scr%;%svnd%;%WINDIR%;%WINDIR%\System32
CD /D %based%

:: VARIABLES USED IN PROCESS
SET app_name=wsjtx
SET tchain=%scr%\wsjtx-toolchain.cmake
SET buildd=%based%\%app_name%\build
SET installdir=%based%\%app_name%\install
SET packagedir=%based%\%app_name%\package
SET JJ=%NUMBER_OF_PROCESSORS%

:: SET RELEASE, DEBUG, and TARGET BASED ON USER INPUT
IF /I [%1]==[rconfig] (SET option=Release
SET btree=true
) ELSE IF /I [%1]==[rinstall] (SET option=Release
SET binstall=true
) ELSE IF /I [%1]==[wsjtx] (SET option=Release
SET binstall=true
) ELSE IF /I [%1]==[package] (SET option=Release
SET bpkg=true
) ELSE IF /I [%1]==[dconfig] (SET option=Debug
SET btree=true
) ELSE IF /I [%1]==[dinstall] (SET option=Debug
SET binstall=true
) ELSE ( GOTO BADTYPE )

REM ----------------------------------------------------------------------------
REM  START MAIN SCRIPT
REM ----------------------------------------------------------------------------

CLS
CD %based%
IF NOT EXIST %SRCD%\NUL mkdir %SRCD%
IF NOT EXIST %buildd%\%option%\NUL mkdir %buildd%\%option%
IF NOT EXIST %installdir%\%option%\NUL mkdir %installdir%\%option%
IF NOT EXIST %packagedir%\NUL mkdir %packagedir%
ECHO -----------------------------------------------------------------
ECHO  ^( %app_name% ^) CMake Build Script
ECHO -----------------------------------------------------------------
ECHO.
IF NOT EXIST %srcd%\%app_name%\.svn\NUL (
GOTO COMSG
) ELSE (
GOTO SVNASK
)

:: ASK USER UPDATE FROM SVN
:SVNASK
CLS
ECHO Update from SVN Before Building? ^( y/n ^)
SET answer=
ECHO.
SET /P answer=Type Response: %=%
If /I "%answer%"=="N" GOTO BUILD
If /I "%answer%"=="Y" (
GOTO SVNUP
) ELSE (
CLS
ECHO.
ECHO Please Answer With: ^( Y or N ^) & ECHO. & GOTO SVNASK
)

:: UPDATE IF USER SAID YES TO UPDATE
:SVNUP
ECHO.
ECHO Updating %srcd%\%app_name%
ECHO.
CD /D %srcd%\%app_name%
start /wait svn update
ECHO.

REM ----------------------------------------------------------------------------
REM  CONFIGURE BUILD TREE ( btree )
REM ----------------------------------------------------------------------------

:BUILD
IF [%btree%]==[true] (
CLS
CD /D %buildd%\%option%
ECHO -----------------------------------------------------------------
ECHO Configuring %option% Build For: ^( %app_name% ^)
ECHO -----------------------------------------------------------------
ECHO.
cmake -G "MinGW Makefiles" -Wno-dev -D CMAKE_TOOLCHAIN_FILE=%tchain% ^
-D WSJT_INCLUDE_KVASD=ON ^
-D CMAKE_COLOR_MAKEFILE=OFF ^
-D CMAKE_BUILD_TYPE=%option% ^
-D CMAKE_INSTALL_PREFIX=%installdir%/%option% %srcd%/%app_name%
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
ECHO.
ECHO -----------------------------------------------------------------
ECHO Finished %option% Configuration for: ^( %app_name% ^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO BASE BUILD CONFIGURATION
ECHO   Package ............ %app_name%
ECHO   Type ............... %option%
ECHO   Build Directory .... %buildd%\%option%
ECHO   Build Option List .. %buildd%\%option%\CmakeCache.txt
ECHO   Target Directory ... %installdir%\%option%
ECHO.
ECHO LIST ALL BUILD CONFIG OPTIONS
ECHO   cat %buildd%\%option%\CmakeCache.txt ^| less
ECHO   :: Arrow Up / Down to dcroll through the list
ECHO   :: Type ^(H^) for help with search commands
ECHO   :: Type ^(Ctrl+C then Q^) to exit
ECHO.
ECHO TO BUILD INSTALL TARGET
ECHO   cd /d %buildd%\%option%
ECHO   cmake --build . --target install
ECHO.
GOTO EOF

REM ----------------------------------------------------------------------------
REM  BUILD INSTALL TARGET ( binstall )
REM ----------------------------------------------------------------------------
) ELSE IF [%binstall%]==[true] (
CLS
CD /D %buildd%\%option%
ECHO -----------------------------------------------------------------
ECHO Building Install Target For: ^( %app_name% ^)
ECHO -----------------------------------------------------------------
ECHO.
cmake -G "MinGW Makefiles" -Wno-dev -D CMAKE_TOOLCHAIN_FILE=%tchain% ^
-D WSJT_INCLUDE_KVASD=ON ^
-D CMAKE_COLOR_MAKEFILE=OFF ^
-D CMAKE_BUILD_TYPE=%option% ^
-D CMAKE_INSTALL_PREFIX=%installdir%/%option% %srcd%/%app_name%
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
ECHO.
cmake --build . --target install
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )

:: CHECK IF DEBUG 
IF /I [%OPTION%]==[Debug] ( GOTO DEBUG_MAKEBAT ) ELSE ( GOTO FINISH )
GOTO FINISH

REM ----------------------------------------------------------------------------
REM  BUILD INSTALLER ( bpkg )
REM ----------------------------------------------------------------------------
) ELSE IF [%bpkg%]==[true] (
CLS
CD /D %buildd%\%option%
ECHO -----------------------------------------------------------------
ECHO Building RC Win32 Installer For: ^( %app_name% ^)
ECHO -----------------------------------------------------------------
ECHO.
cmake -G "MinGW Makefiles" -Wno-dev -D CMAKE_TOOLCHAIN_FILE=%tchain% ^
-D CMAKE_COLOR_MAKEFILE=OFF ^
-D CMAKE_BUILD_TYPE=%option% ^
-D CMAKE_INSTALL_PREFIX=%installdir%/%option% %srcd%/%app_name%
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
GOTO NSIS_PKG

:: NSIS PACKAGE ( WSJT-X / Win32 ONLY)
:NSIS_PKG
cmake --build . --target package --clean-first
IF ERRORLEVEL 1 ( GOTO NSIS_BUILD_ERROR )
ls -al %buildd%\%option%\*-win32.exe |gawk "{print $8}" >p.k & SET /P wsjtxpkg=<p.k & rm p.k
CD /D %buildd%\%option%
MOVE /Y %wsjtxpkg% %packagedir% > nul
CD /D %based%
GOTO FINISH_PKG

:: DEBUG MAKE BATCH FILE 
:DEBUG_MAKEBAT
ECHO -- Generating Debug Batch File for ^( %app_name% ^ )
ECHO.
ECHO -----------------------------------------------------------------
ECHO Finished Building %option% Install Target For: ^( %app_name% ^)
ECHO -----------------------------------------------------------------
ECHO.
CD /D %installdir%\%option%\bin
IF EXIST %app_name%.bat (DEL /Q %app_name%.bat)
>%app_name%.bat (
ECHO @ECHO OFF
ECHO REM -- Debug Batch File
ECHO REM -- Part of the JTSDK v2.0 Project
ECHO TITLE JTSDK QT Debug Terminal
ECHO SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
ECHO SET PATH=.;.\bin;%fft%;%gccd%;%qt5d%;%qt5a%;%qt5p%;%hl3%;%hl3%\lib
ECHO CALL %app_name%.exe
ECHO ENDLOCAL
ECHO EXIT /B 0
)
GOTO DEBUG_FINISH

:: DISPLAY DEBUG_FINISHED MESSAGE
:DEBUG_FINISH
ECHO BUILD SUMMARY
ECHO   Build Tree Location .. %buildd%\%option%
ECHO   Install Location ..... %installdir%\%option%\bin\%app_name%.bat
ECHO.
ECHO RUNTIME COMMENT:
ECHO  When Running ^( %app_name% ^) Debug versions, please use
ECHO  the provided  ^( %app_name%.bat ^) file as this sets up
ECHO  environment variables and support file paths.
ECHO.
GOTO ASK_DEBUG_RUN

:: ASK USER IF THEY WANT TO RUN THE APP, DEBUG MODE
:ASK_DEBUG_RUN
ECHO.
ECHO Would You Like To Run %app_name% Now? ^( Y/N ^)
ECHO.
SET answer=
SET /P answer=Type Response: %=%
ECHO.
If /I "%answer%"=="Y" ( GOTO RUN_DEBUG )
If /I "%answer%"=="N" ( GOTO EOF
) ELSE (
CLS
ECHO.
ECHO Please Answer With: ^( Y or N ^) & ECHO. & GOTO ASK_DEBUG_RUN
)

:: RUN APP, DEBUG MODE
:RUN_DEBUG
ECHO.
CD /D %installdir%\%option%\bin
ECHO .. Starting: ^( %app_name% ^) in Debug Mode
CALL %app_name%.bat
GOTO EOF

:: FINISHED PACKAGE MESSAGE
:FINISH_PKG
ECHO.
ECHO -----------------------------------------------------------------
ECHO Finished Installer Build For: ^( %app_name% ^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO Installer Name ...... %WSJTXPKG%
ECHO Installer Location .. %packagedir%
ECHO.
ECHO To Install the package, browse to Installer Location, and
ECHO run as you normally do to install Windows applications.
ECHO.
GOTO EOF

:: DISPLAY FINISH MESSAGE
:FINISH
ECHO.
ECHO BUILD SUMMARY
ECHO   Build Tree Location .. %buildd%\%option%
ECHO   Install Location ..... %installdir%\%option%\bin\wsjtx.exe
GOTO ASK_FINISH_RUN

:: ASK USER IF THEY WANT TO RUN THE APP
:ASK_FINISH_RUN
ECHO.
ECHO   Would You Like To Run %app_name% Now? ^( y/n ^)
ECHO.
SET answer=
SET /P answer=Type Response: %=%
ECHO.
If /I "%answer%"=="Y" GOTO RUN_INSTALL
If /I "%answer%"=="N" (
GOTO EOF
) ELSE (
CLS
ECHO.
ECHO   Please Answer With: ^( y or n ^) & ECHO. & GOTO ASK_FINISH_RUN
)

:: RUN APP
:RUN_INSTALL
ECHO.
CD /D %installdir%\%option%\bin
ECHO .. Starting: ^( %app_name% ^) in Release Mode
CALL wsjtx.exe
)
GOTO EOF

REM ----------------------------------------------------------------------------
REM  POST BUILD
REM ----------------------------------------------------------------------------

:: DOUBLE-CLICK ERROR MESSAGE
:DOUBLE_CLICK_ERROR
CLS
@ECHO OFF
ECHO -------------------------------
ECHO       Execution Error
ECHO -------------------------------
ECHO.
ECHO Please Run from JTSDK Enviroment
ECHO.
ECHO          qtenv.cmd
ECHO.
PAUSE
GOTO EOF

:: DISPLAY SRC DIRECTORY WAS NOT FOUND, e.g. NO CHECKOUT FOUND
:COMSG
CLS
ECHO ----------------------------------------
ECHO  %srcd%\%app_name% Not Found
ECHO ----------------------------------------
ECHO.
ECHO  In order to build ^( %app_name% ^) you
ECHO  must first perform a checkout from 
ECHO  SourceForge:
ECHO.
ECHO  Type ..: checkout-%app_name%
ECHO.
ECHO  After the pause, the checkout help menu
ECHO  will be displayed.
ECHO.
PAUSE
CALL %based%\scripts\help\qtenv-help-checkout.cmd
GOTO EOF

:: UNSUPPORTED BUILD TYPE
:BADTYPE
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO   ^( %1 ^) IS AN INVALID TARGET
ECHO -----------------------------------------------------------------
ECHO. 
ECHO  After the pause, a build help menu
ECHO  will be displayed. Please use the syntax
ECHO  as outlined and choose the correct
ECHO  target to build.
ECHO.
ECHO  Example: build-%app_name% rinstall
ECHO.
PAUSE
CALL %scr%\help\qtenv-help-%app_name%.cmd
GOTO EOF

:: GENERAL CMAKE ERROR MESSAGE
:CMAKE_ERROR
ECHO.
ECHO -----------------------------------------------------------------
ECHO                    CMAKE BUILD ERROR
ECHO -----------------------------------------------------------------
ECHO.
ECHO  There was a problem building ^( %app_name% ^)
ECHO.
ECHO  Check the screen for error messages, correct, then try to
ECHO  re-build ^( %app_name% ^)
ECHO.
ECHO.
GOTO EOF

:: UNSUPPORTED INSTALLER TYPE
:NSIS_BUILD_ERROR
ECHO.
ECHO -----------------------------------------------------------------
ECHO                    INSTALLER BUILD ERROR
ECHO -----------------------------------------------------------------
ECHO.
ECHO  There was a problem building the package, or the script
ECHO  could not find:
ECHO.
ECHO  %buildd%\%option%\%WSJTXPKG%
ECHO.
ECHO  Check the Cmake logs for any errors, or correct any build
ECHO  script issues that were obverved and try to rebuild the package.
ECHO.
ECHO.
GOTO EOF

:: END QTENV-WSJTXRC.CMD
:EOF
CD /D %based%
ENDLOCAL

EXIT /B 0
