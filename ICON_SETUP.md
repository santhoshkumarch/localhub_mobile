# Namma Chennai - App Icon Setup

## Overview
The app icon has been created with a red gradient background and white community circles, representing the social nature of the app. The design uses the app's primary color scheme (red #FF4444 to #CC0000) with gold accents.

## Icon Design
- **Background**: Red gradient (from #FF4444 to #CC0000) with rounded corners
- **Main Element**: Three white circles representing community/people connection
- **Accent**: Gold/orange connection lines and speech bubble tail
- **Style**: Modern, clean, and recognizable at all sizes

## Files Generated

### Android Icons
Located in `android/app/src/main/res/`:
- `mipmap-mdpi/ic_launcher.png` (48x48) + ic_launcher_round.png
- `mipmap-hdpi/ic_launcher.png` (72x72) + ic_launcher_round.png
- `mipmap-xhdpi/ic_launcher.png` (96x96) + ic_launcher_round.png
- `mipmap-xxhdpi/ic_launcher.png` (144x144) + ic_launcher_round.png
- `mipmap-xxxhdpi/ic_launcher.png` (192x192) + ic_launcher_round.png

### iOS Icons
Located in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`:
- Icon-App-20x20@1x.png through Icon-App-1024x1024@1x.png
- All required scales for iPhone and iPad

### App Store Icons
- `assets/images/app_icon_512.png` - 512x512 for Google Play Store and App Store

### Source Files
- `assets/images/app_icon.svg` - SVG source (editable)
- `assets/images/app_icon_192.png` - Base 192x192 PNG

## Configuration Files
- `android/app/src/main/AndroidManifest.xml` - Updated with app name and icon references
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json` - iOS icon configuration

## How to Apply the Icons

### For Android
1. Run `flutter clean` to clear build cache
2. Run `flutter pub get`
3. Run `flutter run` to build and test
4. The new icon should appear on your device/emulator home screen

### For iOS
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `flutter run` or build in Xcode
4. The new icon will appear on your device

### For App Store Submission
- **Google Play Store**: Use `assets/images/app_icon_512.png` (512x512)
- **Apple App Store**: Use the iOS icons from `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Troubleshooting

If you still see the default Flutter icon:
1. Delete the build folder: `flutter clean`
2. Delete Android build cache: `rm -r android/build` (or `rmdir /s android\build` on Windows)
3. Rebuild: `flutter run`

## Customization
To modify the icon design:
1. Edit `assets/images/app_icon.svg` with any SVG editor
2. Run `create_all_icons.ps1` to regenerate all sizes
3. Run `flutter clean && flutter run`

## Icon Sizes Reference
- **Android**: Uses density-specific folders (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- **iOS**: Uses scale factors (@1x, @2x, @3x) for different device resolutions
- **App Store**: 512x512 PNG for both Google Play and Apple App Store
