# 🎓 EduFlows - Système de Gestion Éducative

Application Flutter avec backend Node.js et base de données PostgreSQL pour la gestion des cours, professeurs et étudiants.

## 🏗️ Architecture

eduflows/
├── frontend/ # Application Flutter
├── backend/ # API Node.js + Express
├── database/ # Scripts SQL PostgreSQL
├── deployment/ # Configurations déploiement
├── docs/ # Documentation
└── scripts/ # Scripts utilitaires


## 🚀 Démarrage Rapide

### Prérequis
- Flutter 3.0+
- Node.js 18+
- PostgreSQL 14+
- Git

### Installation Locale
```bash
# 1. Cloner le projet
git clone https://github.com/votre-username/eduflows.git
cd eduflows

# 2. Backend
cd backend
npm install
cp .env.example .env
# Éditer .env avec vos configurations
npm run dev

# 3. Base de données
psql -U postgres -f database/init.sql

# 4. Frontend
cd frontend
flutter pub get
flutter run


Rôles d'accès

    Admin : admin@eduflows.com / admin123

    Professeur : prof@eduflows.com / prof123

    Étudiant : etudiant@eduflows.com / etudiant123


Technologies

    Frontend : Flutter, Provider, Shared Preferences

    Backend : Node.js, Express, JWT, Bcrypt

    Base de données : PostgreSQL

    API : RESTful JSON



Licence

MIT
text


**`docs/INSTALLATION.md` :**
```markdown
# 📚 Guide d'Installation

## Environnement de Développement

### 1. Prérequis
```bash
# Flutter
flutter --version  # >= 3.0.0

# Node.js
node --version     # >= 18.0.0
npm --version      # >= 8.0.0

# PostgreSQL
psql --version     # >= 14.0.0



Installation Backend
bash

cd backend

# Installer les dépendances
npm install

# Configurer l'environnement
cp .env.example .env
# Éditer .env avec vos valeurs

# Initialiser la base de données
npm run db:init

# Démarrer en développement
npm run dev



3. Installation Frontend
bash

cd frontend

# Installer les dépendances Flutter
flutter pub get

# Configurer l'URL API
# Modifier lib/core/api/api_service.dart
# Pour développement: http://localhost:3000/api

# Démarrer l'application
flutter run


 Données de test
sql

-- Comptes prédéfinis
Email: admin@eduflows.com    | Password: admin123    | Rôle: Admin
Email: prof@eduflows.com     | Password: prof123     | Rôle: Professeur  
Email: etudiant@eduflows.com | Password: etudiant123 | Rôle: Étudiant



**`deployment/DOCKER.md` :**
```markdown
# 🐳 Déploiement avec Docker

## Docker Compose
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: eduflows_db
      POSTGRES_USER: eduflows_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"

  backend:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: production
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: eduflows_db
      DB_USER: eduflows_user
      DB_PASSWORD: ${DB_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
    depends_on:
      - postgres

volumes:
  postgres_data:



Commandes
bash

# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Logs
docker-compose logs -f

# Backup base de données
docker exec -t eduflows_postgres_1 pg_dump -U eduflows_user eduflows_db > backup.sql



### **Étape 4 : Créer les scripts utilitaires**

**`scripts/setup-dev.sh` :**
```bash
#!/bin/bash

echo "🚀 Installation EduFlows - Environnement de Développement"

# Vérifier les prérequis
command -v flutter >/dev/null 2>&1 || { echo "❌ Flutter non installé"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "❌ Node.js non installé"; exit 1; }
command -v psql >/dev/null 2>&1 || { echo "❌ PostgreSQL non installé"; exit 1; }

# Backend
echo "📦 Installation backend..."
cd backend
npm install
if [ ! -f .env ]; then
    cp .env.example .env
    echo "⚠️  Fichier .env créé. Veuillez le configurer."
fi

# Base de données
echo "🗄️  Configuration base de données..."
read -p "Nom d'utilisateur PostgreSQL (postgres): " db_user
db_user=${db_user:-postgres}
sudo -u $db_user psql -c "CREATE DATABASE eduflows_db;" 2>/dev/null || true
sudo -u $db_user psql -d eduflows_db -f ../database/init.sql 2>/dev/null || true

# Frontend
echo "📱 Installation frontend..."
cd ../frontend
flutter pub get

echo "✅ Installation terminée!"
echo "📋 Prochaines étapes:"
echo "1. Configurer le fichier backend/.env"
echo "2. Démarrer le backend: cd backend && npm run dev"
echo "3. Démarrer Flutter: cd frontend && flutter run"



