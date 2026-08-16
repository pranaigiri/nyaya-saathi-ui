#!/usr/bin/env python3
"""
Nyaya Saathi - Logo, App Icon & Notification Icon Generator
---------------------------------------------------------
Usage:
    python scripts/update_logo.py

Optional:
    python scripts/update_logo.py [path_to_app_logo] [path_to_notification_logo]

This script automatically:
1. Generates circular Flutter asset images (assets/images/app_logo.png)
2. Generates padded native splash logo (assets/images/splash_logo.png)
3. Generates high-quality Android notification icons across all density folders
   (drawable-mdpi, drawable-hdpi, drawable-xhdpi, drawable-xxhdpi, drawable-xxxhdpi, drawable)
4. Runs flutter_launcher_icons to generate Android mipmap, iOS AppIcon, and Web icons
5. Runs flutter_native_splash to sync native splash screens
"""

import os
import sys
import subprocess
from PIL import Image, ImageOps

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
ASSET_NOTIFICATION_LOGO = os.path.join(PROJECT_ROOT, "assets", "images", "app_logo_transparent.png")
ASSET_SPLASH_LOGO = os.path.join(PROJECT_ROOT, "assets", "images", "splash_logo.png")

# Android drawable destinations
RES_DIR = os.path.join(PROJECT_ROOT, "android", "app", "src", "main", "res")

NOTIFICATION_ICON_CONFIGS = [
    ("drawable", 48, 40),
    ("drawable-mdpi", 24, 20),
    ("drawable-hdpi", 36, 30),
    ("drawable-xhdpi", 48, 40),
    ("drawable-xxhdpi", 72, 60),
    ("drawable-xxxhdpi", 96, 80),
]

def create_circular_logo(source_path, target_path, size=(512, 512)):
    """Create a high-resolution circular masked logo PNG if needed."""
    os.makedirs(os.path.dirname(target_path), exist_ok=True)
    with Image.open(source_path) as img:
        img = img.convert("RGBA")
        fitted = ImageOps.fit(img, size, Image.Resampling.LANCZOS, centering=(0.5, 0.5))

        # Check if image already has a transparent circular boundary
        bbox = fitted.getbbox()
        if bbox:
            fitted.save(target_path, "PNG")
        else:
            mask = Image.new("L", size, 0)
            from PIL import ImageDraw
            draw = ImageDraw.Draw(mask)
            draw.ellipse((0, 0, size[0], size[1]), fill=255)
            circular_logo = Image.new("RGBA", size, (0, 0, 0, 0))
            circular_logo.paste(fitted, (0, 0), mask=mask)
            circular_logo.save(target_path, "PNG")

    rel_path = os.path.relpath(target_path, PROJECT_ROOT)
    print(f"  [OK] Processed app logo: {rel_path} ({size[0]}x{size[1]})")

def create_splash_logo(source_path, target_path, canvas_size=(512, 512), logo_size=(320, 320)):
    """Create a padded transparent logo PNG suitable for Android 12+ native splash screen."""
    os.makedirs(os.path.dirname(target_path), exist_ok=True)
    with Image.open(source_path) as img:
        img = img.convert("RGBA")
        fitted = ImageOps.fit(img, logo_size, Image.Resampling.LANCZOS, centering=(0.5, 0.5))

        canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
        offset = ((canvas_size[0] - logo_size[0]) // 2, (canvas_size[1] - logo_size[1]) // 2)
        canvas.paste(fitted, offset, fitted)
        canvas.save(target_path, "PNG")

    rel_path = os.path.relpath(target_path, PROJECT_ROOT)
    print(f"  [OK] Created padded splash logo: {rel_path} ({canvas_size[0]}x{canvas_size[1]}, icon {logo_size[0]}x{logo_size[1]})")

def generate_notification_icons(source_path):
    """Generate Android notification icons across all density folders."""
    if not os.path.exists(source_path):
        print(f"  [WARNING] Notification source image not found at '{source_path}', skipping.")
        return

    with Image.open(source_path) as img:
        img = img.convert("RGBA")
        bbox = img.getbbox()
        if bbox:
            cropped = img.crop(bbox)
        else:
            cropped = img

        w, h = cropped.size

        for folder_name, canvas_size, target_content_size in NOTIFICATION_ICON_CONFIGS:
            out_folder = os.path.join(RES_DIR, folder_name)
            os.makedirs(out_folder, exist_ok=True)
            out_file = os.path.join(out_folder, "ic_notification.png")

            # Maintain aspect ratio
            if w > h:
                new_w = target_content_size
                new_h = max(1, int(h * (target_content_size / w)))
            else:
                new_h = target_content_size
                new_w = max(1, int(w * (target_content_size / h)))

            resized = cropped.resize((new_w, new_h), Image.Resampling.LANCZOS)

            canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
            offset_x = (canvas_size - new_w) // 2
            offset_y = (canvas_size - new_h) // 2
            canvas.paste(resized, (offset_x, offset_y), resized)

            canvas.save(out_file, "PNG")
            rel_file = os.path.relpath(out_file, PROJECT_ROOT)
            print(f"  [OK] Generated notification icon: {rel_file} ({canvas_size}x{canvas_size} canvas, {new_w}x{new_h} glyph)")

def update_all_icons(app_logo_path, notif_logo_path):
    print("=====================================================")
    print(" Nyaya Saathi - Logo, App & Notification Icon Sync")
    print(f" App Logo Base:         {app_logo_path}")
    print(f" Notification Icon Base: {notif_logo_path}")
    print("=====================================================\n")

    # 1. Generate Notification Icons
    print("1. Generating Android notification icons for all densities...")
    generate_notification_icons(notif_logo_path)

    # 2. Prepare Flutter asset images & Splash logo
    print("\n2. Preparing asset images & splash logo...")
    create_splash_logo(app_logo_path, ASSET_SPLASH_LOGO, (512, 512), (320, 320))

    # 3. Run flutter_launcher_icons
    print("\n3. Running 'dart run flutter_launcher_icons'...")
    res_launcher = subprocess.run(["dart", "run", "flutter_launcher_icons"], cwd=PROJECT_ROOT, shell=True)
    if res_launcher.returncode == 0:
        print("  [OK] flutter_launcher_icons generated adaptive launcher icons successfully.")
    else:
        print("  [WARNING] flutter_launcher_icons command exited with non-zero code.")

    # 4. Run flutter_native_splash
    print("\n4. Running 'dart run flutter_native_splash:create'...")
    res_splash = subprocess.run(["dart", "run", "flutter_native_splash:create"], cwd=PROJECT_ROOT, shell=True)
    if res_splash.returncode == 0:
        print("  [OK] flutter_native_splash generated native splash screen successfully.")
    else:
        print("  [WARNING] flutter_native_splash command exited with non-zero code.")

    print("\n=====================================================")
    print(" SUCCESS: All app icons & notification icons synced!")
    print("=====================================================\n")

if __name__ == "__main__":
    app_logo = sys.argv[1] if len(sys.argv) > 1 else ASSET_LOGO
    notif_logo = sys.argv[2] if len(sys.argv) > 2 else ASSET_NOTIFICATION_LOGO
    update_all_icons(app_logo, notif_logo)
