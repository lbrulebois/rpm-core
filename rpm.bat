REM -----
REM Remote Packages' Manager (v0.3)
REM Tool to deploy, install, repair or uninstall
REM products needed on a computer using a 
REM network repository.
REM -----
@echo off
setlocal enabledelayedexpansion

REM RPM's header
echo  Remote Products Manager (RPM)
echo  -----
echo   v0.3 - by BRULEBOIS Loic
echo   Script to deploy easily products on a computer
echo   using the common network.
echo  -----
echo.
echo.

REM -----
REM Global variables for RPM
set SCRIPT_ROOT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_ROOT_DIR%bin\
set SCRIPT_PKG_DIR=%SCRIPT_ROOT_DIR%pkg\
set SCRIPT_MAN_DIR=%SCRIPT_ROOT_DIR%man\
set SCRIPT_LOG_DIR=%SCRIPT_ROOT_DIR%logs\
REM -----

REM -----
REM Main exit codes
set EC_SUCCESS=0
set EC_CRITICAL=1
REM -----

REM -----
REM Exit codes
set EC_NOCONFIG=10
set EC_BADCOMMAND=11
set EC_DEPLOY_NODESTDIR=20
set EC_INSTALL_NOPKGCODE=21
set EC_INSTALL_BADPKGCODE=22
set EC_USAGE_NODOCFOUND=23
set EC_UNINSTALL_NOPKGCODE=24
set EC_UNINSTALL_BADPKGCODE=25
set EC_APPLY_NOFILEPATH=26
set EC_APPLY_BADFILEPATH=27
SET EC_UPDATE_BADPKGCODE=28
REM -----

REM STEP 1
REM If the file doesn't exist, we return an error ...
if not exist "%SCRIPT_ROOT_DIR%config.ini" ( 
    echo  #Sorry, the configuration file isn't found
    exit /B %EC_NOCONFIG%
)
REM ... overwise, we load the RPM's configuration 
REM for further usages.
echo  -- Configuration -----
for /F "tokens=*" %%I in (%SCRIPT_ROOT_DIR%config.ini) do (
    set CONF_%%I
    echo  %%I
)
echo  ----------------------
echo.

REM STEP 2
REM To excute the action, we first need to known how 
REM many arguments are given ...
set /A ArgsCount=0
FOR %%A in (%*) DO (set /A ArgsCount+=1)
REM ... and select all the arguments after the first one
for /f "tokens=1,* delims= " %%a in ("%*") do set ArgsToSend=%%b

REM We get the command to execute, and if no one
REM is defined, we call the "usage" command !
set Command=%1
if %ArgsCount% LSS 1 (set Command=usage)

REM We can now call the command linked script if
REM the script exists !
if exist "%SCRIPT_DIR%%Command%.bat" (
    call %SCRIPT_DIR%%Command%.bat %ArgsToSend%
    exit /B %errorlevel%
) else (
    echo  #Sorry : the command isn't recognized
    exit /B %EC_BADCOMMAND%
)