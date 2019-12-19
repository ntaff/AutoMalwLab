function Get-File {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$urlLocation,
        [string]$ToolFolderName
    )
        
        $OutFile = Join-Path -Path $PSScriptRoot -ChildPath "$ToolFolderName"

        Write-Output " "
        Write-Output "**************************************"
        Write-Output "Téléchargement de $ToolFolderName en cours..."

        Invoke-WebRequest -Uri $urlLocation -OutFile $OutFile -Verbose:$false
}
