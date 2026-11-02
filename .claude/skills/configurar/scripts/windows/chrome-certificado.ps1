# Hace que Chrome elija solo el certificado FNMT en Cl@ve e Interior (equivalente Windows del "defaults write" de Mac).
# Solo toca la política de Chrome del usuario actual. Uso:
#   powershell -NoProfile -ExecutionPolicy Bypass -File chrome-certificado.ps1
$k = 'HKCU:\Software\Policies\Google\Chrome\AutoSelectCertificateForUrls'
New-Item -Path $k -Force | Out-Null
New-ItemProperty -Path $k -Name '1' -PropertyType String -Force -Value '{"pattern":"https://[*.]clave.gob.es","filter":{"ISSUER":{"CN":"AC FNMT Usuarios"}}}' | Out-Null
New-ItemProperty -Path $k -Name '2' -PropertyType String -Force -Value '{"pattern":"https://[*.]mir.es","filter":{"ISSUER":{"CN":"AC FNMT Usuarios"}}}' | Out-Null
Write-Output "Hecho. Cierra Chrome del todo y abre chrome://policy para comprobarlo."
