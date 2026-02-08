package main

import (
	"log"
	"os"

	"pictorial-backend/config"
	"pictorial-backend/handlers"
	"pictorial-backend/routes"
	ws "pictorial-backend/websocket"

	"github.com/gin-gonic/gin"
)

func main() {
	// Initialize database connection
	config.ConnectDatabase()

	// Run migrations
	config.MigrateDB()

	// Initialize WebSocket hub
	hub := ws.NewHub()
	handlers.Hub = hub
	go hub.Run()
	log.Println("WebSocket hub started")

	// Set Gin mode
	if os.Getenv("GIN_MODE") == "" {
		gin.SetMode(gin.DebugMode)
	}

	// Create router
	router := gin.Default()

	// CORS middleware
	router.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// Setup routes
	routes.SetupRoutes(router, hub)

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
