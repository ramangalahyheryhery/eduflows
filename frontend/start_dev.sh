#!/bin/bash

echo "🚀 Démarrage EduFlows en mode développement avec proxy..."

# Vérifier que le backend est démarré
echo "🔍 Vérification du backend..."
if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ Backend détecté sur localhost:3000"
else
    echo "❌ Backend non détecté! Démarrez-le avec:"
    echo "   cd backend && npm start"
    echo ""
    read -p "Voulez-vous démarrer le backend maintenant? (o/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        echo "🔄 Démarrage du backend..."
        cd backend
        npm start &
        BACKEND_PID=$!
        cd ..
        echo "✅ Backend démarré (PID: $BACKEND_PID)"
    else
        echo "❌ Impossible de continuer sans backend"
        exit 1
    fi
fi

# Attendre que le backend soit prêt
echo "⏳ Attente que le backend soit complètement prêt..."
sleep 3

# Démarrer Flutter avec proxy
echo "🌐 Démarrage de Flutter Web avec proxy..."
echo "📁 Fichier proxy utilisé: web/proxy.conf.json"
echo "🔗 Frontend: http://localhost:8080"
echo "🔗 Backend (via proxy): http://localhost:8080/api -> http://localhost:3000/api"

# Lancer Flutter
flutter run -d chrome \
  --web-port=8080 \
  --web-hostname=localhost \
  --web-browser-flag="--disable-web-security" \
  --web-allow-expose-url