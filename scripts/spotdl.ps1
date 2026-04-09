param(
    [Parameter(Mandatory=$true)][string]$Url,
    [Parameter(Mandatory=$true)][string]$OutputPath
)

$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

if (-not ([System.IO.Path]::IsPathRooted($OutputPath))) {
    $OutputPath = Join-Path $PSScriptRoot "..\$OutputPath"
}

if (-not (Test-Path $OutputPath)) { New-Item -Path $OutputPath -ItemType Directory | Out-Null }

Write-Host "Iniciando download SpotDL..."

try {
    & python -m spotdl download --output "{artist} - {title}" --format mp3 --lyrics genius $Url --output-dir "$OutputPath"
    Write-Host "Download concluido via SpotDL."
} catch {
    Write-Host "Erro: $_"
    exit 1
}
exit 0
