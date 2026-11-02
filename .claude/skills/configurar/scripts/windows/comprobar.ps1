# Comprobaciones de solo lectura para Windows (no cambia nada).
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File comprobar.ps1
$ErrorActionPreference = 'SilentlyContinue'

Write-Output "=== Certificados FNMT (usuario actual) ==="
$certs = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Issuer -like '*AC FNMT Usuarios*' }
if (-not $certs) { Write-Output "NINGUNO" }
foreach ($c in $certs) {
  $estado = if ($c.NotAfter -gt (Get-Date)) { 'VALIDO' } else { 'CADUCADO' }
  Write-Output ("{0} | caduca {1:dd/MM/yyyy} | {2} | clave privada: {3}" -f $c.Subject, $c.NotAfter, $estado, $c.HasPrivateKey)
}

Write-Output "`n=== AutoFirma ==="
$rutas = @("$env:ProgramFiles\AutoFirma", "${env:ProgramFiles(x86)}\AutoFirma", "$env:LOCALAPPDATA\Programs\AutoFirma")
$af = $rutas | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($af) { Write-Output "INSTALADO en $af" } else { Write-Output "NO ENCONTRADO" }

Write-Output "`n=== Chrome: autoselección de certificado ==="
$k = 'HKCU:\Software\Policies\Google\Chrome\AutoSelectCertificateForUrls'
if (Test-Path $k) { (Get-ItemProperty $k).PSObject.Properties | Where-Object { $_.Name -match '^\d+$' } | ForEach-Object { Write-Output "$($_.Name): $($_.Value)" } }
else { Write-Output "NO CONFIGURADO" }

Write-Output "`n=== Carpetas en la nube ==="
$nube = @("$env:USERPROFILE\Dropbox", "$env:USERPROFILE\OneDrive", "$env:USERPROFILE\iCloudDrive", "G:\Mi unidad", "G:\My Drive")
$nube | Where-Object { Test-Path $_ } | ForEach-Object { Write-Output $_ }

Write-Output "`n=== Descargas ==="
Write-Output "$env:USERPROFILE\Downloads"
