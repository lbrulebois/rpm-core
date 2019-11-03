REM -----
REM ACTION : deploy
REM USAGE :
REM rpm.bat deploy <destdir>
REM   Will deploy the RPM's application in the
REM   wanted directory.
REM -----
set DestDir=
set DestDir=%1

echo  Command 'deploy' 
echo  -----
echo  destdir         = %DestDir% (required)
echo  -----
echo.

REM STEP 1
REM We check that the first argument is setted.
set /A ArgsCount=0
FOR %%A in (%*) DO (set /A ArgsCount+=1)

if %ArgsCount% LSS 1 (
    echo  #Sorry, the destination's directory must be setted.
    exit /B %EC_DEPLOY_NODESTDIR%
)

REM STEP 2
REM We proceed to the installation of the RPM's core
REM and we need first to clean the destination's ...
if exist %DestDir% (
    rd /s /q "%DestDir%" || rem
)

REM Then to create the directories to work on ...
mkdir "%DestDir%"
mkdir "%DestDir%\logs\"

REM and we copy the core to the destination directory ...
robocopy /E %SCRIPT_ROOT_DIR% "%DestDir%" > "%DestDir%\logs\deploy_core.log"

REM STEP 3
REM We upgrade the RPM's core to install all the 
REM functions and tools needed ...
call %DestDir%\rpm.bat install rpm/core

REM STEP 4
REM The core is upgraded, the tools are installed, we
REM can remove the deploy's command from the local installation ...
if exist "%DestDir%\bin\deploy.bat" (
    del /s /f /q "%DestDir%\bin\deploy.bat" > nul
)
if exist "%DestDir%\man\deploy\" (
    del /s /f /q "%DestDir%\man\deploy\*.*" > nul
)

REM STEP 5
REM We add the RPM's directory to the PATH var
REM if it's not already done ...
FOR /F "usebackq tokens=3*" %%A IN (`reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path`) DO (
    set ActualPathValue=%%A
) 
REM it's why we're checking that the %PATH% doesn't contain
REM already the RPM's path ...
if "!ActualPathValue:;%DestDir%=!"=="%ActualPathValue%" (
    echo  Adding the RPM's installation to the PATH variable. 
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_SZ /d "%PATH%;%DestDir%" /f
    REM We can now reboot the computer ...
    shutdown /r /t 0
) else ( 
    echo  The PATH variable contains already the RPM's installation.
)