function Get-Sysinternals {
    [CmdLetBinding()]
    param(
        [string]$InstallLocation
    )

    if ($InstallLocation) {
        Get-ChildItem -Path $InstallLocation | Select-Object -Property Name,Length,LastWriteTime,@{l='Updated';e={Get-Date $_.LastWriteTime -Format d}}

    } else {
        $SysinternalsLiveUrl = 'https://live.sysinternals.com'
        Write-Verbose -Message "Récupération de la liste des outils Sysinternals à l'adresse suivante : $SysinternalsLiveUrl"
        try {
            $SysinternalsLive = Invoke-WebRequest -Uri $SysinternalsLiveUrl -UseBasicParsing
        }
        catch {
            Write-Warning -Message "Erreur : impossible de récupérer la liste des outils Sysinternals à l'adresse suivante : $SysinternalsLiveUrl"
            $PSCmdlet.ThrowTerminatingError($_)
        }
        $SysinternalsList = ($SysinternalsLive.Content -Split('<br>')).Where({$_ -notmatch '<pre|pre>|&lt;dir&gt;'})

        foreach ($File in $SysinternalsList) {
            $LineParts = $File.Trim().Split(' ')
            $LineParts[-1] -match '>(.*?\..*?)<' | Out-Null
            $LastWriteTime = [datetime]($LineParts[0..9] -join ' ').trim()

            [PSCustomObject]@{
                Name = $Matches[1]
                Length = (($LineParts | Select-Object -Skip 10) -join ' ').Trim().Split(' ')[0]
                LastWriteTime = $LastWriteTime
                Updated = Get-Date $LastWriteTime -Format d
            }
        }
    }
}
