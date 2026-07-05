param (
    [string]$Url = "https://mykottakkal.vercel.app"
)

Write-Host "Generating QR Code for: $Url"
$encodedUrl = [uri]::EscapeDataString($Url)
$qrApiUrl = "https://api.qrserver.com/v1/create-qr-code/?size=500x500&data=$encodedUrl"
$outputPath = Join-Path $PSScriptRoot "mykottakkal_qr.png"

try {
    Invoke-WebRequest -Uri $qrApiUrl -OutFile $outputPath -UseBasicParsing
    Write-Host "Success! QR Code saved to: $outputPath"
} catch {
    Write-Error "Failed to generate QR Code: $_"
}
