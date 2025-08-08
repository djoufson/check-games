# Check-Game API Specification

## Base URL
- Development: `http://localhost:3000/api/v1`
- Production: `https://api.checkgame.com/api/v1`

## Authentication
- **Type**: Bearer Token (JWT)
- **Header**: `Authorization: Bearer <token>`
- **Token Expiration**: 24 hours
- **Refresh Token Expiration**: 30 days

## HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `422` - Validation Error
- `500` - Internal Server Error

## API Endpoints

### Authentication

#### POST /auth/register
Register a new user account.

**Request Body:**
```json
{
  "username": "string (3-20 chars, alphanumeric + underscore)",
  "email": "string (valid email)",
  "password": "string (min 8 chars)"
}
```

**Response (201):**
```json
{
  "user": {
    "id": "uuid",
    "username": "string",
    "email": "string",
    "createdAt": "timestamp"
  },
  "tokens": {
    "accessToken": "string",
    "refreshToken": "string"
  }
}
```

#### POST /auth/login
Authenticate user and get tokens.

**Request Body:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response (200):**
```json
{
  "user": {
    "id": "uuid",
    "username": "string",
    "email": "string"
  },
  "tokens": {
    "accessToken": "string",
    "refreshToken": "string"
  }
}
```

#### POST /auth/refresh
Refresh access token.

**Request Body:**
```json
{
  "refreshToken": "string"
}
```

**Response (200):**
```json
{
  "accessToken": "string"
}
```

#### POST /auth/logout
Invalidate refresh token.

**Request Body:**
```json
{
  "refreshToken": "string"
}
```

**Response (200):**
```json
{
  "message": "Logged out successfully"
}
```

### User Management

#### GET /users/profile
Get current user profile. **[Requires Auth]**

**Response (200):**
```json
{
  "id": "uuid",
  "username": "string",
  "email": "string",
  "stats": {
    "totalGames": "number",
    "wins": "number",
    "losses": "number",
    "winRate": "number"
  },
  "createdAt": "timestamp"
}
```

#### PUT /users/profile
Update user profile. **[Requires Auth]**

**Request Body:**
```json
{
  "username": "string (optional)",
  "email": "string (optional)"
}
```

### Session Management

#### POST /sessions
Create a new game session. **[Requires Auth]**

**Request Body:**
```json
{
  "name": "string (optional, max 50 chars)",
  "maxPlayers": "number (2-8, default: 4)",
  "isPrivate": "boolean (default: false)"
}
```

**Response (201):**
```json
{
  "id": "uuid",
  "name": "string",
  "code": "string (6-char join code)",
  "maxPlayers": "number",
  "currentPlayers": "number",
  "isPrivate": "boolean",
  "status": "waiting | active | completed",
  "createdBy": "uuid",
  "createdAt": "timestamp",
  "joinUrl": "string"
}
```

#### GET /sessions/:id
Get session details.

**Response (200):**
```json
{
  "id": "uuid",
  "name": "string",
  "code": "string",
  "maxPlayers": "number",
  "currentPlayers": "number",
  "isPrivate": "boolean",
  "status": "string",
  "createdBy": "uuid",
  "players": [
    {
      "id": "uuid",
      "username": "string",
      "isAnonymous": "boolean",
      "joinedAt": "timestamp",
      "isActive": "boolean"
    }
  ],
  "currentGame": {
    "id": "uuid",
    "gameNumber": "number",
    "status": "active | completed",
    "startedAt": "timestamp"
  },
  "tournament": {
    "gamesPlayed": "number",
    "eliminatedPlayers": ["uuid"],
    "currentRound": "number"
  }
}
```

#### POST /sessions/:id/join
Join a session.

**Request Body:**
```json
{
  "anonymousName": "string (optional, for anonymous users)"
}
```

**Response (200):**
```json
{
  "sessionToken": "string (special token for this session)",
  "player": {
    "id": "uuid",
    "username": "string",
    "isAnonymous": "boolean"
  }
}
```

#### POST /sessions/join-by-code
Join session using join code.

**Request Body:**
```json
{
  "code": "string (6-char code)",
  "anonymousName": "string (optional)"
}
```

#### DELETE /sessions/:id/leave
Leave a session. **[Requires Auth or Session Token]**

**Response (200):**
```json
{
  "message": "Left session successfully"
}
```

#### GET /sessions
List public sessions and user's sessions. **[Optional Auth]**

**Query Parameters:**
- `status`: `waiting | active | completed`
- `page`: `number (default: 1)`
- `limit`: `number (default: 10, max: 50)`

**Response (200):**
```json
{
  "sessions": [
    {
      "id": "uuid",
      "name": "string",
      "currentPlayers": "number",
      "maxPlayers": "number",
      "status": "string",
      "createdAt": "timestamp"
    }
  ],
  "pagination": {
    "page": "number",
    "limit": "number",
    "total": "number",
    "totalPages": "number"
  }
}
```

### Game Management

#### POST /sessions/:sessionId/games/start
Start a new game in session. **[Requires Auth - Session Creator]**

**Response (201):**
```json
{
  "gameId": "uuid",
  "message": "Game started successfully"
}
```

#### GET /sessions/:sessionId/games/:gameId
Get game details. **[Requires Session Token]**

**Response (200):**
```json
{
  "id": "uuid",
  "gameNumber": "number",
  "status": "active | completed",
  "players": [
    {
      "id": "uuid",
      "username": "string",
      "handSize": "number",
      "isCurrentPlayer": "boolean",
      "isEliminated": "boolean"
    }
  ],
  "currentCard": {
    "suit": "spades | hearts | diamonds | clubs",
    "rank": "A | 2-10 | J | Q | K | Joker",
    "color": "red | black"
  },
  "drawPileSize": "number",
  "discardPileSize": "number",
  "currentPlayerTurn": "uuid",
  "gameState": "waiting | playing | finished",
  "winner": "uuid (if completed)",
  "loser": "uuid (if completed)"
}
```

#### GET /sessions/:sessionId/games
List games in session. **[Requires Session Token]**

**Response (200):**
```json
{
  "games": [
    {
      "id": "uuid",
      "gameNumber": "number",
      "status": "string",
      "startedAt": "timestamp",
      "completedAt": "timestamp (if completed)",
      "winner": "uuid (if completed)",
      "loser": "uuid (if completed)"
    }
  ]
}
```

## Error Responses

All error responses follow this format:

```json
{
  "error": {
    "code": "string",
    "message": "string",
    "details": {} // optional additional details
  }
}
```

### Common Error Codes
- `VALIDATION_ERROR` - Request validation failed
- `USER_NOT_FOUND` - User doesn't exist
- `SESSION_NOT_FOUND` - Session doesn't exist
- `SESSION_FULL` - Session has reached maximum players
- `UNAUTHORIZED` - Authentication required
- `FORBIDDEN` - Access denied
- `DUPLICATE_EMAIL` - Email already registered
- `DUPLICATE_USERNAME` - Username already taken
- `INVALID_CREDENTIALS` - Login failed
- `EXPIRED_TOKEN` - Token has expired
- `INVALID_TOKEN` - Token is malformed or invalid

## Rate Limiting
- Authentication endpoints: 5 requests per minute per IP
- Session creation: 10 requests per hour per user
- General API: 100 requests per minute per user
- WebSocket connections: 1 per user per session

## Pagination
All list endpoints support pagination:

**Query Parameters:**
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 10, max: 50)

**Response includes:**
```json
{
  "pagination": {
    "page": "number",
    "limit": "number",
    "total": "number",
    "totalPages": "number"
  }
}
```