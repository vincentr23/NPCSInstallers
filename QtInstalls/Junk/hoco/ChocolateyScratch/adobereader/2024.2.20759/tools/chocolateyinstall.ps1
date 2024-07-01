﻿$ErrorActionPreference = 'Stop'

$DisplayName = 'Adobe Acrobat'

# all checksum types are the same
$allChecksumType = 'SHA256'

$MUIurl = 'https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2400220759/AcroRdrDC2400220759_MUI.exe'
$MUIchecksum = 'A01BA9E824848B344F98E9CB6B19334865E8F37F515B8CE30B06EEA77451B9A9'

$MUIurl64 = 'https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2400220759/AcroRdrDCx642400220759_MUI.exe'
$MUIchecksum64 = '1D344CA4788568A605B09DD83CC839F2FE2C8390EE45518D53CEE032D25A5DF7'

$MUImspURL = 'https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2400220759/AcroRdrDCUpd2400220759_MUI.msp'
$MUImspChecksum = 'AA7839C37E70A11C7652AAAB60E767C8EDDE240AB0D57E0BEC9824CAC35B5489'

$MUImspURL64 = 'https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2400220759/AcroRdrDCx64Upd2400220759_MUI.msp'
$MUImspChecksum64 = '5A8E529A81EFBC26CD06E3F902187CDB295827246E810A4EE7A97DDF46D30F88'

$MUIinstalled = $false
$PerformNewInstall = $false
$ApplyPatch = $false
[array]$installation = Get-UninstallRegistryKey -SoftwareName $DisplayName.replace(' Acrobat', ' Acrobat*')

$MUImspURL -match 'AcroRdrDCUpd(\d+)_' | Out-Null
$UpdaterVersion = $Matches[1]

$PackageParameters = Get-PackageParameters

# this parameter _could_ cause issues so lets put lots of verbose text around it
if ($PackageParameters['IgnoreInstalled']) {
   if ([string]::IsNullOrEmpty($PackageParameters['IgnoreInstalled']) -or [string]::IsNullOrWhiteSpace($PackageParameters['IgnoreInstalled'])) {
      throw "Package parameter '/IgnoreInstalled' cannot be empty or whitespace."
   }

   $matchInstallation = ($PackageParameters['IgnoreInstalled']).Split(',')

   Write-Verbose "/IgnoreInstalled package parameter was passed with these software names:"
   $matchInstallation | ForEach-Object { Write-Verbose "- $_" }

   # loop over each found installation and ignore it if it matches a value in '/IgnoreInstalled'
   $key = for ($i = 0; $i -lt $installation.count; $i++) {
      for ($j = 0; $j -lt $matchInstallation.count; $j++) {
         if ($installation[$i].DisplayName -notlike $matchInstallation[$j]) {
            $installation[$i]
            Write-Verbose "Keeping '$($installation[$i].DisplayName)' as it does not match '$($matchInstallation[$j]))'"
         }
         else {
            Write-Verbose "Removing '$($installation[$i].DisplayName)' from list of found software, as it matches '$($matchInstallation[$j]))'"
         }
      }
   }

   Write-Verbose "After processing, we will use this list of installed software:"
   $key | ForEach-Object {
      Write-Warning "- $($_.DisplayName)"
   }

   if ($installation.Count -gt 0 -and $key.Count -eq 0) {
      Write-Warning "We originally found $($installation.Count) software names matching $($DisplayName.replace(' Acrobat', ' Acrobat*'))."
      Write-Warning 'Using ''/IgnoreInstalled'' matches, this is now 0.'
      Write-Warning 'This may be intended.'
      Write-Warning "This will cause issues if you have the software from this package already installed."
   }
}
else {
   $key = $installation
}

if ($key.Count -eq 1) {
   $InstalledVersion = $key[0].DisplayVersion.replace('.', '')
   $IsAdobeAcrobatReader = $key[0].DisplayName -match 'Adobe Acrobat Reader'
   if ($IsAdobeAcrobatReader -and $key[0].DisplayName -notmatch 'MUI') {
      if (($InstalledVersion -ge $UpdaterVersion) -and !($PackageParameters.OverwriteInstallation)) {
         Write-Warning "The currently installed $($key[0].DisplayName) is a single-language install."
         Write-Warning "You will need to uninstall $($key[0].DisplayName) first or use /OverwriteInstallation."
         Throw 'Installation halted.'
      }
      elseif (($InstalledVersion -ge $UpdaterVersion) -and $PackageParameters.OverwriteInstallation) {
         Write-Warning "The currently installed $($key[0].DisplayName) is a single-language install."
         Write-Warning  'This package will replace it with the multi-language (MUI) release (Installation overwrite).'
      }
      else {
         Write-Warning "The currently installed $($key[0].DisplayName) is a single-language install."
         Write-Warning  'This package will replace it with the multi-language (MUI) release.'
      }
   }
   else {
      $MUIinstalled = $true
      if ($InstalledVersion -eq $UpdaterVersion) {
         Write-Verbose 'Currently installed version is the same as this package.  Nothing further to do.'
         Return
      }
      elseif ($InstalledVersion -gt $UpdaterVersion) {
         Write-Warning "$($key[0].DisplayName) v20$($key[0].DisplayVersion) installed."
         Write-Warning "This package installs v$env:ChocolateyPackageVersion and cannot replace a newer version."
         Throw 'Installation halted.'
      }
      else {
         # for installations where there is an e.g. existing "Adobe Acrobat Reader DC MUI" present,
         # we perform a new installation otherwise we apply the patch
         if ($IsAdobeAcrobatReader) {
            $PerformNewInstall = $true
         }
         else {
            $ApplyPatch = $true
         }
      }
   }
}
elseif ($key.count -gt 1) {
   Write-Warning "$($key.Count) matching installs of Adobe Acrobat Reader DC found!"
   Write-Warning 'To prevent accidental data loss, this install will be aborted.'
   Write-Warning 'The following installs were found:'
   $key | ForEach-Object { Write-Warning "- Name: $($_.DisplayName)`tVersion: $($_.DisplayVersion)" }

   if ($PackageParameters['IgnoreInstalled']) {
      Write-Warning "You have passed '/IgnoreInstalled' containing:"
      ($PackageParameters['IgnoreInstalled']).Split(',') | ForEach-Object { Write-Warning "- $_" }
   }
   Throw 'Installation halted.'
}
else {
   $PerformNewInstall = $true
}

if ($PackageParameters.OverwriteInstallation) {
   Write-Host 'Uninstalling single language version.'
   $UninstallRegKey = [array](Get-UninstallRegistryKey "Adobe Acrobat Reader DC*")[0].UninstallString.split("/I")[2]
   $MSIArgs = @(
      "/x"
      '"{0}"'
      "/qn"
   ) -f $UninstallRegKey
   Start-Process "msiexec.exe" -ArgumentList $MSIArgs -Wait
   $Uninstalled = $?
   $RegPath = 'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown'

   if (Test-Path $RegPath) {
      $key = Get-ItemProperty -path $RegPath
      if ($key.bUpdater -ne $null) {
         $null = Remove-ItemProperty -Path $RegPath -Name 'bUpdater' -Force
      }
   }

   if ($Uninstalled) {
      Write-Host "Successfully uninstalled existing Adobe Acrobat Reader."
   }
   else {
      Throw "Failed to uninstall existing version of Adobe Acrobat Reader."
   }
}

# Reference: https://www.adobe.com/devnet-docs/acrobatetk/tools/AdminGuide/properties.html#command-line-example
$options = ' DISABLEDESKTOPSHORTCUT=1'
if ($PackageParameters.DesktopIcon) {
   $options = ''
   Write-Host 'You requested a desktop icon.' -ForegroundColor Cyan
}

if ($PackageParameters.NoUpdates) {
   $RegRoot = 'HKLM:\SOFTWARE\Policies'
   $RegSubFolders = ('Adobe\Acrobat Reader\DC\FeatureLockDown').split('\')
   for ($i = 0; $i -lt $RegSubFolders.count; $i++) {
      $RegPath = "$RegRoot\$($RegSubFolders[0..$i] -join '\')"
      if (-not (Test-Path $RegPath)) {
         $null = New-Item -Path $RegPath.TrimEnd($RegSubFolders[$i]) -Name $RegSubFolders[$i]
      }
   }
   $RegPath = "$RegRoot\$($RegSubFolders -join '\')"
   if (Test-Path $RegPath) {
      $null = New-ItemProperty -Path $RegPath -Name 'bUpdater' -PropertyType DWORD -Value 0 -Force
   }
   Write-Host 'You requested no Adobe updates.' -ForegroundColor Cyan
}

if ($PackageParameters.EnableUpdateService) {
   Write-Host 'You requested to enable the auto-update service.' -ForegroundColor Cyan
   if ($MUIinstalled) {
      if (Get-Service -Name 'AdobeARMservice' -ErrorAction SilentlyContinue) {
         $null = Set-Service -Name 'AdobeARMservice' -StartupType Automatic
         $null = Start-Service -Name 'AdobeARMservice'
      }
      else {
         Write-Warning 'The Adobe ARM update service is not available and is not installed on updates.'
      }
   }
}
else {
   $options += ' DISABLE_ARM_SERVICE_INSTALL=1'
   if (Get-Service -Name 'AdobeARMservice' -ErrorAction SilentlyContinue) {
      $null = Stop-Service -Name 'AdobeARMservice' -Force
      $null = Set-Service -Name 'AdobeARMservice' -StartupType Disabled
   }
}

if (-not $PackageParameters.UpdateMode) {
   $UpdateMode = 0
}
else { $UpdateMode = $PackageParameters.UpdateMode }

if ((0..4) -contains $UpdateMode) {
   Switch ($UpdateMode) {
      0 { Write-Host 'Configuring manual update checks and installs.' -ForegroundColor Cyan }
      1 { Write-Host 'You requested manual update checks and installs.' -ForegroundColor Cyan }
      2 { Write-Host 'You requested automatic update downloads and manual installs.' -ForegroundColor Cyan }
      3 { Write-Host 'You requested scheduled, automatic updates.' -ForegroundColor Cyan }
      4 { Write-Host 'You requested notifications but manual updates.' -ForegroundColor Cyan }
   }
   if ($MUIinstalled) {
      # This is the official setting based on the reference URL.
      $RegPath1 = 'HKLM:\SOFTWARE\Adobe\Adobe ARM\1.0\ARM\'
      if (Test-Path $RegPath1) {
         $null = New-ItemProperty -Path $RegPath1 -Name 'iCheckReader' -Value $UpdateMode -force
      }
      $GUID = '{' + $key[0].UninstallString.split('{')[-1]
      # This is the setting that actually causes a change in behavior.
      $RegPath2 = "HKLM:\SOFTWARE\Wow6432Node\Adobe\Adobe ARM\Legacy\Reader\$GUID"
      if (Test-Path $RegPath2) {
         $null = New-ItemProperty -Path $RegPath2 -Name 'Mode' -Value $UpdateMode -force
      }
   }
   else {
      $options += " UPDATE_MODE=$UpdateMode"
   }
}

$DownloadArgs = @{
   packageName         = "$env:ChocolateyPackageName (update)"
   FileFullPath        = Join-Path $env:TEMP "$env:ChocolateyPackageName.$env:ChocolateyPackageVersion.msp"
   url                 = $MUImspURL
   checksum            = $MUImspChecksum
   checksumType        = $allChecksumType
   url64bit            = $MUImspURL64
   checksum64          = $MUImspChecksum64
   checksumType64      = $allChecksumType
   GetOriginalFileName = $true
}
$mspPath = Get-ChocolateyWebFile @DownloadArgs

if ($PerformNewInstall) {
   $DownloadArgs = @{
      packageName         = $env:ChocolateyPackageName
      FileFullPath        = Join-Path $env:TEMP "$env:ChocolateyPackageName.$env:ChocolateyPackageVersion.installer.exe"
      url                 = $MUIurl
      checksum            = $MUIChecksum
      checksumType        = $allChecksumType
      url64bit            = $MUIurl64
      checksum64          = $MUIChecksum64
      checksumType64      = $allChecksumType
      GetOriginalFileName = $true
   }
   $MUIexePath = Get-ChocolateyWebFile @DownloadArgs

   $packageArgsEXE = @{
      packageName    = "$env:ChocolateyPackageName (installer)"
      fileType       = 'EXE'
      File           = $MUIexePath
      checksumType   = $allChecksumType
      silentArgs     = "/sAll /msi /norestart /quiet PATCH=`"$mspPath`" ALLUSERS=1 EULA_ACCEPT=YES $options" +
      " /L*v `"$env:TEMP\$env:chocolateyPackageName.$env:chocolateyPackageVersion.Install.log`""
      validExitCodes = @(0, 1000, 1101, 1603)
   }
   $exitCode = Install-ChocolateyInstallPackage @packageArgsEXE

   # check if the patch should be applied separately
   [array]$key = Get-UninstallRegistryKey -SoftwareName $DisplayName.replace(' Acrobat', ' Acrobat*')
   $InstalledVersion = $key[0].DisplayVersion.replace('.', '')
   $ApplyPatch = $InstalledVersion -lt $UpdaterVersion

   if ($exitCode -eq 1603) {
      Write-Warning "For code 1603, Adobe recommends to 'shut down Microsoft Office and all web browsers' and try again."
      Write-Warning 'The install log should provide more details about the encountered issue:'
      Write-Warning "   $env:TEMP\$env:chocolateyPackageName.$env:chocolateyPackageVersion.Install.log"
      Throw "Installation of $env:ChocolateyPackageName was unsuccessful."
   }
}

if ($ApplyPatch) {
   Write-Host 'Applying patch.'

   $UpdateArgs = @{
      Statements     = "/p `"$mspPath`" /norestart /quiet ALLUSERS=1 EULA_ACCEPT=YES $options" +
      " /L*v `"$env:TEMP\$env:chocolateyPackageName.$env:chocolateyPackageVersion.Update.log`""
      ExetoRun       = 'msiexec.exe'
      validExitCodes = @(0, 1603)
   }
   $exitCode = Start-ChocolateyProcessAsAdmin @UpdateArgs

   if ($exitCode -eq 1603) {
      Write-Warning "For code 1603, Adobe recommends to 'shut down Microsoft Office and all web browsers' and try again."
      Write-Warning 'The update log should provide more details about the encountered issue:'
      Write-Warning "   $env:TEMP\$env:chocolateyPackageName.$env:chocolateyPackageVersion.Update.log"
      Throw "Patching of $env:ChocolateyPackageName to the latest version was unsuccessful."
   }
}

if ($PackageParameters.NoUpdates -or $UpdateMode -lt 2) {
   Unregister-ScheduledTask 'Adobe Acrobat Update Task' -Confirm:$false -ErrorAction SilentlyContinue
}
