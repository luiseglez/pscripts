#SCRIPT PARA RECUPERAR Y RESPALDAR LA CALVE DE RECUPERACION

# Ruta de respaldo
$RutaRespaldo = "$env:USERPROFILE\BitLocker_Recovery_Keys"
New-Item -ItemType Directory -Path $RutaRespaldo -Force | Out-Null

# Obtener unidades locales
$Unidades = @(Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType = 3")

foreach ($Unidad in $Unidades) {
    $Letra = $Unidad.DeviceID
    Write-Host "`n🔍 Verificando unidad $Letra..."

    # Ejecutar manage-bde y limpiar salida
    $Raw = manage-bde -protectors -get $Letra 2>&1
    $Texto = $Raw | ForEach-Object {
        $_.Trim() -replace '[^\u0000-\u007F]', ''  # Limpia caracteres especiales
    }

    # Buscar clave de recuperación
    $Clave = $null
    foreach ($Linea in $Texto) {
        if ($Linea -match "\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}") {
            $Clave = $Matches[0].Trim()
            break
        }
    }

     
    if ($Clave) {
        Write-Host "✅ Clave encontrada en $Letra $Clave"

        # Guardar en archivo
        $Archivo = "$RutaRespaldo\BitLocker_$($Letra.Replace(':','')).txt"
        $Contenido = @"
    

Unidad: $Letra
Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Clave: $Clave
"@
        $Contenido | Out-File -FilePath $Archivo -Encoding UTF8
        Write-Host "📁 Clave respaldada en: $Archivo"
    } else {
        Write-Host "⚠️ No se encontró clave de recuperación en $Letra."
    }
}





