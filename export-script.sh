#!/bin/bash

# Flutter Chekmate Intelligence - Complete Project Export Script
# This script creates a complete project structure ready for Windsurf IDE

echo "🚀 Creating Flutter Chekmate Intelligence Project..."

# Create main project directory
PROJECT_NAME="flutter_chekmate_intelligence"
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Create Flutter project structure
echo "📁 Setting up directory structure..."

# Main directories
mkdir -p lib/{dashboard,ml,providers,models,services,analysis_pipeline}
mkdir -p lib/dashboard/{tabs,widgets}
mkdir -p lib/ml/{models,training}
mkdir -p firebase/functions
mkdir -p assets/{models,icons}
mkdir -p test/{unit,widget,integration}
mkdir -p docs

# ============= CORE PROJECT FILES =============

# Create pubspec.yaml
cat > pubspec.yaml << 'EOF'
name: flutter_chekmate_intelligence
description: AI-powered Flutter code analysis with ML predictions
version: 2.0.0+1
publish_to: 'none'

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase & Backend
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
  firebase_database: ^10.3.8
  firebase_analytics: ^10.7.4
  firebase_auth: ^4.15.0
  firebase_storage: ^11.5.5
  firebase_performance: ^0.9.3
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # ML & Data Science
  ml_algo: ^16.17.5
  ml_dataframe: ^1.5.1
  
  # Charts & Visualization
  fl_chart: ^0.65.0
  syncfusion_flutter_charts: ^23.2.6
  
  # UI Enhancements
  flutter_animate: ^4.3.0
  badges: ^3.1.2
  flutter_speed_dial: ^7.0.0
  shimmer: ^3.0.0
  lottie: ^2.7.0
  
  # Utilities
  intl: ^0.18.1
  collection: ^1.18.0
  path_provider: ^2.1.1
  dio: ^5.4.0
  uuid: ^4.2.1
  crypto: ^3.0.3
  
  # Code Analysis
  analyzer: ^6.3.0
  dart_style: ^2.3.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  freezed: ^2.4.6
  freezed_annotation: ^2.4.1
  json_serializable: ^6.7.1
  mockito: ^5.4.3

flutter:
  uses-material-design: true
  
  assets:
    - assets/models/
    - assets/icons/
  
  fonts:
    - family: Inter
      fonts:
        - asset: fonts/Inter-Regular.ttf
        - asset: fonts/Inter-Bold.ttf
          weight: 700
EOF

# Create analysis_options.yaml
cat > analysis_options.yaml << 'EOF'
include: package:flutter_lints/flutter.yaml

analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  errors:
    missing_required_param: error
    missing_return: error
    todo: ignore
  exclude:
    - lib/generated/**

linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_init_to_null
    - avoid_relative_lib_imports
    - avoid_return_types_on_setters
    - avoid_shadowing_type_parameters
    - avoid_types_as_parameter_names
    - camel_case_extensions
    - prefer_adjacent_string_concatenation
    - prefer_collection_literals
    - prefer_conditional_assignment
    - prefer_const_constructors
EOF

# Create README.md
cat > README.md << 'EOF'
# Flutter Chekmate Intelligence Platform 🚀

## Advanced AI-Powered Flutter Code Analysis System

### 🏗️ Architecture Overview

This platform implements a sophisticated four-thread analysis pipeline with ML predictions, real-time monitoring, and a comprehensive data lake architecture.

### 🔥 Key Features

- **Four-Thread Analysis Pipeline**
  - Thread 1: Rapid Discovery & Summarization
  - Thread 2: AI-Optimized Transformation
  - Thread 3: Documentation Synthesis
  - Thread 4: Data Lake Population

- **Machine Learning Models**
  - Complexity Growth Prediction
  - Technical Debt Forecasting
  - Security Vulnerability Detection
  - Performance Bottleneck Analysis
  - Pattern Evolution Tracking

- **Real-Time Dashboard**
  - Live metrics streaming via Firebase
  - Interactive visualizations
  - Predictive analytics
  - Alert system

- **Data Lake Architecture**
  - Bronze Layer: Raw immutable data
  - Silver Layer: Processed analytics
  - Gold Layer: Business intelligence

### 🚀 Quick Start

1. **Prerequisites**
   ```bash
   flutter --version  # 3.0+
   firebase --version # Latest
   node --version     # 18+
   ```

2. **Installation**
   ```bash
   flutter pub get
   cd firebase/functions && npm install
   ```

3. **Firebase Setup**
   ```bash
   firebase init
   flutterfire configure
   ```

4. **Run Locally**
   ```bash
   firebase emulators:start
   flutter run
   ```

### 📱 Supported Platforms

- iOS 12.0+
- Android API 21+
- Web (Chrome, Safari, Firefox)
- macOS 10.14+
- Windows 10+
- Linux (Ubuntu 18.04+)

### 🔧 Configuration

See `docs/CONFIGURATION.md` for detailed setup instructions.

### 📊 Dashboard Access

Once running, access the dashboard at:
- Mobile/Desktop App: Launch directly
- Web: http://localhost:3000
- Monitoring: http://localhost:3001 (Grafana)

### 🤝 Contributing

See `CONTRIBUTING.md` for guidelines.

### 📄 License

MIT License - see `LICENSE` for details.

### 🆘 Support

- Documentation: `docs/`
- Issues: GitHub Issues
- Discord: [Join our community](https://discord.gg/chekmate)

---
Built with ❤️ using Flutter, Firebase, and Riverpod
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/
*.iml
*.ipr
*.iws
.idea/

# Firebase
firebase-debug.log
firestore-debug.log
database-debug.log
ui-debug.log
firebase-export-*

# Platform specific
ios/Flutter/.last_build_id
ios/Pods
android/.gradle
android/captures/
android/local.properties
*.jks

# Secrets
*.env
service-account.json
google-services.json
GoogleService-Info.plist

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
*.swp
*.swo
EOF

# Create Docker files
cat > Dockerfile << 'EOF'
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter doctor

# Copy project
WORKDIR /app
COPY . .

# Get dependencies
RUN flutter pub get

# Build
RUN flutter build apk --release

EXPOSE 3000
CMD ["flutter", "run", "--release"]
EOF

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - FLUTTER_ENV=development
    volumes:
      - .:/app
    depends_on:
      - firebase

  firebase:
    image: andreysenov/firebase-tools
    ports:
      - "4000:4000"  # Emulator UI
      - "8080:8080"  # Firestore
      - "9000:9000"  # Realtime Database
      - "5001:5001"  # Functions
    volumes:
      - ./firebase:/app
    command: firebase emulators:start --import=./seed

  ml-server:
    build: ./ml-server
    ports:
      - "5000:5000"
    environment:
      - PYTHONUNBUFFERED=1
    volumes:
      - ./ml-models:/models

  monitoring:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-storage:/var/lib/grafana

volumes:
  grafana-storage:
EOF

# Create Firebase configuration
cat > firebase.json << 'EOF'
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "database": {
    "rules": "database.rules.json"
  },
  "functions": {
    "source": "firebase/functions",
    "predeploy": [
      "npm --prefix \"$RESOURCE_DIR\" run lint",
      "npm --prefix \"$RESOURCE_DIR\" run build"
    ],
    "runtime": "nodejs18"
  },
  "storage": {
    "rules": "storage.rules"
  },
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  },
  "emulators": {
    "auth": {
      "port": 9099
    },
    "functions": {
      "port": 5001
    },
    "firestore": {
      "port": 8080
    },
    "database": {
      "port": 9000
    },
    "hosting": {
      "port": 5002
    },
    "storage": {
      "port": 9199
    },
    "ui": {
      "enabled": true,
      "port": 4000
    }
  }
}
EOF

# Create Firestore rules
cat > firestore.rules << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Data Lake - Bronze Layer (immutable)
    match /data_lake/bronze/{document=**} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if false;
    }
    
    // Data Lake - Silver Layer
    match /data_lake/silver/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.auth.token.analyst == true;
    }
    
    // Data Lake - Gold Layer
    match /data_lake/gold/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.auth.token.admin == true;
    }
    
    // ML Predictions (read-only for users)
    match /ml_predictions/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    
    // Analysis Results
    match /analysis_results/{analysisId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow delete: if false;
    }
  }
}
EOF

# Create package.json for Firebase Functions
cat > firebase/functions/package.json << 'EOF'
{
  "name": "flutter-chekmate-functions",
  "version": "1.0.0",
  "description": "Cloud Functions for Flutter Chekmate Intelligence",
  "main": "index.js",
  "engines": {
    "node": "18"
  },
  "scripts": {
    "lint": "eslint .",
    "build": "tsc",
    "serve": "npm run build && firebase emulators:start --only functions",
    "deploy": "firebase deploy --only functions"
  },
  "dependencies": {
    "firebase-admin": "^11.11.1",
    "firebase-functions": "^4.5.0",
    "@google-cloud/firestore": "^7.1.0",
    "axios": "^1.6.2",
    "lodash": "^4.17.21"
  },
  "devDependencies": {
    "@typescript-eslint/eslint-plugin": "^6.13.0",
    "@typescript-eslint/parser": "^6.13.0",
    "eslint": "^8.55.0",
    "typescript": "^5.3.2"
  }
}
EOF

# Create VS Code configuration for Windsurf
mkdir -p .vscode
cat > .vscode/launch.json << 'EOF'
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Debug",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug"
    },
    {
      "name": "Flutter Profile",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile"
    },
    {
      "name": "Flutter Release",
      "request": "launch",
      "type": "dart",
      "flutterMode": "release"
    }
  ]
}
EOF

cat > .vscode/settings.json << 'EOF'
{
  "dart.flutterSdkPath": "/usr/local/flutter",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "files.exclude": {
    "**/.dart_tool": true,
    "**/.idea": true,
    "**/build": true
  }
}
EOF

# Create the export script
cat > export_project.sh << 'EOF'
#!/bin/bash
echo "📦 Creating project archive..."
zip -r flutter_chekmate_intelligence.zip . \
  -x "*.git*" \
  -x "*build/*" \
  -x "*.dart_tool*" \
  -x "*node_modules*"
echo "✅ Project exported to flutter_chekmate_intelligence.zip"
EOF

chmod +x export_project.sh

echo "✅ Project structure created successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Run 'cd $PROJECT_NAME'"
echo "2. Run 'flutter create . --org com.yourcompany'"
echo "3. Copy your existing lib files"
echo "4. Run 'flutter pub get'"
echo "5. Configure Firebase: 'flutterfire configure'"
echo "6. Open in Windsurf IDE"
echo ""
echo "🎉 Project is ready for development in Windsurf!"