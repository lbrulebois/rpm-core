REM -----
REM ACTION : usage
REM USAGE :
REM rpm.bat usage [<action>]
REM   Will explain the user how to use RPM or the 
REM   wanted action.
REM -----

setlocal enabledelayedexpansion

set ActionCmd=
set ActionCmd=%1

echo  Command 'usage' 
echo  -----
echo  action          = %ActionCmd% (optionnal)
echo  -----
echo.

REM If no action is specified, we load the summary ...
REM In the other case, we try to load the documentation 
REM linked to the wanted command if it exists, overwise,
REM we inform the user that it's not possible 
REM in two case : the command doesn't exist -
REM we return an error / no documentation found.
if [%1] == [] (
    echo  Available actions :
    for /f "tokens=*" %%A in ('dir /b %SCRIPT_DIR%\*.bat') do (
        echo    - %%~nA
    )
) else (
    echo  Command : %ActionCmd%

    if not exist "%SCRIPT_DIR%%ActionCmd%.bat" ( 
        echo  #Sorry : the command isn't recognized 
        exit /B %EC_BADCOMMAND% 
    )

    if not exist "%SCRIPT_MAN_DIR%%ActionCmd%.txt" (
        echo  #Sorry, no documentation found for this command.
        exit /B %EC_USAGE_NODOCFOUND%
    )

    for /f "delims=" %%l in (%SCRIPT_MAN_DIR%%ActionCmd%.txt) do (
        if "%%l" == " " ( 
            echo. 
        ) else (
            echo   %%l
        )
    )
)