#!/usr/bin/env python3
"""
Nyaya Saathi - Logo & App Icon Update Script
-------------------------------------------
Usage:
    python scripts/update_logo.py [path_to_new_logo_image]

Example:
    python scripts/update_logo.py assets/images/app_logo.png
    python scripts/update_logo.py my_new_logo.png

This script automatically:
1. Generates circular transparent Flutter asset images (assets/images/app_logo.png & logo.png)
2. Runs flutter_launcher_icons to update Android adaptive icons, iOS app icon, and Web icons
3. Runs flutter_native_splash to generate native Android 12+ and iOS launch splash screens
"""

import os
import sys
import shutil
import subprocess
from PIL import Image, ImageDraw, ImageOps

# Set stdout/stderr encoding to UTF-8 for cross-platform terminal compatibility
if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except Exception:
        pass

# Base project directory
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Target asset destinations
ASSET_LOGO = os.path.join(PROJECT_ROOT, "assets", "images", "app_logo.png")
ASSET_SPLASH_LOGO = os.path.join(PROJECT_ROOT, "assets", "images", "splash_logo.png")

def create_circular_logo(source_path, target_path, size=(512, 512)):
    """Create a high-resolution circular masked logo PNG."""
    os.makedirs(os.path.dirname(target_path), exist_ok=True)
    with Image.open(source_path) as img:
        img = img.convert("RGBA")
        fitted = ImageOps.fit(img, size, Image.Resampling.LANCZOS, centering=(0.5, 0.5))

        mask = Image.new("L", size, 0)
        draw = ImageDraw.Draw(mask)
        draw.ellipse((0, 0, size[0], size[1]), fill=255)

        circular_logo = Image.new("RGBA", size, (0, 0, 0, 0))
        circular_logo.paste(fitted, (0, 0), mask=mask)
        circular_logo.save(target_path, "PNG")

    rel_path = os.path.relpath(target_path, PROJECT_ROOT)
    print(f"  [OK] Created circular logo: {rel_path} ({size[0]}x{size[1]})")

def create_splash_logo(source_path, target_path, canvas_size=(512, 512), logo_size=(320, 320)):
    """Create a padded transparent logo PNG suitable for Android 12+ native splash screen."""
    os.makedirs(os.path.dirname(target_path), exist_ok=True)
    with Image.open(source_path) as img:
        img = img.convert("RGBA")
        fitted = ImageOps.fit(img, logo_size, Image.Resampling.LANCZOS, centering=(0.5, 0.5))

        mask = Image.new("L", logo_size, 0)
        draw = ImageDraw.Draw(mask)
        draw.ellipse((0, 0, logo_size[0], logo_size[1]), fill=255)

        logo_masked = Image.new("RGBA", logo_size, (0, 0, 0, 0))
        logo_masked.paste(fitted, (0, 0), mask=mask)

        canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
        offset = ((canvas_size[0] - logo_size[0]) // 2, (canvas_size[1] - logo_size[1]) // 2)
        canvas.paste(logo_masked, offset, logo_masked)
        canvas.save(target_path, "PNG")

    rel_path = os.path.relpath(target_path, PROJECT_ROOT)
    print(f"  [OK] Created padded splash logo: {rel_path} ({canvas_size[0]}x{canvas_size[1]}, icon {logo_size[0]}x{logo_size[1]})")

def update_logo(source_path):
    if not os.path.exists(source_path):
        print(f"Error: Source image not found at '{source_path}'")
        sys.exit(1)

    print("==========================================")
    print(" Nyaya Saathi Logo & Native Splash Updater")
    print(f" Source Image: {source_path}")
    print("==========================================\n")

    try:
        # 1. Prepare circular Flutter asset images
        print("1. Generating circular Flutter asset images...")
        create_circular_logo(source_path, ASSET_LOGO, (512, 512))
        create_splash_logo(source_path, ASSET_SPLASH_LOGO, (512, 512), (320, 320))

        # 2. Run flutter_launcher_icons
        print("\n2. Running 'dart run flutter_launcher_icons'...")
        res_launcher = subprocess.run(["dart", "run", "flutter_launcher_icons"], cwd=PROJECT_ROOT, shell=True)
        if res_launcher.returncode == 0:
            print("  [OK] flutter_launcher_icons generated adaptive launcher icons successfully.")
        else:
            print("  [WARNING] flutter_launcher_icons command exited with non-zero code.")

        # 3. Run flutter_native_splash
        print("\n3. Running 'dart run flutter_native_splash:create'...")
        res_splash = subprocess.run(["dart", "run", "flutter_native_splash:create"], cwd=PROJECT_ROOT, shell=True)
        if res_splash.returncode == 0:
            print("  [OK] flutter_native_splash generated native splash screen successfully.")
        else:
            print("  [WARNING] flutter_native_splash command exited with non-zero code.")

        print("\n==========================================")
        print(" SUCCESS: App icons and splash screen updated!")
        print("==========================================\n")

    except Exception as e:
        print(f"\n[ERROR] Error processing image: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        source_image = sys.argv[1]
    elif os.path.exists(ASSET_LOGO):
        source_image = ASSET_LOGO
    else:
        print("Usage: python scripts/update_logo.py <path_to_new_image>")
        sys.exit(1)

    update_logo(source_image)
