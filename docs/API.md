# MACKHAN API Reference

HTTP APIs used by the Flutter Android app (`mobile/`).

| Service | Base URL (local) | Emulator |
|---------|------------------|----------|
| Backend | `http://localhost:3000` | `http://10.0.2.2:3000` |
| ML | `http://localhost:8000` | `http://10.0.2.2:8000` |

Auth: HS256 JWT. Access token in `Authorization: Bearer <accessToken>`. Backend and ML share `JWT_SECRET`.

Password rule: ≥8 characters, ≥1 uppercase letter, ≥1 digit.

---

## Backend error envelope

```json
{
  "success": false,
  "message": "Human-readable summary",
  "code": "ERROR_CODE",
  "errors": [{ "field": "email", "message": "…" }]
}
```

| HTTP | `code` | When |
|------|--------|------|
| 400 | `VALIDATION_ERROR` | Joi / multer / bad input |
| 401 | `UNAUTHORIZED` | Missing/invalid JWT or bad credentials |
| 403 | `EMAIL_NOT_VERIFIED` | Login before verify |
| 404 | `NOT_FOUND` | User / OTP missing |
| 409 | `CONFLICT` | Email already registered |
| 429 | `RATE_LIMITED` | Too many requests |
| 500 | `INTERNAL_ERROR` | Unhandled server error |

### Rate limits (per IP, 15-minute window)

| Routes | Limit |
|--------|-------|
| `/api/auth/register`, `/login`, `/forgot-password` | 5 |
| `/api/auth/verify`, `/reset-password` | 10 |
| Other `/api/*` | 100 |

---

## Backend — Auth

### `POST /api/auth/register`

Creates an unverified user and emails a 6-digit OTP.

```bash
curl -s -X POST http://localhost:3000/api/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"fullName":"Ada Lovelace","email":"ada@example.com","password":"Password1"}'
```

**201**

```json
{ "message": "Registration successful. Check email for verification code.", "email": "ada@example.com" }
```

| Status | Code |
|--------|------|
| 400 | `VALIDATION_ERROR` |
| 409 | `CONFLICT` |

---

### `POST /api/auth/verify`

```bash
curl -s -X POST http://localhost:3000/api/auth/verify \
  -H 'Content-Type: application/json' \
  -d '{"email":"ada@example.com","code":"123456"}'
```

**200** `{ "message": "Email verified" }`

| Status | Code |
|--------|------|
| 400 | `VALIDATION_ERROR` (bad/expired code) |
| 404 | `NOT_FOUND` |

---

### `POST /api/auth/login`

```bash
curl -s -X POST http://localhost:3000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"ada@example.com","password":"Password1"}'
```

**200**

```json
{
  "accessToken": "<jwt>",
  "refreshToken": "<jwt>",
  "user": {
    "id": "uuid",
    "fullName": "Ada Lovelace",
    "email": "ada@example.com",
    "isVerified": true,
    "profileImageUrl": null,
    "createdAt": "2026-01-01T00:00:00.000Z",
    "updatedAt": "2026-01-01T00:00:00.000Z"
  }
}
```

| Status | Code |
|--------|------|
| 401 | `UNAUTHORIZED` |
| 403 | `EMAIL_NOT_VERIFIED` |

---

### `POST /api/auth/forgot-password`

Always returns the same message (no email enumeration).

```bash
curl -s -X POST http://localhost:3000/api/auth/forgot-password \
  -H 'Content-Type: application/json' \
  -d '{"email":"ada@example.com"}'
```

**200** `{ "message": "If that email exists, a reset code has been sent." }`

---

### `POST /api/auth/reset-password`

```bash
curl -s -X POST http://localhost:3000/api/auth/reset-password \
  -H 'Content-Type: application/json' \
  -d '{"email":"ada@example.com","code":"123456","newPassword":"Password2"}'
```

**200** `{ "message": "Password reset successful" }`

| Status | Code |
|--------|------|
| 400 | `VALIDATION_ERROR` |
| 404 | `NOT_FOUND` |

---

### `POST /api/auth/refresh`

Rotates tokens. Body carries the refresh JWT (no access Bearer required).

```bash
curl -s -X POST http://localhost:3000/api/auth/refresh \
  -H 'Content-Type: application/json' \
  -d '{"refreshToken":"<refresh jwt>"}'
```

**200** `{ "accessToken": "<jwt>", "refreshToken": "<jwt>" }`

| Status | Code |
|--------|------|
| 401 | `UNAUTHORIZED` |

---

### `POST /api/auth/logout`

Requires access Bearer **and** refresh token in body (revokes refresh).

```bash
curl -s -X POST http://localhost:3000/api/auth/logout \
  -H 'Authorization: Bearer <accessToken>' \
  -H 'Content-Type: application/json' \
  -d '{"refreshToken":"<refresh jwt>"}'
```

**200** `{ "message": "Logged out" }`

| Status | Code |
|--------|------|
| 401 | `UNAUTHORIZED` |

---

## Backend — Users

All routes require `Authorization: Bearer <accessToken>`.

### `GET /api/users/me`

```bash
curl -s http://localhost:3000/api/users/me \
  -H 'Authorization: Bearer <accessToken>'
```

**200** — `PublicUser` object (same shape as `user` in login).

| Status | Code |
|--------|------|
| 401 | `UNAUTHORIZED` |
| 404 | `NOT_FOUND` |

---

### `PUT /api/users/me`

`multipart/form-data`. At least one of `fullName` or `profileImage`.

| Field | Type | Notes |
|-------|------|-------|
| `fullName` | text | ≥2 chars |
| `profileImage` | file | `image/jpeg` or `image/png`, ≤5MB |

```bash
curl -s -X PUT http://localhost:3000/api/users/me \
  -H 'Authorization: Bearer <accessToken>' \
  -F 'fullName=Ada L.' \
  -F 'profileImage=@./avatar.png'
```

**200** — updated `PublicUser`.

| Status | Code |
|--------|------|
| 400 | `VALIDATION_ERROR` |
| 401 | `UNAUTHORIZED` |
| 404 | `NOT_FOUND` |

---

### `PUT /api/users/me/password`

```bash
curl -s -X PUT http://localhost:3000/api/users/me/password \
  -H 'Authorization: Bearer <accessToken>' \
  -H 'Content-Type: application/json' \
  -d '{"currentPassword":"Password1","newPassword":"Password2","refreshToken":"<optional>"}'
```

**200** `{ "message": "Password updated" }`

| Status | Code |
|--------|------|
| 400 | `VALIDATION_ERROR` |
| 401 | `UNAUTHORIZED` (wrong current password) |
| 404 | `NOT_FOUND` |

---

## Backend — Health

### `GET /api/health`

No auth.

```bash
curl -s http://localhost:3000/api/health
```

**200** `{ "status": "ok", "timestamp": "2026-01-01T00:00:00.000Z" }`

---

## ML service

FastAPI errors use `{ "detail": "…" }` (not the backend envelope).

### `GET /health`

```bash
curl -s http://localhost:8000/health
```

**200**

```json
{
  "status": "healthy",
  "model_loaded": true,
  "model_type": "modnet",
  "version": "1.0.0"
}
```

---

### `POST /inference/segment`

HQ background removal. Requires access JWT (same secret as backend).

| Field | Type | Notes |
|-------|------|-------|
| `file` | file | JPEG/PNG required |
| `quality` | form | `standard` (default) or `high` |

Max upload: `MAX_IMAGE_SIZE_MB` (default **10**).

```bash
curl -s -X POST http://localhost:8000/inference/segment \
  -H 'Authorization: Bearer <accessToken>' \
  -F 'file=@./capture.jpg' \
  -F 'quality=high' \
  -o segmented.png
```

**200** binary `image/png`  
Header: `Content-Disposition: attachment; filename=segmented.png`

| Status | Detail |
|--------|--------|
| 401 | Invalid / missing token |
| 413 | File too large |
| 422 | Bad format / quality / decode |
| 500 | Model / inference failure |

---

### `POST /inference/benchmark`

No auth. Times repeated inference.

```bash
curl -s -X POST http://localhost:8000/inference/benchmark \
  -H 'Content-Type: application/json' \
  -d '{"iterations":10}'
```

| Field | Type | Notes |
|-------|------|-------|
| `iterations` | int | 1–100, default 10 |
| `image_path` | string? | Optional path to sample image on server |

**200**

```json
{
  "iterations": 10,
  "avg_latency_ms": 42.5,
  "fps": 23.5,
  "p95_latency_ms": 55.0
}
```

| Status | Detail |
|--------|--------|
| 422 | Validation / missing image file |
| 500 | Model not loaded |

---

## Endpoint index

**Backend (11):**  
`POST` register · verify · login · forgot-password · reset-password · refresh · logout ·  
`GET` users/me · health ·  
`PUT` users/me · users/me/password  

**ML (3):**  
`GET` /health · `POST` /inference/segment · `POST` /inference/benchmark  

> PLAN §11.1 said “13 backend”; the shipped API has **11** backend routes + **3** ML routes (matches PLAN §6–§7).
