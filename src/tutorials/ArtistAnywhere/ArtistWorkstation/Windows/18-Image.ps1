Set-Location -Path "C:\Users\Default\Downloads"

$keyName = "OOBE"
$keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
New-Item –Path $keyPath –Name $keyName -Force
New-ItemProperty -Path "$keyPath\$keyName" -PropertyType "DWORD" -Name "DisablePrivacyExperience" -Value 1 -Force

DISM /Online /Enable-Feature /FeatureName:ClientForNFS-Infrastructure /All
New-ItemProperty -Path HKLM:\\SOFTWARE\\Microsoft\\ClientForNFS\\CurrentVersion\\Default -Name AnonymousUid -PropertyType DWord -Value 0
New-ItemProperty -Path HKLM:\\SOFTWARE\\Microsoft\\ClientForNFS\\CurrentVersion\\Default -Name AnonymousGid -PropertyType DWord -Value 0
net stop nfsclnt
net stop nfsrdr
net start nfsrdr
net start nfsclnt

$fileName = "452.57_grid_win10_server2016_server2019_64bit_international.exe"
#$fileName = "AMD-Azure-NVv4-Driver-20Q1-Hotfix3.exe"
$downloadUrl = "https://bit1.blob.core.windows.net/bin/Graphics"
Invoke-WebRequest -OutFile $fileName -Uri $downloadUrl/$fileName
Start-Process -FilePath $fileName -ArgumentList "/s" -Wait