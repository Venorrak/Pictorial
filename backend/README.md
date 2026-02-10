# Pictorial Backend API

A RESTful API backend for a messaging application built with Go, PostgreSQL, and Docker.

## Features

- **User Authentication**: JWT-based authentication with secure password hashing
- **Channel Management**: Create, read, update, and delete communication channels
- **Messaging**: Send text and/or image messages to channels
- **Real-time Communication**: WebSocket support for instant message delivery
- **RESTful API**: Clean and intuitive API design
- **Database**: PostgreSQL with GORM ORM
- **Containerized**: Docker and Docker Compose support
- **Scalable**: Designed for scalability and maintainability

## Technology Stack

- **Language**: Go 1.21
- **WebSocket**: Gorilla WebSocket
- **Framework**: Gin Web Framework
- **Database**: PostgreSQL 15
- **ORM**: GORM
- **Authentication**: JWT (golang-jwt/jwt)
- **Password Hashing**: bcrypt
- **Containerization**: Docker & Docker Compose

## Project Structure

```
backend/
├── config/          # Database and JWT configuration
├── handlers/        # HTTP request handlers
├── middleware/      # Authentication middleware
├── models/          # Database models
├── websocket/       # WebSocket hub and client management
├── routes/          # API route definitions
├── utils/           # Utility functions (JWT, password hashing)
├── main.go          # Application entry point
├── go.mod           # Go module dependencies
├── Dockerfile       # Docker image definition
├── docker-compose.yml # Docker Compose configuration
└── .env.example     # Environment variables template
```

## Database Schema

### User
- `id`: INT (Primary Key, Auto Increment)
- `name`: VARCHAR(50) (Not Null, Unique)
- `password`: VARCHAR(100) (Not Null, Hashed)
- `role`: VARCHAR(20) (Not Null, Default: 'user') - Either 'user' or 'admin'
- `created_at`: DATETIME
- `updated_at`: DATETIME

### Channel
- `id`: INT (Primary Key, Auto Increment)
- `name`: VARCHAR(50) (Not Null, Unique)
- `description`: TEXT
- `created_at`: DATETIME
- `updated_at`: DATETIME

### Message
- `id`: INT (Primary Key, Auto Increment)
- `channel_id`: INT (Foreign Key -> Channel)
- `user_id`: INT (Foreign Key -> User)
- `content`: TEXT (Optional)
- `image`: BYTEA (Optional PNG image)
- `nb_of_lines`: INT (Required, 1-5, Default: 1)
- `created_at`: DATETIME
- `updated_at`: DATETIME

**Constraints**: 
- At least one of `content` or `image` must be provided
- `nb_of_lines` must be between 1 and 5 (inclusive)

## API Endpoints

### Authentication

#### Register User
```
POST /api/v1/auth/register
Content-Type: application/json

{
  "name": "username",
  "password": "password123"
}

Response: 201 Created
{
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "role": "user",
    "name": "username",
    "created_at": "2026-02-05T12:00:00Z"
  }
}
```

#### Login
```
POST /api/v1/auth/login
Content-Type: application/json

{
  "name": "username",
  "password": "password123"
}

Response: 200 OK
{
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "role": "user",
    "name": "username",
    "created_at": "2026-02-05T12:00:00Z"
  }
}
```

### User (Protected Routes)

#### Get Current User
```
GET /api/v1/me
Authorization: Bearer {token}

Response: 200 OK
{
  "id": 1,
  "role": "user",
  "name": "username",
  "created_at": "2026-02-05T12:00:00Z"
}
```

**Note:** Creating, updating, and deleting channels requires **admin role**.

#### Create Channel (Admin Only) Routes)

#### Create Channel
```
POST /api/v1/channels
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "general",
  "description": "General discussion channel"
}

Response: 201 Created
{
  "id": 1,
  "name": "general",
  "description": "General discussion channel",
  "created_at": "2026-02-05T12:00:00Z"
}
```

#### Get All Channels
```
GET /api/v1/channels
Authorization: Bearer {token}

Response: 200 OK
[
  {
    "id": 1,
    "name": "general",
    "description": "General discussion channel",
    "created_at": "2026-02-05T12:00:00Z"
  }
]
```

#### Get Channel by ID
```
GET /api/v1/channels/:id
Authorization: Bearer {token}

Response: 200 OK
{
  "id": 1,
  "name": "general",
  "description": "General discussion channel",
  "created_at": "2026-02-05T12:00:00Z"
}
```

#### Update Channel
```
PUT /api/v1/channels/:id
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "updated-general",
  "description": "Updated description"
}

Response: 200 OK
{
  "id": 1,
  "name": "updated-general",
  "description": "Updated description",
  "created_at": "2026-02-05T12:00:00Z"
}
```

#### Delete Channel
```
DELETE /api/v1/channels/:id
Authorization: Bearer {token}

Response: 200 OK
{
  "message": "Channel deleted successfully"
}
```

#### Get Channel Messages
```
GET /api/v1/channels/:id/messages?page=1&limit=50
Authorization: Bearer {token}

Response: 200 OK
[
  {
    "id": 1,
    "channel_id": 1,
    "user_id": 1,
    "content": "Hello world!",
    "has_image": false,
    "nb_of_lines": 1,
    "user": {
      "id": 1,
      "name": "username",
      "created_at": "2026-02-05T12:00:00Z"
    },
    "created_at": "2026-02-05T12:00:00Z"
  }
]
```

### Messages (Protected Routes)

#### Create Message
```
POST /api/v1/messages
Authorization: Bearer {token}
Content-Type: application/json

{
  "channel_id": 1,
  "content": "Hello world!",
  "image_data": "base64_encoded_png_image_data", // optional
  "nb_of_lines": 1 // required, must be between 1 and 5
}

Response: 201 Created
{
  "id": 1,
  "channel_id": 1,
  "user_id": 1,
  "content": "Hello world!",
  "has_image": false,
  "nb_of_lines": 1,
  "user": {
    "id": 1,
    "name": "username",
    "created_at": "2026-02-05T12:00:00Z"
  },
  "created_at": "2026-02-05T12:00:00Z"
}
```

#### Get All Messages
```
GET /api/v1/messages?page=1&limit=50
Authorization: Bearer {token}

Response: 200 OK
[...]
```

#### Get Message by ID
```
GET /api/v1/messages/:id
Authorization: Bearer {token}

Response: 200 OK
{
  "id": 1,
  "channel_id": 1,
  "user_id": 1,
  "content": "Hello world!",
  "has_image": false,
  "nb_of_lines": 1,
  "user": {...},
  "created_at": "2026-02-05T12:00:00Z"
}
```

#### Get Message Image
```
GET /api/v1/messages/:id/image
Authorization: Bearer {token}

Response: 200 OK
Content-Type: image/png
[binary image data]
```

#### Delete Message

Users can delete their own messages. Admins can delete any message.
```
DELETE /api/v1/messages/:id
Authorization: Bearer {token}

Response: 200 OK
{
  "message": "Message deleted successfully"
}
```

### WebSocket (Real-time Communication)

The application uses a **single WebSocket connection per user** that can subscribe to multiple channels dynamically. This eliminates the need to reconnect when switching between channels.

#### Connect to WebSocket
```
GET /api/v1/ws?token={jwt_token}
Upgrade: websocket

This endpoint upgrades the HTTP connection to a WebSocket connection.
The JWT token must be passed as a URL query parameter.
Each user maintains one connection and subscribes/unsubscribes to channels as needed.

Example:
ws://localhost:8080/api/v1/ws?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Client-to-Server Messages:**

Subscribe to a channel:
```json
{
  "type": "subscribe",
  "channel_id": 1
}
```

Unsubscribe from a channel:
```json
{
  "type": "unsubscribe",
  "channel_id": 1
}
```

**Server-to-Client Messages:**

When a new message is created in any subscribed channel, all subscribed clients receive:
```json
{
  "id": 1,
  "channel_id": 1,
  "user_id": 1,
  "content": "Hello world!",
  "has_image": false,
  "nb_of_lines": 1,
  "user": {
    "id": 1,
    "name": "username",
    "created_at": "2026-02-05T12:00:00Z"
  },
  "created_at": "2026-02-05T12:00:00Z"
}
```

**Client Example (JavaScript):**
```javascript
const token = 'your_jwt_token';
const ws = new WebSocket(`ws://localhost:8080/api/v1/ws`);

ws.onopen = () => {
  console.log('Connected to WebSocket');
  
  // Subscribe to initial channel
  ws.send(JSON.stringify({
    type: 'subscribe',
    channel_id: 1
  }));
};

ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  console.log('New message in channel', message.channel_id, ':', message);
  
  // Update UI based on which channel the message belongs to
  displayMessage(message);
};

// When user switches to a different channel
function switchChannel(oldChannelId, newChannelId) {
  // Unsubscribe from old channel
  ws.send(JSON.stringify({
    type: 'unsubscribe',
    channel_id: oldChannelId
  }));
  
  // Subscribe to new channel
  ws.send(JSON.stringify({
    type: 'subscribe',
    channel_id: newChannelId
  }));
}

// Subscribe to multiple channels simultaneously
function subscribeToMultipleChannels(channelIds) {
  channelIds.forEach(channelId => {
    ws.send(JSON.stringify({
      type: 'subscribe',
      channel_id: channelId
    }));
  });
}

ws.onerror = (error) => {
  console.error('WebSocket error:', error);
};

ws.onclose = () => {
  console.log('Disconnected from WebSocket');
};
```

**Architecture Benefits:**
- **Efficient**: Single persistent connection per user, no reconnection overhead
- **Flexible**: Subscribe to multiple channels simultaneously
- **Instant switching**: Change channels by sending subscribe/unsubscribe messages
- **Scalable**: Server manages subscriptions in memory without maintaining multiple connections per user

## Setup and Installation

### Prerequisites
- Docker and Docker Compose installed
- OR Go 1.21+ and PostgreSQL 15+

### Option 1: Using Docker Compose (Recommended)

1. Clone the repository
2. Navigate to the backend directory:
   ```bash
   cd backend
   ```

3. Create a `.env` file (optional, defaults will be used):
   ```bash
   cp .env.example .env
   # Edit .env with your preferred values
   ```

4. Start the services:
   ```bash
   docker compose up -d
   ```

5. The API will be available at `http://localhost:8080`

6. Check health:
   ```bash
   curl http://localhost:8080/health
   ```

### Option 2: Development Setup with Hot Reload

For development with automatic code reloading:

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create a `.env` file (optional):
   ```bash
   cp .env.example .env
   ```

3. Start the development environment:
   ```bash
   docker compose -f docker-compose.dev.yml up
   ```

4. The API will be available at `http://localhost:8080`

5. Make changes to your code - the server will automatically reload!

6. View logs:
   ```bash
   docker compose -f docker-compose.dev.yml logs -f backend
   ```

7. Stop the development environment:
   ```bash
   docker compose -f docker-compose.dev.yml down
   ```

**Development Features:**
- **Hot Reload**: Powered by [Air](https://github.com/cosmtrek/air) - changes are detected and the server restarts automatically
- **Debug Mode**: Detailed logging enabled
- **Go Modules Cache**: Speeds up rebuilds
- **Isolated Environment**: Separate from production containers

### Option 3: Manual Setup

1. Install PostgreSQL and create a database:
   ```sql
   CREATE DATABASE pictorial;
   ```

2. Set environment variables:
   ```bash
   export DB_HOST=localhost
   export DB_PORT=5432
   export DB_USER=postgres
   export DB_PASSWORD=postgres
   export DB_NAME=pictorial
   export JWT_SECRET=your-secret-key
   export PORT=8080
   ```

3. Install dependencies:
   ```bash
   go mod download
   ```

4. Run the application:
   ```bash
   go run main.go
   ```

## Development

### Running Tests
```bash
go test ./...
```

### Building Binary
```bash
go build -o pictorial-backend
./pictorial-backend
```

### Building Docker Image
```bash
docker build -t pictorial-backend .
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_HOST` | Database host | `localhost` |
| `DB_PORT` | Database port | `5432` |
| `DB_USER` | Database user | `postgres` |
| `DB_PASSWORD` | Database password | `postgres` |
| `DB_NAME` | Database name | `pictorial` |
| `JWT_SECRET` | Secret key for JWT signing | `your-super-secret-jwt-key-change-this-in-production` |
| `PORT` | API server port | `8080` |
| `GIN_MODE` | Gin mode (debug/release) | `debug` |
Role-Based Access Control**: Admin role for privileged operations
- **WebSocket Security**: WebSocket connections require JWT authentication
- **CORS Support**: Configurable cross-origin resource sharing
- **Input Validation**: Request validation using Gin binding
- **SQL Injection Protection**: GORM provides parameterized queries
- **Authorization**: Users can only delete their own messages (admins can delete any)
- **WebSocket Security**: WebSocket connections require JWT authentication
- **CORS Support**: Configurable cross-origin resource sharing
- **Input Validation**: Request validation using Gin binding
- **SQL Injection Protection**: GORM provides parameterized queries
- **Authorization**: Users can only delete their own messages

## Scalability Considerations

- **Stateless Design**: JWT-based auth allows horizontal scaling
- **WebSocket Hub**: Centralized hub manages WebSocket connections efficiently
- **Channel-based Broadcasting**: Messages are only sent to clients subscribed to specific channels
- **Database Indexing**: Foreign keys and commonly queried fields are indexed
- **Pagination**: Message endpoints support pagination
- **Connection Pooling**: GORM manages database connections efficiently
- **Goroutines**: WebSocket clients run in separate goroutines for concurrent handling
- **Docker Support**: Easy deployment and scaling with containers

## Error Handling

The API returns standard HTTP status codes:
- `200 OK`: Successful request
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `409 Conflict`: Duplicate resource (e.g., username exists)
- `500 Internal Server Error`: Server error

Error responses follow this format:
```json
{
  "error": "Error message description"
}
```

## License

This project is part of the Pictorial messaging application.
