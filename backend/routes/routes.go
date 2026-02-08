package routes

import (
	"pictorial-backend/handlers"
	"pictorial-backend/middleware"
	ws "pictorial-backend/websocket"

	"github.com/gin-gonic/gin"
)

// SetupRoutes configures all API routes
func SetupRoutes(router *gin.Engine, hub *ws.Hub) {
	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// API v1 group
	v1 := router.Group("/api/v1")
	{
		// Public routes (no authentication required)
		auth := v1.Group("/auth")
		{
			auth.POST("/register", handlers.Register)
			auth.POST("/login", handlers.Login)
		}

		// WebSocket endpoint (token passed in URL query parameter)
		v1.GET("/ws", handlers.WSHandler(hub))

		// Protected routes (authentication required)
		protected := v1.Group("")
		protected.Use(middleware.AuthMiddleware())
		{
			// User routes
			protected.GET("/me", handlers.GetCurrentUser)

			// Channel routes
			channels := protected.Group("/channels")
			{
				// Admin-only routes
				channels.POST("", middleware.AdminMiddleware(), handlers.CreateChannel)
				channels.PUT("/:id", middleware.AdminMiddleware(), handlers.UpdateChannel)
				channels.DELETE("/:id", middleware.AdminMiddleware(), handlers.DeleteChannel)

				// All authenticated users can read
				channels.GET("", handlers.GetChannels)
				channels.GET("/:id", handlers.GetChannel)
				channels.GET("/:id/messages", handlers.GetChannelMessages)
			}

			// Message routes
			messages := protected.Group("/messages")
			{
				messages.POST("", handlers.CreateMessage)
				messages.GET("", handlers.GetMessages)
				messages.GET("/:id", handlers.GetMessage)
				messages.GET("/:id/image", handlers.GetMessageImage)
				messages.DELETE("/:id", handlers.DeleteMessage)
			}
		}
	}
}
