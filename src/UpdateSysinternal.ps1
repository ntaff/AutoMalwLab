function Update-Sysinternals {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallLocation,
        [switch]$Force,
        [switch]$IgnoreDownloadErrors
    )

    $BlacklistPath = Join-Path -Path $PSScriptRoot -ChildPath 'Blacklist.json'
    $DownloadErrors = @()

    if (-Not (Test-Path -Path $InstallLocation)) {
        Write-Output "Le chemin d'accès $InstallLocation n'existe pas."
        $Response = Read-Host -Prompt "Voulez vous en créer un ? (O/N)"
        if ($Response -ne 'O') {
            Write-Warning -Message 'Ok Boomer.'
            exit
        } else {
            try {
                New-Item -Path $InstallLocation -Force -Type Directory | Out-Null
                Write-Verbose -Message "$InstallLocation crée"
            }
            catch {
                Write-Warning -Message 'Erreur, impossible de créer le chemin d accès'
                exit 1
            }
        }
    }

    if (-Not $IgnoreDownloadErrors) {
        Write-Verbose -Message 'Recherche de fichier blacklistés...'
        $SkipFiles = Get-Content -Path $BlacklistPath -ErrorAction SilentlyContinue | ConvertFrom-Json
    }

    Write-Verbose -Message 'Liste actuelle des fichiers Sysinternals.'
    try {
        $Sysinternals = Get-Sysinternals -Verbose:$false
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }

    Write-Verbose -Message 'Récupération des fichiers locaux de Sysinternals.'
    $LocalFiles = Get-Sysinternals -InstallLocation $InstallLocation

    if ($Force) {
        Write-Verbose -Message 'Téléchargement de tous les fichiers.'
        $DownloadFiles = $Sysinternals
    } elseif ($LocalFiles) {
        Write-Verbose -Message 'Recherche si les fichiers sont à jour.'
        $DownloadFiles = Compare-Object -Property Updated -ReferenceObject $LocalFiles -DifferenceObject $Sysinternals -PassThru | Where-Object {$_.SideIndicator -eq '=>'}
    } else {
        Write-Verbose -Message "Le chemin d accès $InstallLocation est vide, téléchargement de tous les fichiers."
        $DownloadFiles = $Sysinternals
    }

    if ($SkipFiles) {
        Write-Verbose -Message "fichiers suivants non pris en compte:"
        Write-Verbose -Message ("`n" + ($SkipFiles | Format-Table -AutoSize | Out-String).Trim())
        $DownloadFiles = $DownloadFiles | Where-Object {$SkipFiles.Name -notcontains $_.Name}
    }

    $OriginalProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'

    Write-Verbose -Message 'Mises à jour des outils Sysinternals.'
    $Count = 0
    foreach ($Tool in $DownloadFiles) {

        Write-Output "Téléchargement du fichier : $($Tool.Name)"
        $Uri = 'https://live.sysinternals.com/tools/' + $Tool.Name
        $OutFile = Join-Path -Path $InstallLocation -ChildPath $Tool.Name

        try {
            Invoke-WebRequest -Uri $Uri -OutFile $OutFile -Verbose:$false

            Write-Verbose -Message "Mise à jour de la variable LastWriteTime pour $($Tool.Name) to $($Tool.LastWriteTime)"
            $UpdateLastWriteTime = Get-ChildItem -Path $OutFile
            $UpdateLastWriteTime.LastWriteTime = $Tool.LastWriteTime
            $Count++
        }
        catch {
            if (-Not $IgnoreDownloadErrors) {
                Write-Warning -Message "Impossible de télécharger $($Tool.Name)"
                $DownloadErrors += $Tool
            }
        }
    }
    $ProgressPreference = $OriginalProgressPreference

    if ($DownloadErrors) {
        Write-Warning -Message "Des erreurs de téléchargement ont été rencontrées."
        $Response = Read-Host -Prompt "Voulez vous ignorer ces fichiers la prochaine fois ? (O/N)"

        if ($Response -eq 'O') {
            $DownloadFiles | Select-Object -Property Name,Length,LastWriteTime,Updated | ConvertTo-Json |
                Out-File -FilePath $BlacklistPath -Force
        }
    }

    if ($Count -gt 0 ) {
        Write-Output ''
        Write-Output "$Count outils Sysinternals téléchargés"
    }

    Write-Output ''
}
