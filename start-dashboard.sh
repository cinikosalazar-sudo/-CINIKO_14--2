#!/bin/bash

# ============================================================
# COMPLETE SETUP + DASHBOARD - TODO EN UNO
# ============================================================

set -e

echo "============================================================"
echo " 🎯 SETUP COMPLETO + DASHBOARD"
echo "============================================================"
echo ""

# 1. Setup
echo "⚙️  Instalando..."
npm install > /dev/null 2>&1 || true
mkdir -p data
[ ! -f .env ] && cp .env.example .env

# 2. Start server
echo "🚀 Iniciando servidor..."
node server.js > /tmp/sapi-server.log 2>&1 &
SERVER_PID=$!

sleep 3

# 3. Check if running
if curl -s http://localhost:3000/api/registros > /dev/null 2>&1; then
    echo "✅ Servidor en http://localhost:3000"
else
    echo "❌ Error iniciando servidor"
    cat /tmp/sapi-server.log
    exit 1
fi

# 4. Open dashboard
echo ""
echo "🌐 Abriendo dashboard..."

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open file://$(pwd)/dashboard.html 2>/dev/null || echo "Abre en navegador: file://$(pwd)/dashboard.html"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    open file://$(pwd)/dashboard.html
else
    echo "Abre en navegador: file://$(pwd)/dashboard.html"
fi

echo ""
echo "============================================================"
echo " ✅ LISTO"
echo "============================================================"
echo ""
echo "📊 Dashboard: file://$(pwd)/dashboard.html"
echo "📡 API: http://localhost:3000"
echo ""
echo "Presiona CTRL+C para detener"
echo ""

# Cleanup
trap "kill $SERVER_PID 2>/dev/null || true; exit 0" SIGINT SIGTERM

wait $SERVER_PID
