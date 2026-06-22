#!/bin/bash

# ============================================================
# DOCKER INSTANT START - EJECUTA EN CONTENEDOR INMEDIATAMENTE
# ============================================================

set -e

echo "============================================================"
echo " 🐳 EJECUTANDO EN DOCKER AHORA MISMO"
echo "============================================================"
echo ""

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no detectado"
    echo "📥 Instala Docker desde: https://docker.com"
    exit 1
fi

echo "✅ Docker detectado"
echo ""

# Variables
IMAGE_NAME="control-sapi"
TAG="latest"
CONTAINER_NAME="sapi-$(date +%s)"
PORT=3000

# Build
echo "🔨 Compilando imagen Docker..."
docker build -t ${IMAGE_NAME}:${TAG} . > /dev/null 2>&1

echo "✅ Imagen lista"
echo ""

# Run
echo "⚡ Iniciando contenedor..."
docker run --rm \
    --name ${CONTAINER_NAME} \
    -p ${PORT}:3000 \
    -e TIKTOK_ACCESS_TOKEN="tu_token_aqui" \
    -e NODE_ENV=production \
    ${IMAGE_NAME}:${TAG}
