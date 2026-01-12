:::::::::::::::::::::::::::::::::::::::::::: 
:: Elevate.cmd - Version 4 
:: Automatically check & get admin rights 
:::::::::::::::::::::::::::::::::::::::::::: 
@echo off 
CLS 
REM ECHO. 
REM ECHO ============================= 
REM ECHO Running Admin shell 
REM ECHO ============================= 
 
:init 
setlocal DisableDelayedExpansion 
set cmdInvoke=1 
set winSysFolder=System32 
set "batchPath=%~0" 
for %%k in (%0) do set batchName=%%~nk 
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs" 
setlocal EnableDelayedExpansion 
 
:checkPrivileges 
NET FILE 1>NUL 2>NUL 
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges ) 
 
:getPrivileges 
if '%1'=='ELEV' ( shift /1 & goto gotPrivileges) 
REM ECHO. 
REM ECHO ************************************** 
REM ECHO Invoking UAC for Privilege Escalation 
REM ECHO ************************************** 

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"

if '%cmdInvoke%'=='1' goto InvokeCmd 

ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
goto ExecElevation

:InvokeCmd
ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
"%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

:LOOP
REM echo Verificando se o arquivo está presente...
if exist "C:\Dtc_Atualizador_Server.exe" (
    REM echo Arquivo encontrado. Iniciando atualização...
    goto :UPDATE
) else (
    REM echo Arquivo não encontrado. Aguardando 10 segundos...
    timeout /t 10 /nobreak > nul
    goto :LOOP
)

:UPDATE
REM echo Encerrando Dtc_Atualizador_Server...
taskkill /F /IM Dtc_Atualizador_Server.exe > nul 2>&1
timeout /t 2 /nobreak > nul

REM echo Atualizando Dtc_Atualizador_Server...

cd /d "C:\Dtc_Atualizador_Server"

move /y "C:\Dtc_Atualizador_Server.exe" "C:\Program Files\Datacom\DTCSync\Dtc_Atualizador_Server.exe" > nul 2>&1

if errorlevel 1 (
    REM echo Falha ao mover o arquivo. Verifique se o arquivo não está em uso e se a pasta de destino existe.
    exit /b 1
) else (
    REM echo Arquivo movido com sucesso.
)

del "C:\Dtc_Atualizador_Server.exe" > nul 2>&1

if exist "C:\Dtc_Atualizador_Server.exe" (
    REM echo Falha ao excluir o arquivo antigo. Verifique se o arquivo não está em uso.
    exit /b 1
) else (
    REM echo Arquivo antigo excluído com sucesso.
)

REM echo Iniciando Dtc_Atualizador_Server...
start "" "C:\Program Files\Datacom\DTCSync\Dtc_Atualizador_Server.exe"

timeout /t 5 /nobreak > nul
