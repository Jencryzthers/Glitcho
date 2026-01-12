# 🚀 Glitcho - Guide de démarrage rapide

## Installation

### Option 1 : Utiliser l'app pré-compilée
L'application est déjà construite et prête à l'emploi :
```bash
open Build/Glitcho.app
```

### Option 2 : Recompiler depuis les sources
Si vous avez modifié le code :
```bash
./Scripts/make_app.sh
open Build/Twitch.app
```

## Première utilisation

### 1. Lancer l'application
Double-cliquez sur `Glitcho.app` ou utilisez la commande `open Build/Glitcho.app`

### 2. Se connecter à Twitch
- Cliquez sur le bouton **"Log in"** violet dans la sidebar
- Entrez vos identifiants Twitch
- L'application mémorisera votre session

### 3. Navigation
**Sidebar gauche :**
- **Logo** : Retour à l'accueil
- **Section Explore** : Parcourir les catégories
  - Home, Following, Browse, Categories, Music, Esports, Drops
- **Section Following** : Vos chaînes suivies en direct
  - Badge "LIVE" rouge pour les streamers actifs

**Barre de recherche :**
- Recherchez des streamers, jeux ou catégories
- Appuyez sur Entrée pour lancer la recherche
- Cliquez sur le ⓧ pour effacer

**Boutons profil :**
- ⚙️ **Settings** : Paramètres Twitch
- ➡️ **Log out** : Déconnexion

## Fonctionnalités de blocage de publicités

### Comment ça fonctionne ?
L'application intègre un système de blocage multi-couches :

1. **Blocage réseau** : Plus de 40 domaines publicitaires bloqués (Google Ads, Amazon, Facebook Pixel, etc.)
2. **Filtrage CSS** : Plus de 80 sélecteurs pour masquer les éléments publicitaires
3. **Filtrage M3U8** : Suppression des segments publicitaires des playlists vidéo
4. **Surveillance active** : Détection et suppression en temps réel des éléments publicitaires
5. **Blocage dynamique** : Intercepte les scripts et iframes publicitaires avant leur chargement

### Console de débogage (optionnel)
Pour voir les logs de blocage :
1. Ouvrez Safari Developer Tools (nécessite d'activer le mode développeur)
2. Connectez-vous au WebView de l'app
3. Recherchez les messages `[Enhanced Adblock]` dans la console

Messages typiques :
- ✅ `[Enhanced Adblock] Initialized with uBlock-inspired rules` - Le bloqueur est actif
- 🚫 `[Enhanced Adblock] Blocked domain: doubleclick.net` - Un domaine pub bloqué
- ⚠️ `[Enhanced Adblock] Removed existing script` - Script publicitaire supprimé

## Raccourcis clavier

| Raccourci | Action |
|-----------|--------|
| `Cmd + R` | Recharger la page |
| `Cmd + [` | Page précédente |
| `Cmd + ]` | Page suivante |
| `Cmd + Clic` | Ouvrir dans un nouvel onglet (limité) |

## Personnalisation

### Modifier l'UI
Tous les éléments visuels peuvent être personnalisés dans `Sources/Twitch/ContentView.swift` :

**Couleurs du thème :**
```swift
// Ligne ~593-596 dans GlassBackground
Color(red: 0.08, green: 0.12, blue: 0.18),  // Bleu foncé
Color(red: 0.14, green: 0.08, blue: 0.2),   // Violet foncé
Color(red: 0.06, green: 0.18, blue: 0.16)   // Vert foncé
```

**Opacité du verre :**
```swift
// Dans GlassCard (ligne ~338-340)
.fill(Color.white.opacity(0.08))  // Fond
.stroke(Color.white.opacity(0.18)) // Bordure
```

**Bouton Login gradient :**
```swift
// Ligne ~305-306 dans AccountSection
Color(red: 0.58, green: 0.25, blue: 0.82),  // Violet Twitch clair
Color(red: 0.48, green: 0.18, blue: 0.72)   // Violet Twitch foncé
```

### Ajouter des domaines à bloquer
Dans `Sources/Twitch/WebViewStore.swift`, recherchez `blockedDomains` :
```javascript
const blockedDomains = [
  'doubleclick.net',
  'googlesyndication.com',
  // Ajoutez vos domaines ici
];
```

## Dépannage

### L'application ne se lance pas
```bash
# Vérifier les permissions
xattr -cr Build/Twitch.app

# Recompiler
./Scripts/make_app.sh
```

### Le blocage de pub ne fonctionne pas
- Le blocage est côté client et son efficacité peut varier
- Certaines publicités peuvent parfois passer
- Essayez de recharger le stream (Cmd+R)
- Vérifiez la console de débogage pour les logs de blocage

### Chaînes suivies ne s'affichent pas
- Assurez-vous d'être connecté à votre compte Twitch
- Visitez une fois la page "Following" pour déclencher le chargement
- Attendez quelques secondes que le script s'exécute

### L'interface est lente
- Fermez et relancez l'application
- Vérifiez votre connexion Internet
- Réduisez le nombre de chaînes suivies affichées

## Support & Contribution

### Signaler un bug
Ouvrez une issue sur GitHub avec :
- Version de macOS
- Description du problème
- Logs de console si possible

### Contribuer
Les pull requests sont les bienvenues ! Consultez `CONTRIBUTING.md` (si disponible)

## Ressources

- **Historique des changements** : [CHANGELOG.md](CHANGELOG.md)
- **Guide d'installation** : [INSTALL.md](INSTALL.md)

## Notes importantes

⚠️ **Limitations du blocage de publicités** :
- Blocage côté client uniquement
- Efficacité variable selon les mises à jour Twitch
- Certaines publicités peuvent parfois passer

✅ **Avantages de cette app** :
- Interface native macOS optimisée
- Design moderne glass-morphic
- Blocage publicitaire multi-couches
- Expérience immersive sans distractions
- Consommation mémoire optimisée vs navigateur
