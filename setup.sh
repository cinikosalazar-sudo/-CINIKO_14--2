#!/bin/bash

# ============================================================
# SETUP RÁPIDO - INSTALA Y EJECUTA TODO
# ============================================================

set -e

echo "============================================================"
echo " ⚙️  SETUP INICIAL CONTROL-SAPI"
echo "============================================================"

# 1. Verify prerequisites
echo "👉 Verificando requisitos..."

if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado"
    echo "   Descarga en: https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js: $(node --version)"
echo "✅ npm: $(npm --version)"

# 2. Install dependencies
echo ""
echo "👉 Instalando dependencias npm..."
npm install

# 3. Create environment file
echo ""
echo "👉 Creando archivo .env..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ Archivo .env creado"
    echo "   Edita .env y agrega tu TIKTOK_ACCESS_TOKEN"
else
    echo "✅ Archivo .env ya existe"
fi

# 4. Make scripts executable
echo ""
echo "👉 Preparando scripts..."
chmod +x run-local.sh run-docker.sh 2>/dev/null || true
echo "✅ Scripts listos"

# 5. Create data directory
echo ""
echo "👉 Creando directorios de datos..."
mkdir -p data
echo "✅ Directorios creados"

# 6. Show next steps
echo ""
echo "============================================================"
echo " ✅ SETUP COMPLETADO"
echo "============================================================"
echo ""
echo "PRÓXIMOS PASOS:"
echo ""
echo "1️⃣  EJECUTAR LOCALMENTE (Node.js):"
echo "   npm start"
echo ""
echo "2️⃣  EJECUTAR CON TÚNEL PÚBLICO (ngrok):"
echo "   bash run-local.sh"
echo ""
echo "3️⃣  EJECUTAR EN DOCKER:"
echo "   bash run-docker.sh"
echo ""
echo "4️⃣  EDITAR CREDENCIALES:"
echo "   nano .env"
echo ""
echo "============================================================"
