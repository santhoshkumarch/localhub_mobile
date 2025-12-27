#!/usr/bin/env python3
"""
Generate app icons for Flutter from SVG
Requires: pip install cairosvg pillow
"""

import os
import io
from pathlib import Path
from PIL import Image

# SVG content
svg_content = '''<svg viewBox="0 0 192 192" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FF4444;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#CC0000;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="accentGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FFD700;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#FFA500;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="192" height="192" rx="45" fill="url(#bgGradient)"/>
  <circle cx="96" cy="70" r="28" fill="white" opacity="0.95"/>
  <circle cx="65" cy="105" r="22" fill="white" opacity="0.9"/>
  <circle cx="127" cy="105" r="22" fill="white" opacity="0.9"/>
  <line x1="96" y1="98" x2="75" y2="120" stroke="url(#accentGradient)" stroke-width="3" stroke-linecap="round"/>
  <line x1="96" y1="98" x2="117" y2="120" stroke="url(#accentGradient)" stroke-width="3" stroke-linecap="round"/>
  <path d="M 96 140 L 85 155 L 107 155 Z" fill="url(#accentGradient)"/>
</svg>'''

# Icon sizes for Android
android_sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

# iOS sizes
ios_sizes = {
    '20x20': 20,
    '29x29': 29,
    '40x40': 40,
    '58x58': 58,
    '60x60': 60,
    '76x76': 76,
    '80x80': 80,
    '87x87': 87,
    '120x120': 120,
    '152x152': 152,
    '167x167': 167,
    '180x180': 180,
    '1024x1024': 1024,
}

try:
    import cairosvg
    
    # Generate Android icons
    print("Generating Android icons...")
    for folder, size in android_sizes.items():
        svg_bytes = svg_content.encode('utf-8')
        png_bytes = cairosvg.svg2png(bytestring=svg_bytes, output_width=size, output_height=size)
        
        output_path = f'android/app/src/main/res/{folder}/ic_launcher.png'
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        with open(output_path, 'wb') as f:
            f.write(png_bytes)
        print(f"  ✓ {output_path} ({size}x{size})")
    
    # Generate iOS icons
    print("\nGenerating iOS icons...")
    for size_name, size in ios_sizes.items():
        svg_bytes = svg_content.encode('utf-8')
        png_bytes = cairosvg.svg2png(bytestring=svg_bytes, output_width=size, output_height=size)
        
        output_path = f'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-{size_name}.png'
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        with open(output_path, 'wb') as f:
            f.write(png_bytes)
        print(f"  ✓ {output_path} ({size}x{size})")
    
    print("\n✅ All icons generated successfully!")
    
except ImportError:
    print("cairosvg not installed. Installing...")
    os.system('pip install cairosvg pillow')
    print("Please run this script again.")
