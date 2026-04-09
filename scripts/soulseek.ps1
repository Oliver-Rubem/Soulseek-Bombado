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
    } elseif ($url -match 'track/([a-zA-Z0-9]+)') {
        $trackId = $matches[1]
        $headers = @{"Authorization"="Bearer $token"}
        try {
            $response = Invoke-RestMethod -Uri "https://api.spotify.com/v1/tracks/$trackId" -Method Get -Headers $headers
            return @("$($response.artists[0].name) - $($response.name)")
        } catch { return $null }
    } else { 
        Write-Host "URL da playlist/track invalida!"
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
        } catch { 
            Write-Host "Erro ao buscar faixas."
            $apiUrl = $null 
        }
    }
    return $tracks
}

if (-not (Test-Path $sldlPath)) {
    Write-Host "sldl.exe nao encontrado."
    exit 1
}

Write-Host "Conectando ao Spotify..."
$token = Get-SpotifyToken
if (-not $token) { exit 1 }

$musicas = Get-PlaylistTracks -url $Url -token $token
if (-not $musicas) { exit 1 }

if (-not ([System.IO.Path]::IsPathRooted($OutputPath))) {
    $OutputPath = Join-Path $PSScriptRoot "..\$OutputPath"
}

if (-not (Test-Path $OutputPath)) { New-Item -Path $OutputPath -ItemType Directory | Out-Null }

Write-Host "$($musicas.Count) musicas encontradas! Iniciando downloads..."

foreach ($query in $musicas) {
    $cleanQuery = $query -replace '["''\/\?\*\:\<\>\|]', ''
    Write-Host "Buscando: $cleanQuery"
    & $sldlPath "$cleanQuery" -p "$OutputPath" --no-progress
}

Write-Host "Fim."
exit 0
