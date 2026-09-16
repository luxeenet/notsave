# Production Android Notification Receiver Backend

A production-ready, highly secure, scalable, and observable backend built with **Node.js**, **TypeScript**, **Express**, and **MongoDB** (Mongoose) designed to receive, authenticate, validate, deduplicate, and durably persist Android notification payloads sent via HTTP POST requests.

---

## 1. System Architecture

```text
Android App
     │
     │ HTTPS POST /api/v1/notifications
     ▼
Internet
     │
     ▼
Nginx (Reverse Proxy :443 SSL Certbot)
     │
     │ 127.0.0.1:8080
     ▼
Node.js + Express App (Managed by PM2)
 ├── Request ID Middleware (X-Request-ID)
 ├── Helmet (Security Headers)
 ├── Rate Limiter (express-rate-limit)
 ├── Bearer Token Auth (timingSafeCompare)
 ├── Payload Validator (Zod Schema)
 ├── Deduplication & Normalization
 └── Storage Confirmation
     │
     ▼
MongoDB (Database: android_notifications | Collection: notifications)
```

---

## 2. Project Directory Layout

```text
c:/Users/notsave/
├── src/
│   ├── config/
│   │   ├── database.ts         # MongoDB connection & reconnect handlers
│   │   ├── environment.ts      # Strict environment configuration & fallback validation
│   │   └── logger.ts           # Structured Pino logger with authorization token redaction
│   ├── controllers/
│   │   ├── notification.controller.ts  # Primary notification receiver endpoint handler
│   │   ├── health.controller.ts        # Root status, liveness, and readiness probes
│   │   └── admin.controller.ts         # Protected internal query & aggregation endpoints
│   ├── middleware/
│   │   ├── auth.middleware.ts     # Timing-safe Bearer Token & Admin key verifier
│   │   ├── error.middleware.ts    # Central error handler suppressing stacks in prod
│   │   ├── rateLimit.middleware.ts# Rate limiting middleware
│   │   ├── requestId.middleware.ts# Request tracking middleware (X-Request-ID)
│   │   └── validation.middleware.ts   # Zod body validation middleware
│   ├── models/
│   │   ├── Notification.ts      # Main Mongoose Notification Schema with unique indexes
│   │   └── DeliveryAttempt.ts   # Delivery attempt & duplicate tracking Schema
│   ├── routes/
│   │   ├── notification.routes.ts # Ingestion API routes (/api/v1/notifications)
│   │   ├── health.routes.ts       # Health check routes (/, /health/live, /health/ready)
│   │   └── admin.routes.ts        # Admin routes (/api/v1/admin/notifications)
│   ├── services/
│   │   ├── notification.service.ts# Safe insertion, SHA-256 deduplication & E11000 handling
│   │   ├── admin.service.ts       # Pagination & search filtering query logic
│   │   └── stats.service.ts       # Aggregation analytics (hourly, package, category)
│   ├── validators/
│   │   └── notification.validator.ts # Zod notification payload schema
│   ├── types/
│   │   ├── notification.types.ts  # Interfaces & response contracts
│   │   └── express.d.ts           # Custom Express Request type augmentations
│   ├── utils/
│   │   ├── hash.ts               # SHA-256 generation & crypto.timingSafeEqual comparison
│   │   ├── date.ts               # Safe Android epoch timestamp conversion
│   │   └── sanitize.ts           # Helper sanitization
│   ├── app.ts                    # Express app setup factory
│   └── server.ts                 # Server startup & SIGTERM/SIGINT graceful shutdown
├── tests/
│   ├── unit/
│   │   ├── hash.test.ts          # Timing-safe auth & SHA-256 tests
│   │   └── validation.test.ts    # Zod payload schema validation tests
│   └── integration/
│       ├── health.test.ts        # Health & readiness probe tests
│       └── notification.test.ts  # Ingestion route security & auth tests
├── scripts/
│   └── health-check.ts           # CLI health script for Docker/PM2 probes
├── nginx/
│   └── notification-server.conf  # Production Nginx reverse proxy configuration
├── .env.example
├── .env
├── .gitignore
├── ecosystem.config.js           # PM2 configuration
├── openapi.yaml                  # OpenAPI 3.0 API Specification
├── package.json
├── tsconfig.json
├── vitest.config.ts
└── README.md
```

---

## 3. Installation & Local Setup

### Prerequisites
- **Node.js**: v18.0.0+ (Tested on v22.18.0)
- **MongoDB**: Community Server 6.0+ (Listening locally on `127.0.0.1:27017` or MongoDB Atlas URI)

### Step 1: Install Dependencies
```bash
npm install
```

### Step 2: Environment Configuration
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

Ensure the following variables are specified:
```env
NODE_ENV=production
PORT=8080
MONGODB_URI=mongodb://127.0.0.1:27017/android_notifications
BEARER_TOKEN=YOUR_SECRET_BEARER_TOKEN_HERE
ADMIN_API_KEY=YOUR_SECRET_ADMIN_KEY_HERE
TRUST_PROXY=true
CORS_ORIGINS=
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX=300
BODY_LIMIT=1mb
LOG_LEVEL=info
LOG_NOTIFICATION_CONTENT=false
```

### Step 3: Run Development Server
```bash
npm run dev
```

### Step 4: Build & Run Production Output
```bash
npm run build
npm start
```

### Step 5: Execute Test Suite
```bash
npm run test
```

---

## 4. Android Client Payload & Curl Test

### HTTP Request Specification
```http
POST /api/v1/notifications HTTP/1.1
Host: notify.example.com
Authorization: Bearer YOUR_SECRET_BEARER_TOKEN_HERE
Content-Type: application/json

{
  "id": "test-001",
  "packageName": "com.android.settings",
  "key": "0|com.android.settings|1001|...",
  "title": "Test Notification",
  "text": "Hello from Android",
  "subText": "Testing",
  "bigText": "Full notification content details",
  "category": "msg",
  "time": 1694825600000
}
```

### Sample Manual cURL Command
```bash
curl -X POST \
  http://127.0.0.1:8080/api/v1/notifications \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-bearer-token-12345" \
  -d '{
    "id": "test-001",
    "packageName": "com.android.settings",
    "key": "test-key",
    "title": "Test Notification",
    "text": "Hello from Android",
    "subText": "Testing",
    "bigText": "Full notification content",
    "category": "msg",
    "time": 1694825600000
  }'
```

#### Expected Success Response (HTTP 200 OK)
```json
{
  "success": true,
  "message": "Notification received",
  "notificationId": "test-001",
  "requestId": "req_..."
}
```

#### Expected Duplicate Response (HTTP 200 OK)
```json
{
  "success": true,
  "message": "Notification already received",
  "notificationId": "test-001",
  "requestId": "req_...",
  "duplicate": true
}
```

---

## 5. MongoDB Shell Verification

Verify stored documents in MongoDB via `mongosh`:

```javascript
// Connect to database
use android_notifications;

// 1. Inspect recent 10 notifications
db.notifications.find().sort({ receivedAt: -1 }).limit(10).pretty();

// 2. Count total saved notifications
db.notifications.countDocuments();

// 3. Inspect delivery attempt logs
db.delivery_attempts.find().sort({ attemptedAt: -1 }).limit(10).pretty();
```

---

## 6. Ubuntu VPS Production Deployment Guide

### Step 1: System Update & Node.js Setup
```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs nginx ufw certbot python3-certbot-nginx
```

### Step 2: Install MongoDB on Ubuntu
```bash
sudo apt-get install -y gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

sudo apt update
sudo apt install -y mongodb-org

sudo systemctl enable mongod
sudo systemctl start mongod
sudo systemctl status mongod
```

### Step 3: PM2 Process Manager Configuration
Install PM2 globally:
```bash
sudo npm install -g pm2 pm2-logrotate
```

Deploy app:
```bash
git clone <your-repo-url> /var/www/android-notification-server
cd /var/www/android-notification-server
npm install
npm run build
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

Configure PM2 log rotation:
```bash
pm2 set pm2-logrotate:max_size 50M
pm2 set pm2-logrotate:retain 10
```

### Step 4: UFW Firewall Setup
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### Step 5: Nginx & Certbot SSL Setup
Link the provided Nginx configuration:
```bash
sudo cp nginx/notification-server.conf /etc/nginx/sites-available/notify.example.com
sudo ln -s /etc/nginx/sites-available/notify.example.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

Obtain Let's Encrypt SSL certificate:
```bash
sudo certbot --nginx -d notify.example.com
```

---

## 7. MongoDB Backup & Restoration

### Backup Database
```bash
mongodump --db=android_notifications --out=/var/backups/mongodb/$(date +%F)
```

### Restore Database
```bash
mongorestore --db=android_notifications /var/backups/mongodb/2026-09-16/android_notifications
```
