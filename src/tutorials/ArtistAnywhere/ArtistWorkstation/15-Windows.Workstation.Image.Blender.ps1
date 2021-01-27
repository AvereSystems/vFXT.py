$directoryName = "Blender"
$localDirectory = "C:\Users\Public\Downloads\$directoryName"

New-Item -ItemType "Directory" -Path $localDirectory
Set-Location -Path $localDirectory

$downloadUrl = "https://mediasolutions.blob.core.windows.net/bin/Blender"

$fileName = "blender-2.91.0-windows64.msi"
Invoke-WebRequest -OutFile $fileName -Uri $downloadUrl/$fileName

msiexec /i $fileName /quiet /qn /norestart /log $fileName.Replace(".msi", ".log")