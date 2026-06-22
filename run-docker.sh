#!/bin/bash

# ============================================================
# DOCKER RUN CON PUERTO EXPUESTO
# ============================================================

set -e

echo "============================================================"
echo " 🐳 EJECUTANDO CONTROL-SAPI EN DOCKER"
echo "============================================================"

IMAGE_NAME="control-sapi"
IMAGE_TAG="local"
CONTAINER_NAME="control-sapi-local"
PORT=3000

# 1. Build Docker image
echo "👉 Compilando imagen Docker..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
echo "✅ Imagen compilada: ${IMAGE_NAME}:${IMAGE_TAG}"

# 2. Stop existing container if running
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "👉 Deteniendo contenedor anterior..."
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
fi

# 3. Run container
echo "👉 Iniciando contenedor..."
docker run -d \
    --name ${CONTAINER_NAME} \
    -p ${PORT}:3000 \
    -e TIKTOK_ACCESS_TOKEN="${TIKTOK_ACCESS_TOKEN:-tu_token_aqui}" \
    -e NODE_ENV=development \
    ${IMAGE_NAME}:${IMAGE_TAG}

echo "✅ Contenedor iniciado: ${CONTAINER_NAME}"

# 4. Wait for container to be ready
echo "👉 Esperando que el servidor esté listo..."
sleep 3

# 5. Test server
echo "👉 Probando conexión..."
for i in {1..10}; do
    if curl -s http://localhost:${PORT}/api/registros > /dev/null 2>&1; then
        echo "✅ Servidor respondiendo"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "❌ Servidor no responde"
        docker logs ${CONTAINER_NAME}
        exit 1
    fi
    sleep 1
done

# 6. Display endpoints
echo ""
echo "============================================================"
echo " 📡 ENDPOINTS DOCKER"
echo "============================================================"
echo ""
echo "http://localhost:${PORT}/api/registros"
echo "http://localhost:${PORT}/api/validar-rfc"
echo "http://localhost:${PORT}/api/tiktok/event/track"
echo ""

# 7. Show logs
echo "============================================================"
echo " 📋 LOGS EN VIVO"
echo "============================================================"
echo ""
docker logs -f ${CONTAINER_NAME}
