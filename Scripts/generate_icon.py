#!/usr/bin/env python3
"""
Générateur d'icône personnalisée pour Glitcho
Design : Glitch style avec effet de verre violet
"""

from PIL import Image, ImageDraw, ImageFilter
import math

def create_glass_icon(size=1024):
    """Crée une icône avec effet de verre et bulles de chat style Twitch"""
    
    # Créer l'image avec transparence
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Couleurs Twitch authentiques
    twitch_purple = (145, 70, 255)      # #9146FF - Violet Twitch officiel
    bg_gradient_start = (145, 70, 255)  # Violet Twitch
    bg_gradient_end = (100, 50, 200)    # Violet plus foncé
    glass_overlay = (160, 100, 255, 100)  # Violet semi-transparent
    bubble_color = (255, 255, 255, 245)   # Blanc pour les bulles
    
    # Marge
    margin = int(size * 0.08)
    inner_size = size - (margin * 2)
    
    # 1. Fond avec dégradé violet
    for y in range(size):
        ratio = y / size
        r = int(bg_gradient_start[0] * (1 - ratio) + bg_gradient_end[0] * ratio)
        g = int(bg_gradient_start[1] * (1 - ratio) + bg_gradient_end[1] * ratio)
        b = int(bg_gradient_start[2] * (1 - ratio) + bg_gradient_end[2] * ratio)
        draw.rectangle([(margin, margin + y), (size - margin, margin + y + 1)], 
                      fill=(r, g, b, 255))
    
    # 2. Forme arrondie de base
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = int(size * 0.22)  # Coins arrondis
    mask_draw.rounded_rectangle(
        [(margin, margin), (size - margin, size - margin)],
        radius=corner_radius,
        fill=255
    )
    
    # Appliquer le masque
    img.putalpha(mask)
    
    # 3. Créer un calque pour l'effet de verre
    glass_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    glass_draw = ImageDraw.Draw(glass_layer)
    
    # Highlight en haut (effet de verre)
    for i in range(int(inner_size * 0.4)):
        alpha = int(80 * (1 - i / (inner_size * 0.4)))
        glass_draw.ellipse(
            [(margin, margin - int(inner_size * 0.1) + i), 
             (size - margin, margin + int(inner_size * 0.3) + i)],
            fill=(255, 255, 255, alpha)
        )
    
    # Fusionner l'effet de verre
    img = Image.alpha_composite(img, glass_layer)
    
    # 4. Créer le Glitch style Twitch (formes géométriques angulaires)
    symbol_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    symbol_draw = ImageDraw.Draw(symbol_layer)
    
    center_x = size // 2
    center_y = size // 2
    
    # Taille de base pour le glitch
    glitch_size = int(size * 0.42)
    
    # Carré principal (corps du Glitch)
    main_w = int(glitch_size * 0.85)
    main_h = int(glitch_size * 1.0)
    main_x = center_x - main_w // 2
    main_y = center_y - main_h // 2 - int(glitch_size * 0.05)
    
    # Ombre du corps principal
    shadow_offset = int(size * 0.015)
    symbol_draw.rounded_rectangle(
        [(main_x + shadow_offset, main_y + shadow_offset),
         (main_x + main_w + shadow_offset, main_y + main_h + shadow_offset)],
        radius=int(main_w * 0.15),
        fill=(0, 0, 0, 60)
    )
    
    # Corps principal blanc
    symbol_draw.rounded_rectangle(
        [(main_x, main_y),
         (main_x + main_w, main_y + main_h)],
        radius=int(main_w * 0.15),
        fill=bubble_color
    )
    
    # Découpes carrées ("yeux" du Glitch) - style Twitch authentique
    eye_w = int(main_w * 0.25)
    eye_h = int(main_h * 0.22)
    eye_spacing = int(main_w * 0.12)
    eye_y = main_y + int(main_h * 0.28)
    
    # Oeil gauche (carré avec coins légèrement arrondis)
    left_eye_x = main_x + int(main_w * 0.2)
    symbol_draw.rounded_rectangle(
        [(left_eye_x, eye_y),
         (left_eye_x + eye_w, eye_y + eye_h)],
        radius=int(eye_w * 0.12),
        fill=bg_gradient_start  # Violet Twitch
    )
    
    # Oeil droit
    right_eye_x = main_x + main_w - int(main_w * 0.2) - eye_w
    symbol_draw.rounded_rectangle(
        [(right_eye_x, eye_y),
         (right_eye_x + eye_w, eye_y + eye_h)],
        radius=int(eye_w * 0.12),
        fill=bg_gradient_start
    )
    
    # Bouche (rectangle horizontal)
    mouth_w = int(main_w * 0.45)
    mouth_h = int(main_h * 0.15)
    mouth_x = main_x + (main_w - mouth_w) // 2
    mouth_y = main_y + int(main_h * 0.65)
    
    symbol_draw.rounded_rectangle(
        [(mouth_x, mouth_y),
         (mouth_x + mouth_w, mouth_y + mouth_h)],
        radius=int(mouth_h * 0.3),
        fill=bg_gradient_start
    )
    
    # Bras/Jambes carrés (extensions latérales en bas)
    limb_size = int(glitch_size * 0.22)
    limb_y = main_y + main_h - int(limb_size * 1.5)
    
    # Bras gauche (carré décalé)
    left_limb_x = main_x - int(limb_size * 0.5)
    symbol_draw.rounded_rectangle(
        [(left_limb_x + shadow_offset, limb_y + shadow_offset),
         (left_limb_x + limb_size + shadow_offset, limb_y + limb_size + shadow_offset)],
        radius=int(limb_size * 0.15),
        fill=(0, 0, 0, 60)
    )
    symbol_draw.rounded_rectangle(
        [(left_limb_x, limb_y),
         (left_limb_x + limb_size, limb_y + limb_size)],
        radius=int(limb_size * 0.15),
        fill=bubble_color
    )
    
    # Bras droit (carré décalé)
    right_limb_x = main_x + main_w - int(limb_size * 0.5)
    symbol_draw.rounded_rectangle(
        [(right_limb_x + shadow_offset, limb_y + shadow_offset),
         (right_limb_x + limb_size + shadow_offset, limb_y + limb_size + shadow_offset)],
        radius=int(limb_size * 0.15),
        fill=(0, 0, 0, 60)
    )
    symbol_draw.rounded_rectangle(
        [(right_limb_x, limb_y),
         (right_limb_x + limb_size, limb_y + limb_size)],
        radius=int(limb_size * 0.15),
        fill=bubble_color
    )
    
    # Fusionner le symbole
    img = Image.alpha_composite(img, symbol_layer)
    
    # 5. Bordure subtile
    border_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    border_draw = ImageDraw.Draw(border_layer)
    border_draw.rounded_rectangle(
        [(margin, margin), (size - margin, size - margin)],
        radius=corner_radius,
        outline=(255, 255, 255, 40),
        width=int(size * 0.005)
    )
    img = Image.alpha_composite(img, border_layer)
    
    return img

def generate_iconset():
    """Génère toutes les tailles d'icônes pour macOS"""
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    print("🎨 Génération de l'icône Glitcho...")
    
    # Créer l'icône de base en haute résolution
    base_icon = create_glass_icon(1024)
    
    # Créer le dossier iconset
    import os
    iconset_path = "Resources/AppIcon.iconset"
    os.makedirs(iconset_path, exist_ok=True)
    
    # Générer toutes les tailles
    for size in sizes:
        # Version normale
        icon = base_icon.resize((size, size), Image.Resampling.LANCZOS)
        icon.save(f"{iconset_path}/icon_{size}x{size}.png")
        print(f"  ✓ {size}x{size}")
        
        # Version @2x
        if size <= 512:
            icon_2x = base_icon.resize((size * 2, size * 2), Image.Resampling.LANCZOS)
            icon_2x.save(f"{iconset_path}/icon_{size}x{size}@2x.png")
            print(f"  ✓ {size}x{size}@2x")
    
    # Sauvegarder aussi la version PNG pour référence
    base_icon.save("Resources/AppIcon.png")
    print(f"  ✓ AppIcon.png (preview)")
    
    print("\n✅ Icône générée avec succès!")
    print(f"📁 Fichiers dans: {iconset_path}/")
    print("\n🔧 Pour générer le .icns, exécutez:")
    print("   iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns")

if __name__ == "__main__":
    try:
        generate_iconset()
    except ImportError:
        print("❌ Erreur: Pillow n'est pas installé")
        print("📦 Installez-le avec: pip3 install Pillow")
        exit(1)
