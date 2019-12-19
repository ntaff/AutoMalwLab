# Script pour automatiser la création d'un environnement d'analyse de malware
# version 1.0
# Auteur : Nicolas TAFFOUREAU - DCPJ

. $PSScriptRoot\GetSysinternals.ps1
. $PSScriptRoot\UpdateSysinternals.ps1
. $PSScriptRoot\GetFile.ps1

# Installation des outils Sysinternal
Update-Sysinternals "$PSScriptRoot\Sysinternals"

#****************************************************************************************#

# Installation de DNSQuerySniffer
Get-File "https://www.nirsoft.net/utils/dnsquerysniffer-x64.zip" "dnsquerysniffer-x64.zip"

# On extrait le fichier zip précédemment téléchargé
Expand-Archive -LiteralPath "$PSScriptRoot\dnsquerysniffer-x64.zip" -DestinationPath "$PSScriptRoot\dnsquerysniffer"

# Puis on le supprime
remove-item "$PSScriptRoot\dnsquerysniffer-x64.zip"

#****************************************************************************************#

# Installation de Floss
Get-File "http://s3.amazonaws.com/build-artifacts.floss.flare.fireeye.com/appveyor/dist/floss64.exe" "floss64.exe"

#****************************************************************************************#

# Installation de TCPDump
Get-File "http://www.microolap.com/downloads/tcpdump/tcpdump_trial_license.zip" "tcpdump_trial_license.zip"

# On extrait le fichier zip précédemment téléchargé
Expand-Archive -LiteralPath "$PSScriptRoot\tcpdump_trial_license.zip" -DestinationPath "$PSScriptRoot\tcpdump"

# Puis on le supprime
remove-item "$PSScriptRoot\tcpdump_trial_license.zip"

#****************************************************************************************#

# Installation de Free-EmlReader
Get-File "https://www.emlreader.com/dl/free-emlreader.exe" "free-emlreader.exe"

#****************************************************************************************#

# Installation de PD64
Get-File "http://www.split-code.com/files/pd_v2_1.zip" "pd_v2_1.zip"

# On extrait le fichier zip précédemment téléchargé
Expand-Archive -LiteralPath "$PSScriptRoot\pd_v2_1.zip" -DestinationPath "$PSScriptRoot\pd64"

# Puis on le supprime
remove-item "$PSScriptRoot\pd_v2_1.zip"

#****************************************************************************************#

# Installation de Free-msg-viewer
Get-File "https://www.freeviewer.org/dl/free-msg-viewer.exe" "free-msg-viewer.exe"

# On l'installe
Start-Process -Wait -FilePath "$PSScriptRoot\free-msg-viewer.exe" -ArgumentList "/S" -PassThru

#****************************************************************************************#

# Installation de Notepad++
Get-File "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.8.2/npp.7.8.2.Installer.x64.exe" "npp.7.8.2.Installer.x64.exe"

# On l'installe
Start-Process -Wait -FilePath "$PSScriptRoot\npp.7.8.2.Installer.x64.exe" -ArgumentList "/S" -PassThru
