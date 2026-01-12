# 🚀 Glitcho - Installation rapide

## Prérequis

✅ **macOS 13.0 ou supérieur**

## Lancer l'application

```bash
# Méthode 1 : Swift directement
swift run

# Méthode 2 : Compiler l'app
./Scripts/make_app.sh
open Build/Glitcho.app
```

## 🎯 Fonctionnalités

### ✨ Interface Glass modernisée
- Design glass-morphic avec effets de flou
- Sidebar personnalisée avec navigation fluide
- Animations et effets hover
- Badge "LIVE" pour les chaînes en direct

### 🚫 Blocage de publicités multi-couches
L'application intègre un système de blocage avancé :
- ✅ **Blocage réseau** : 40+ domaines publicitaires bloqués
- ✅ **Filtrage CSS** : 80+ sélecteurs pour masquer les pubs
- ✅ **Filtrage M3U8** : Suppression des segments publicitaires
- ✅ **Surveillance active** : Détection en temps réel
- ✅ **Blocage dynamique** : Scripts et iframes publicitaires interceptés

### 📺 Interface épurée
- **Navigation** : Sidebar personnalisée avec chaînes suivies
- **Lecteur** : Intégration Twitch optimisée
- **Contrôles** : Recherche, navigation fluide

## 📖 Documentation complète

- **Guide utilisateur** : [QUICKSTART.md](QUICKSTART.md)
- **Changelog** : [CHANGELOG.md](CHANGELOG.md)

## ⚡ Utilisation rapide

1. Lance l'app
2. Connecte-toi à ton compte Twitch (optionnel)
3. Clique sur une chaîne dans la sidebar
4. Profite du stream **sans pubs** !

## 🔧 Si ça ne fonctionne pas

```bash
# Recompiler l'app
./Scripts/make_app.sh

# Vérifier les permissions
xattr -cr Build/Twitch.app
```

## 🎮 Fonctionnalités à venir

- [ ] Sélecteur de qualité vidéo
- [ ] Support multi-fenêtres
- [ ] Picture-in-Picture
- [ ] Thèmes personnalisables
