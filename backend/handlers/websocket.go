package handlers

import (
	"log"
	"net/http"

	"pictorial-backend/config"
	"pictorial-backend/utils"
	ws "pictorial-backend/websocket"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		// Allow all origins in development
		// In production, check the origin header
		return true
	},
}

// WSHandler handles WebSocket connections
func WSHandler(hub *ws.Hub) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Try to get token from URL query parameter
		token := c.Query("token")
		if token == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Token is required"})
			return
		}

		// Validate token and extract user ID
		claims, err := utils.ValidateToken(token, config.GetJWTSecret())
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			return
		}

		userID := claims.UserID

		// Upgrade HTTP connection to WebSocket
		conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
		if err != nil {
			log.Printf("Failed to upgrade connection: %v", err)
			return
		}

		// Create new client
		client := ws.NewClient(hub, conn, userID)

		// Register client with hub
		hub.Register(client)

		// Start client goroutines
		go client.WritePump()
		go client.ReadPump()
	}
}
