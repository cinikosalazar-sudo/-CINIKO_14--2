<!-- markdownlint-disable -->

# Control SApi 🚀

**TikTok Shop Merchant Data Management & Event Tracking Service**

A Node.js HTTP server that manages merchant compliance data and forwards conversion events to TikTok's Events API. Designed for Mexican merchants with RFC validation and fiscal compliance tracking.

## Features

- 📊 **Multi-layer merchant data**: Technical, fiscal, and functional layers
- ✅ **RFC validation**: Mexican tax ID format validation
- 📡 **TikTok Events API integration**: Track conversions in real-time
- 🔄 **Auto-sync**: Automatic MCP connection status updates every 60 seconds
- 💾 **Persistent storage**: JSON-based data persistence in `data/registros.json`
- 🌐 **CORS enabled**: Cross-origin requests supported

## Architecture

```
server.js              Main HTTP server (port 3000)
├── /api/registros     GET merchant records
├── /api/validar-rfc   POST validate RFC format
└── /api/tiktok/event/track  POST forward events to TikTok

data/
└── registros.json     Persistent merchant data store
```

## Quick Start

### Local Development

```bash
# Install dependencies
npm install

# Set up environment
cp .env.example .env
# Edit .env and add your TIKTOK_ACCESS_TOKEN

# Start server
npm start

# Server runs on http://localhost:3000
```

### Docker Build & Run

```bash
# Build image
docker build -t control-sapi:latest .

# Run container
docker run -e TIKTOK_ACCESS_TOKEN=your_token -p 3000:3000 control-sapi:latest
```

### Cloud Run Deployment

```bash
bash deploy.sh
```

This will:
1. Authenticate with Google Cloud
2. Create Artifact Registry repository
3. Build and push Docker image
4. Deploy to Cloud Run with 24/7 uptime (min-instances=1)

## API Endpoints

### GET `/api/registros`
Retrieve all merchant records.

**Response:**
```json
[
  {
    "id": "7404372303604319238",
    "meta_datos": { "fecha_ingreso": "...", "auditor_responsable": "TikTok Shop" },
    "capa_tecnica": { "servidor_mcp": "Conectado", "pixel_id": "D8MUKT3C77U235SQOCU0", ... },
    "capa_fiscal": { "rfc_titular": "SAVO881129829", "formulario_w8ben": "Validado", ... },
    "capa_funcional": { "saldo_retenido_mxn": 124850.00, "indice_retorno_funcional": 92, ... }
  }
]
```

### POST `/api/validar-rfc`
Validate Mexican RFC (tax ID) format.

**Request:**
```json
{ "rfc": "SAVO881129829" }
```

**Response:**
```json
{ "valido": true, "rfc": "SAVO881129829", "mensaje": "RFC válido" }
```

### POST `/api/tiktok/event/track`
Forward conversion event to TikTok Events API.

**Request:**
```json
{
  "event_name": "Purchase",
  "value": 100.50,
  "currency": "MXN",
  "url": "https://www.tiktok.com/@ciniko_14/shop"
}
```

**Response:**
```json
{
  "exito": true,
  "codigo": 200,
  "respuesta_tiktok": { ... }
}
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `TIKTOK_ACCESS_TOKEN` | ✅ | TikTok Business API access token |
| `PORT` | ❌ | Server port (default: 3000) |
| `NODE_ENV` | ❌ | Environment mode (default: production) |

## Data Structure

### Capa Técnica (Technical Layer)
- `servidor_mcp`: MCP server connection status
- `pixel_id`: TikTok pixel identifier
- `emparejamiento_avanzado`: Advanced pairing status
- `ultima_sincronizacion`: Last sync timestamp

### Capa Fiscal (Fiscal Layer)
- `rfc_titular`: Mexican tax ID (RFC)
- `formulario_w8ben`: W8-BEN form status (US tax compliance)
- `conciliacion_cfdi`: CFDI reconciliation status (Mexican e-invoicing)

### Capa Funcional (Functional Layer)
- `saldo_retenido_mxn`: Retained balance in Mexican Pesos
- `indice_retorno_funcional`: Functional return index (0-100)
- `liberacion_manual`: Manual release status

## Security Notes

⚠️ **For production deployment:**

- Store `TIKTOK_ACCESS_TOKEN` in Google Cloud Secret Manager
- Implement authentication on API endpoints
- Add rate limiting to prevent abuse
- Use HTTPS/TLS for all communications
- Never commit `.env` files
- Rotate access tokens regularly
- Audit RFC and financial data access

## Requirements

- Node.js 18+
- (Docker for containerized deployment)
- (Google Cloud account for Cloud Run)

## License

BSD 2-Clause License — See LICENSE file

## Support

For issues or questions, contact the merchant compliance team.

---

**Made with ❤️ for Mexican e-commerce merchants**
