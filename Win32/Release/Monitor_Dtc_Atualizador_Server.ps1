$ini = "timer.ini"
if (Test-Path $ini) {
  $line = Get-Content $ini | Select-String "DataHora="
  if ($line) {
    $value = $line.ToString().Split("=")[1].Trim()
    $dt = [datetime]::ParseExact($value, "yyyy-MM-dd HH:mm:ss", $null)
    $span = New-TimeSpan -Start $dt -End (Get-Date)
    if ($span.TotalMinutes -gt 3) {
      $exe = Join-Path $PSScriptRoot "Dtc_Atualizador_Server.exe"
      if (-not (Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $exe })) {
        Start-Process -FilePath $exe -WorkingDirectory $PSScriptRoot
      }
    }
  }
}
