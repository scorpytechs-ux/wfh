$msixPath = "d:\shubham\wfh\installment_management_system\build\windows\x64\runner\Release\installment_management_system.msix"
$cert = (Get-AuthenticodeSignature $msixPath).SignerCertificate
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()
Add-AppxPackage -Path $msixPath
Write-Host "Installation Complete! You can close this window now."
Start-Sleep -Seconds 10
