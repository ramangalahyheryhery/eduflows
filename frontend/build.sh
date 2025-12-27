#!/bin/bash
# frontend/build.sh - Script de build Flutter pour Docker

echo "🚀 Building Flutter web application..."

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé"
    exit 1
fi

# Clean
echo "🧹 Cleaning..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🔨 Building web version..."
flutter build web \
  --release \
  --web-renderer canvaskit \
  --dart-define=API_URL=${API_URL:-http://localhost:3000}

echo "✅ Build completed!"
echo "📁 Output: build/web/"