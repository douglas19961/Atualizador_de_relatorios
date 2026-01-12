@echo off
title Monitor_Dtc_Atualizador_Server
setlocal enabledelayedexpansion

:: ============================================
:: CONFIGURAÇÕES
:: ============================================
set "processo=Dtc_Atualizador_Server.exe"
set "caminho=C:\Program Files\Datacom\DtcSync\Dtc_Atualizador_Server.exe"
set "log=%~dp0Monitor_DTC.log"
set "intervalo=10"

:: Mostra informações na tela
cls
echo ========================================
echo   Monitor Dtc_Atualizador_Server
echo ========================================
echo Processo: %processo%
echo Caminho: %caminho%
echo Log: %log%
echo Intervalo: %intervalo% segundos
echo ========================================
echo.
echo Monitorando... Pressione CTRL+C para parar
echo.

:: Inicializa log
echo ========================================>>"%log%"
echo Inicio: %date% %time% >>"%log%"
echo Processo: %processo% >>"%log%"
echo Caminho: %caminho% >>"%log%"
echo ========================================>>"%log%"

:: Verifica se o executável existe
if not exist "%caminho%" (
    echo [%date% %time%] ERRO: Executavel nao encontrado >>"%log%"
    echo.
    echo ERRO: Executavel nao encontrado em:
    echo %caminho%
    echo.
    pause
    exit /b 1
)

echo [%date% %time%] Monitoramento iniciado >>"%log%"
echo [%date% %time%] Monitoramento iniciado

:: ============================================
:: LOOP DE MONITORAMENTO
:: ============================================
:loop

:: Verifica se o processo está rodando usando wmic
set "contador=0"
for /f %%A in ('wmic process where "name='%processo%'" get processid /value 2^>nul ^| find /C "ProcessId"') do set "contador=%%A"

:: Se wmic não encontrou, tenta tasklist
if "!contador!"=="" (
    tasklist 2>NUL | find /I "Dtc_Atualizador" >NUL
    if errorlevel 1 (
        set "contador=0"
    ) else (
        set "contador=1"
    )
)

if !contador! EQU 0 (
    :: Processo não encontrado - inicia
    echo [%time%] Processo nao encontrado. Iniciando... >>"%log%"
    echo [%time%] Processo nao encontrado. Iniciando...
    
    pushd "C:\Program Files\Datacom\DtcSync"
    start "" "%caminho%"
    popd
    
    :: Aguarda um pouco para o processo iniciar
    timeout /t 3 >NUL
    
    echo [%time%] Processo iniciado >>"%log%"
    echo [%time%] Processo iniciado
    
    :: Continua o loop normalmente
    goto :continuar
)

if !contador! EQU 1 (
    :: Exatamente uma instância - NÃO FAZ NADA (silencioso)
    REM Não exibe mensagem - apenas monitora
    goto :continuar
)

if !contador! GTR 1 (
    :: Múltiplas instâncias encontradas - lista detalhes
    echo [%time%] AVISO: !contador! instancias encontradas >>"%log%"
    echo [%time%] AVISO: !contador! instancias encontradas
    echo. >>"%log%"
    echo ======================================== >>"%log%"
    echo DETALHES DAS INSTANCIAS (para identificar no Gerenciador de Tarefas): >>"%log%"
    echo ======================================== >>"%log%"
    
    :: Lista todas as instâncias com informações detalhadas
    wmic process where "name='%processo%'" get processid,executablepath,creationdate,commandline /format:list >>"%log%" 2>NUL
    
    echo. >>"%log%"
    echo INSTRUCOES: >>"%log%"
    echo 1. Abra o Gerenciador de Tarefas (Ctrl+Shift+Esc) >>"%log%"
    echo 2. Vá em "Detalhes" >>"%log%"
    echo 3. Procure por "Dtc_Atualizador_Server.exe" >>"%log%"
    echo 4. Compare o PID e o caminho com as informacoes acima >>"%log%"
    echo 5. Feche as instancias com caminho diferente de: %caminho% >>"%log%"
    echo ======================================== >>"%log%"
    echo.
)

:continuar
:: Aguarda antes da próxima verificação
timeout /t %intervalo% >NUL

:: Garante que o loop continue
goto loop

