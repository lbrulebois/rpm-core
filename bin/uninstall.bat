REM -----
REM ACTION : uninstall
REM USAGE :
REM rpm.bat uninstall <package>
REM   Will uninstall a RPM's package with this 
REM   application.
REM -----

set Package=
set Package=%1

echo  Command 'uninstall' 
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
    exit /B %EC_UNINSTALL_NOPKGCODE%
)

REM We check if there is a package available 
REM for this code ...
if not exist "%SCRIPT_PKG_DIR%%Package%" (
    echo  #Sorry : no package found for the code %Package%.
    exit /B %EC_UNINSTALL_BADPKGCODE%
)

REM STEP 2
REM we alors get the arguments to pass them to the installer.
for /f "tokens=1,* delims= " %%a in ("%*") do set ArgsToSendInstall=%%b

REM We get the configuration of the package to check the 
REM good appliance during the installation.
if exist %SCRIPT_PKG_DIR%%Package%\config.ini (
    for /F "tokens=*" %%I in (%SCRIPT_PKG_DIR%%Package%\config.ini) do set PKGCONF_%%I
)

REM STEP 3
REM We proceed to the uninstallation of the package ...
echo  Package = %Package%
echo  Version = %LastVersion%
echo  Uninstallation of the product ...
echo.

call %SCRIPT_PKG_DIR%%Package%\uninstall.rpm.bat

echo.
echo  Uninstallation finished (0x%errorlevel%)

rmdir /s /q "%SCRIPT_PKG_DIR%%Package%\"
exit /B %errorlevel%