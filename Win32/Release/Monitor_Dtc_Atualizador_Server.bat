@echo off
setlocal enabledelayedexpansion

:: ===== Configurações =====
set "BASEDIR=%~dp0"
set "LOG=%BASEDIR%monitor_timer.log"

:: ===== Inicio do monitoramento =====
echo ======================================== >> "%LOG%"
echo Inicio: %date% %time% >> "%LOG%"
echo ======================================== >> "%LOG%"

echo Monitor iniciado. Pressione ENTER para iniciar o loop...
pause

:loop
echo [%date% %time%] [BAT] Verificando timer.ini em %BASEDIR%
echo [%date% %time%] [BAT] Verificando timer.ini em %BASEDIR% >> "%LOG%"

:: ===== PowerShell temporário =====
set "PSFILE=%BASEDIR%verifica_timer.ps1"
(
echo $log = '%LOG%'
echo $ini = Join-Path '%BASEDIR%' 'timer.ini'
echo Add-Content $log ('[' + (Get-Date) + '] Iniciando verificacao do timer.ini')
echo if (Test-Path $ini) {
echo     Add-Content $log 'timer.ini encontrado'
echo     $line = Get-Content $ini ^| Where-Object { $_ -match 'DataHora=' }
echo     if ($line) {
echo         Add-Content $log ('Linha DataHora encontrada: ' + $line)
echo         $value = $line.Split('=')[1].Trim()
echo         Add-Content $log ('Valor extraido: ' + $value)
echo         $dt = [datetime]::ParseExact($value, 'yyyy-MM-dd HH:mm:ss', $null)
echo         $span = New-TimeSpan -Start $dt -End (Get-Date)
echo         Add-Content $log ('Minutos decorridos desde DataHora: ' + [int]$span.TotalMinutes)
echo         if ($span.TotalMinutes -ge 10) {
echo             $exe = Join-Path '%BASEDIR%' 'Dtc_Atualizador_Server.exe'
echo             $p = Get-Process -ErrorAction SilentlyContinue ^| Where-Object { $_.Path -eq $exe }
echo             if (!$p) {
echo                 Add-Content $log ('Processo nao rodando -> iniciando')
echo                 Start-Process -FilePath $exe
echo             } else {
echo                 Add-Content $log 'Processo ja em execucao'
echo             }
echo         } else {
echo             Add-Content $log 'Menos de 10 minutos -> nao inicia processo'
echo         }
echo     } else {
echo         Add-Content $log 'Linha DataHora nao encontrada'
echo     }
echo } else {
echo     Add-Content $log 'timer.ini nao encontrado'
echo }
) > "%PSFILE%"

:: ===== Executa PowerShell =====
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"

echo [%date% %time%] Aguardando 480 segundos antes da proxima verificacao...
echo [%date% %time%] Aguardando 480 segundos antes da proxima verificacao... >> "%LOG%"

timeout /t 480 /nobreak >nul
goto loop
