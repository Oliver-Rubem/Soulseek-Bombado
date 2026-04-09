param(
    [Parameter(Mandatory=$true)][string]$Url,
    [Parameter(Mandatory=$true)][string]$OutputPath
)

$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$ConfigPath = Join-Path $PSScriptRoot "..\config.json"
$Config = Get-Content $ConfigPath | ConvertFrom-Json

$ClientId = $Config.spotify_client_id
$ClientSecret = $Config.spotify_client_secret
$sldlPath = Join-Path $PSScriptRoot "..\slsk-batchdl\publish\sldl.exe"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-SpotifyToken {
    $auth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${ClientId}:${ClientSecret}"))
    $headers = @{"Authorization"="Basic $auth"; "Content-Type"="application/x-www-form-urlencoded"}
    $body = "grant_type=client_credentials"
    try {
        $response = Invoke-RestMethod -Uri "https://accounts.spotify.com/api/token" -Method Post -Headers $headers -Body $body
        return $response.access_token
    } catch { 
        Write-Host "Erro na autenticacao Spotify: $($_.Exception.Message)"
        return $null 
    }
}

function Get-PlaylistTracks($url, $token) {
    if ($url -match 'playlist/([a-zA-Z0-9]+)') {
        $playlistId = $matches[1]
    } else { 
        return $null 
    }

    $headers = @{"Authorization"="Bearer $token"}
    $tracks = @()
    $apiUrl = "https://api.spotify.com/v1/playlists/$playlistId/tracks?limit=100"

    while ($apiUrl) {
        try {
            $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers
            foreach ($item in $response.items) {
                if ($item.track) {
                    $tracks += "$($item.track.artists[0].name) - $($item.track.name)"
                }
            }
            $apiUrl = $response.next
        } catch { $apiUrl = $null }
    }
    return $tracks
}

if (-not ([System.IO.Path]::IsPathRooted($OutputPath))) {
    $OutputPath = Join-Path $PSScriptRoot "..\$OutputPath"
}

if (-not (Test-Path $OutputPath)) { New-Item -Path $OutputPath -ItemType Directory | Out-Null }

Write-Host "Iniciando modo Hybrid..."

$token = Get-SpotifyToken
$musicas = Get-PlaylistTracks -url $Url -token $token

if ($null -eq $musicas -or $musicas.Count -eq 0) {
    Write-Host "Nenhuma musica encontrada ou erro na API. Tentando fallback para SpotDL puro..."
    & python -m spotdl download --output "{artist} - {title}" --format mp3 --lyrics genius $Url --output-dir "$OutputPath"
    exit 0
}

$falhas = @()
if (Test-Path $sldlPath) {
    Write-Host "Passo 1/2: Baixando do Soulseek (Qualidade FLAC/MP3 320)..."
    foreach ($query in $musicas) {
        $cleanQuery = $query -replace '["''\/\?\*\:\<\>\|]', ''
        Write-Host "Buscando: $cleanQuery"
        $output = & $sldlPath "$cleanQuery" -p "$OutputPath" --no-progress 2>&1
        $outputStr = $output | Out-String
        if ($outputStr -match "0 files downloaded") {
            $falhas += $query
        }
    }
} else {
    Write-Host "sldl.exe nao encontrado. Baixando todas via SpotDL."
    $falhas = $musicas
}

if ($falhas.Count -gt 0) {
    Write-Host "Passo 2/2: Recuperando $($falhas.Count) musicas faltantes via SpotDL..."
    $TempList = Join-Path $PSScriptRoot "..\Downloads\missing.txt"
    $falhas | Out-File -FilePath $TempList -Encoding utf8
    & python -m spotdl download --list $TempList --output "{artist} - {title}" --format mp3 --lyrics genius --output-dir "$OutputPath"
    Remove-Item $TempList -ErrorAction SilentlyContinue
}

Write-Host "Fim."
exit 0
