@echo off
setlocal enabledelayedexpansion
set "BASEDIR=%~dp0"

:loop
echo [BAT] Verificando timer.ini em %BASEDIR%

powershell -NoProfile -Command "$ini = Join-Path '%BASEDIR%' 'timer.ini'; if (Test-Path $ini) {   $line = Get-Content $ini | Where-Object { $_ -match 'DataHora=' };   if ($line) {     $value = $line.Split('=')[1].Trim();     $dt = [datetime]::ParseExact($value, 'yyyy-MM-dd HH:mm:ss', $null);     $span = New-TimeSpan -Start $dt -End (Get-Date);     if ($span.TotalMinutes -ge 10) {       $exe = Join-Path '%BASEDIR%' 'Dtc_Atualizador_Server.exe';       if (-not (Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $exe })) { Start-Process -FilePath $exe }     }   } }"

timeout /t 480 /nobreak >nul
goto loop
