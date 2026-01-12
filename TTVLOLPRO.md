# TTV LOL PRO - Intégration

Ce projet intègre des fonctionnalités inspirées de [TTV LOL PRO](https://github.com/younesaassila/ttv-lol-pro) pour bloquer les publicités sur Twitch.

## Fonctionnalités

L'intégration inclut les fonctionnalités suivantes :

### 🚫 Blocage de publicités
- **Interception des requêtes GraphQL** : Les requêtes liées aux publicités sont filtrées
- **Blocage des overlays publicitaires** : Les compteurs et labels de publicités sont masqués
- **Détection et saut des publicités** : Le système détecte et tente de passer les publicités en temps réel
- **Blocage des segments vidéo publicitaires** : Les segments M3U8 contenant des publicités sont bloqués

### 📋 Opérations bloquées
Le script bloque ou modifie les opérations GraphQL suivantes :
- `VideoPlayerStreamInfoOverlayChannel`
- `ComscoreStreamingQuery`
- `ChannelShellQuery`
- `VideoAdUI`

### 🎯 Méthodes de blocage

1. **Override de `fetch()`** : Intercepte et modifie les requêtes fetch
2. **Override de `XMLHttpRequest`** : Intercepte et modifie les requêtes XHR
3. **Injection CSS** : Masque les éléments publicitaires dans le DOM
4. **Surveillance continue** : Vérifie la présence de publicités toutes les secondes

## Implémentation technique

Le blocage est implémenté via un `WKUserScript` injecté dans le WebView :
- **Injection** : `.atDocumentStart` pour intercepter les requêtes dès le chargement
- **Portée** : Uniquement sur la frame principale (`forMainFrameOnly: true`)
- **WebViews concernés** : Principal et arrière-plan (pour le suivi des chaînes)

## Limitations

⚠️ **Important** : Cette implémentation est une version simplifiée de TTV LOL PRO :

1. **Pas de proxy** : TTV LOL PRO utilise des serveurs proxy dans des pays sans publicités. Cette version ne peut pas faire de routing proxy depuis une WebView native.
2. **Blocage côté client uniquement** : Le blocage se fait au niveau du navigateur, pas au niveau réseau.
3. **Efficacité variable** : Twitch change régulièrement ses mécanismes de publicité, ce qui peut nécessiter des mises à jour du script.

## Comparaison avec TTV LOL PRO

| Fonctionnalité | TTV LOL PRO (Extension) | Cette implémentation |
|---------------|-------------------------|---------------------|
| Proxy vers pays sans pub | ✅ Oui | ❌ Non (limitation WebView) |
| Interception GraphQL | ✅ Oui | ✅ Oui |
| Blocage CSS | ✅ Oui | ✅ Oui |
| Configuration utilisateur | ✅ Oui | ❌ Non |
| Statistiques | ✅ Oui | ❌ Non |
| Liste blanche | ✅ Oui | ❌ Non |

## Utilisation avec uBlock Origin

Pour une protection complète, TTV LOL PRO recommande d'utiliser [uBlock Origin](https://ublockorigin.com/) pour bloquer :
- Les bannières publicitaires
- Les publicités dans les VODs
- Les autres types de publicités non-streaming

**Note** : Comme cette application est native et non une extension de navigateur, vous ne pouvez pas installer uBlock Origin directement. Le script intégré fait de son mieux pour bloquer les publicités au niveau du stream.

## Logs et débogage

Le script génère des logs dans la console JavaScript du WebView :
- `[TTV LOL PRO] Ad blocker initialized` : Le script est chargé
- `[TTV LOL PRO] Blocked ad segment: <url>` : Un segment publicitaire a été bloqué
- `[TTV LOL PRO] Ad detected, attempting to skip...` : Une publicité a été détectée

Pour voir ces logs, vous pouvez activer le mode développeur du WebView si nécessaire.

## Mises à jour futures

Pour améliorer l'efficacité du blocage :
1. Surveiller les changements dans l'API Twitch
2. Ajouter de nouvelles opérations GraphQL à bloquer
3. Améliorer la détection des segments publicitaires
4. Potentiellement implémenter un proxy externe (serveur Node.js local)

## Crédits

- **TTV LOL PRO** : [younesaassila/ttv-lol-pro](https://github.com/younesaassila/ttv-lol-pro)
- Extension maintenue par Younes Aassila ([@younesaassila](https://github.com/younesaassila))
- Proxies maintenus par Marc Gómez ([@zGato](https://github.com/zGato))

## Licence

Le code original de TTV LOL PRO est sous licence GPL-3.0. Cette adaptation respecte les termes de cette licence.
