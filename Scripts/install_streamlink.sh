#!/bin/bash
# Installation de Streamlink pour le blocage de pubs Twitch

echo "🚀 Installation de Streamlink pour Twitch..."

# Vérifier si Homebrew est installé
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew n'est pas installé. Installation..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Installer Streamlink
echo "📦 Installation de Streamlink..."
brew install streamlink

# Installer le plugin TwitchDropsMiner (optionnel, pour meilleures performances)
echo "🔧 Configuration de Streamlink..."

# Créer le fichier de config Streamlink
mkdir -p ~/.config/streamlink
cat > ~/.config/streamlink/config << 'EOF'
# Configuration Streamlink pour Twitch
player=iina
player-args=--no-audio-display
default-stream=best
hls-live-edge=3
stream-segment-threads=3
hls-segment-queue-threshold=5
twitch-disable-ads=true
twitch-low-latency=false
EOF

echo "✅ Streamlink installé avec succès !"
echo ""
echo "Test de Streamlink :"
streamlink --version
echo ""
echo "Pour tester avec un stream Twitch :"
echo "  streamlink twitch.tv/CHANNEL_NAME best"
