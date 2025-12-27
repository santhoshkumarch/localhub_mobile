# PowerShell script to generate all app icons from base image
# This script resizes the base 192x192 icon to all required sizes for Android and iOS

Add-Type -AssemblyName System.Drawing

function Resize-Image {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [int]$Width,
        [int]$Height
    )
    
    $source = [System.Drawing.Image]::FromFile($SourcePath)
    $bitmap = New-Object System.Drawing.Bitmap($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($source, 0, 0, $Width, $Height)
    
    $bitmap.Save($DestinationPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $graphics.Dispose()
    $bitmap.Dispose()
    $source.Dispose()
}

$baseIcon = "assets/images/app_icon_192.png"

if (-not (Test-Path $baseIcon)) {
    Write-Host "❌ Base icon not found at $baseIcon"
    exit 1
}

Write-Host "Generating Android icons..."

# Android icon sizes
$androidSizes = @{
    "android/app/src/main/res/mipmap-mdpi/ic_launcher.png" = 48
    "android/app/src/main/res/mipmap-hdpi/ic_launcher.png" = 72
    "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png" = 96
    "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png" = 144
    "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" = 192
}

foreach ($path in $androidSizes.Keys) {
    $size = $androidSizes[$path]
    $dir = Split-Path $path
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Resize-Image -SourcePath $baseIcon -DestinationPath $path -Width $size -Height $size
    Write-Host "  [OK] $path ($size x $size)"
}

Write-Host ""
Write-Host "Generating iOS icons..."

# iOS icon sizes
$iosSizes = @{
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-20x20.png" = 20
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-40x40.png" = 40
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-58x58.png" = 58
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-60x60.png" = 60
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-76x76.png" = 76
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-80x80.png" = 80
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-87x87.png" = 87
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-120x120.png" = 120
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-152x152.png" = 152
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-167x167.png" = 167
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-180x180.png" = 180
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-1024x1024.png" = 1024
}

foreach ($path in $iosSizes.Keys) {
    $size = $iosSizes[$path]
    $dir = Split-Path $path
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Resize-Image -SourcePath $baseIcon -DestinationPath $path -Width $size -Height $size
    Write-Host "  [OK] $path ($size x $size)"
}

Write-Host ""
Write-Host "All icons generated successfully!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. For Android: Icons are ready in android/app/src/main/res/mipmap-*/"
Write-Host "  2. For iOS: Icons are ready in ios/Runner/Assets.xcassets/AppIcon.appiconset/"
Write-Host "  3. Run: flutter clean && flutter pub get"
Write-Host "  4. Run: flutter run"
