REM -----
REM ACTION : install
REM USAGE :
REM rpm.bat install <package>
REM   Will install a RPM's package with this 
REM   application.
REM -----

set Package=
set Package=%1

echo  Command 'install' 
echo  -----
echo  package         = %Package% (required)
echo  -----
echo.

REM STEP 1
REM We check that the first argument is setted and
REM is valid ...
set /A ArgsCount=0
FOR %%A in (%*) DO (set /A ArgsCount+=1)

if %ArgsCount% LSS 1 (
    echo  #Sorry, the package's code must be setted.
    exit /B %EC_INSTALL_NOPKGCODE%
)

REM We check if there is a package available 
REM for this code ...
if not exist "%CONF_REPOSITORY%%Package%" (
    echo  #Sorry : no package found for the code %Package%.
    exit /B %EC_INSTALL_BADPKGCODE%
)

REM We're getting all the informations about the package
REM to install and first, we get the last version of the product ...
set LastVersion=
for /f "tokens=1*" %%G in ('dir /b /o:-n /a:d "%CONF_REPOSITORY%%Package%"') do (
    if not defined LastVersion (set LastVersion=%%G)
)

REM STEP 2
REM The package is available, we check if it's installed
REM localy to uninstall it if it's available, and when
REM it's clear, we remove the old package ...
if exist "%SCRIPT_PKG_DIR%%Package%\" (
    if exist "%SCRIPT_PKG_DIR%%Package%\uninstall.rpm.bat" (
        REM call %SCRIPT_PKG_DIR%%Package%\uninstall.rpm.bat > nul
        call %SCRIPT_ROOT_DIR%\rpm.bat uninstall %Package%
    ) else (
        rd /s /q "%SCRIPT_PKG_DIR%%Package%" || rem
    )
)

REM The package is available, so we download it localy
REM to reference it for further usages ...
mkdir "%SCRIPT_PKG_DIR%%Package%\"
robocopy /E %CONF_REPOSITORY%%Package%\%LastVersion%\ %SCRIPT_PKG_DIR%%Package% > %SCRIPT_ROOT_DIR%logs\dl_%Package:/=-%.log
echo %LastVersion% > %SCRIPT_PKG_DIR%%Package%\version.txt

REM STEP 3
REM we alors get the arguments to pass them to the installer.
for /f "tokens=1,* delims= " %%a in ("%*") do set ArgsToSendInstall=%%b

REM We get the configuration of the package to check the 
REM good appliance during the installation.
if exist %SCRIPT_PKG_DIR%%Package%\config.ini (
    for /F "tokens=*" %%I in (%SCRIPT_PKG_DIR%%Package%\config.ini) do set PKGCONF_%%I
)

REM STEP 4
REM We proceed to the installation of the package ...
echo  Package = %Package%
echo  Version = %LastVersion%
echo  Installation of the product ...
echo.

call %SCRIPT_PKG_DIR%%Package%\install.rpm.bat %ArgsToSendInstall%

echo.
echo  Installation finished (0x%errorlevel%)

exit /B %errorlevel%