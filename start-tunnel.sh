#!/bin/bash

# ============================================================
# EXECUTA TODO EN BACKGROUND Y EXPONE URL PÚBLICA
# ============================================================

set -e

echo "============================================================"
echo " 🌍 CONTROL-SAPI CON NGROK TUNNEL"
echo "============================================================"
echo ""

# 1. Instalar ngrok si no está
if ! command -v ngrok &> /dev/null; then
    echo "📥 Instalando ngrok..."
    curl -s https://ngrok-agent.s3.amazonaws.com/ngrok-v3-stable-linux-amd64.zip -o /tmp/ngrok.zip
    unzip -q /tmp/ngrok.zip -d /usr/local/bin/
    chmod +x /usr/local/bin/ngrok
    rm /tmp/ngrok.zip
fi

echo "✅ ngrok disponible"
echo ""

# 2. Crear .env
mkdir -p data
[ ! -f .env ] && cp .env.example .env

# 3. Instalar dependencias
npm install > /dev/null 2>&1 || true

# 4. Iniciar servidor en background
echo "🚀 Iniciando servidor Node.js..."
node server.js > /tmp/sapi.log 2>&1 &
SERVER_PID=$!
echo "✅ PID: $SERVER_PID"

sleep 3

# 5. Verificar que funciona
if curl -s http://localhost:3000/api/registros > /dev/null 2>&1; then
    echo "✅ Servidor respondiendo"
else
    echo "❌ Error en servidor"
    cat /tmp/sapi.log
    exit 1
fi

echo ""

# 6. Iniciar ngrok
echo "🌐 Creando túnel público..."
ngrok http 3000 --log=stdout > /tmp/ngrok.log 2>&1 &
NGROK_PID=$!

sleep 5

# 7. Obtener URL pública
PUBLIC_URL=$(grep -oP 'URL|uri=\K(https?://[^\s]+)' /tmp/ngrok.log | head -1 || echo "")

if [ -z "$PUBLIC_URL" ]; then
    PUBLIC_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -oP '"public_url":"\K[^"]+' | head -1 || echo "")
fi

echo ""
echo "============================================================"
echo " ✅ SERVIDOR EN VIVO"
echo "============================================================"
echo ""
echo "LOCAL:"
echo "  http://localhost:3000"
echo ""

if [ ! -z "$PUBLIC_URL" ]; then
    echo "PÚBLICO:"
    echo "  $PUBLIC_URL"
    echo ""
fi

echo "ENDPOINTS:"
echo "  GET  /api/registros"
echo "  POST /api/validar-rfc"
echo "  POST /api/tiktok/event/track"
echo ""

echo "============================================================"
echo " 📊 TEST AUTOMÁTICO"
echo "============================================================"
echo ""

# Test local
echo "📍 Local - GET /api/registros:"
curl -s http://localhost:3000/api/registros | jq '.[] | {id, capa_tecnica: .capa_tecnica, capa_fiscal: .capa_fiscal}' 2>/dev/null || echo "Error"

echo ""
echo "📍 Local - POST /api/validar-rfc:"
curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"rfc": "SAVO881129829"}' \
  http://localhost:3000/api/validar-rfc | jq '.' 2>/dev/null || echo "Error"

echo ""
echo "============================================================"
echo " 🛑 SERVIDOR EN EJECUCIÓN - PRESIONA CTRL+C PARA DETENER"
echo "============================================================"
echo ""

# Cleanup
trap "
echo ''
echo '⏹️  Deteniendo...'
kill $SERVER_PID $NGROK_PID 2>/dev/null || true
echo '✅ Detenido'
exit 0
" SIGINT SIGTERM

# Keep running
wait $SERVER_PID
