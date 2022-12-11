$ErrorActionPreference = 'SilentlyContinue'

$index = @()
$index_input = Get-ChildItem -File -Recurse -Exclude '.gitkeep' -Path "$PSScriptRoot\input"

foreach ($i in (Get-ChildItem -Directory -Path $PSScriptRoot)) {
    if ($i.Name -match '^[0-9a-zA-F]{2}$') {
        Remove-Item -Force -Recurse -Path $i.FullName
    }
}

foreach ($i in $index_input) {
    $hash = (Get-FileHash -Algorithm SHA256 -Path $i.FullName).Hash.ToLower()
    $hash_short = $hash.Substring(0, 2)

    $index += @{source = $i.FullName.Substring($PSScriptRoot.Length + 1); destination = "$($hash_short)\$($hash)" }

    New-Item -ItemType 'Directory' -Path "$PSScriptRoot\$($hash_short)" | Out-Null
    Copy-Item -Path $i.FullName -Destination "$PSScriptRoot\$($hash_short)\$($hash)"
}

ConvertTo-Json -InputObject $index | Out-File -FilePath "$PSScriptRoot\index.json"
