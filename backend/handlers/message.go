package handlers

import (
	"encoding/base64"
	"net/http"
	"strconv"

	"pictorial-backend/config"
	"pictorial-backend/models"
	ws "pictorial-backend/websocket"

	"github.com/gin-gonic/gin"
)

// WebSocket hub for broadcasting messages
var Hub *ws.Hub

// CreateMessageRequest represents the message creation request
type CreateMessageRequest struct {
	ChannelID uint    `json:"channel_id" binding:"required"`
	Content   *string `json:"content"`
	ImageData *string `json:"image_data"` // Base64 encoded image
}

// CreateMessage handles message creation
func CreateMessage(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	var req CreateMessageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validate that at least one of content or image is provided
	if (req.Content == nil || *req.Content == "") && (req.ImageData == nil || *req.ImageData == "") {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Message must have at least one of content or image"})
		return
	}

	// Check if channel exists
	var channel models.Channel
	if err := config.DB.First(&channel, req.ChannelID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Channel not found"})
		return
	}

	message := models.Message{
		ChannelID: req.ChannelID,
		UserID:    userID.(uint),
		Content:   req.Content,
	}

	// Decode base64 image if provided
	if req.ImageData != nil && *req.ImageData != "" {
		imageBytes, err := base64.StdEncoding.DecodeString(*req.ImageData)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid image data"})
			return
		}
		message.Image = imageBytes
	}

	if err := config.DB.Create(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create message"})
		return
	}

	// Load user data
	config.DB.Preload("User").First(&message, message.ID)

	response := message.ToResponse()

	// Broadcast message to WebSocket clients in the channel
	if Hub != nil {
		Hub.BroadcastToChannel(req.ChannelID, response)
	}

	c.JSON(http.StatusCreated, response)
}

// GetMessage returns a single message by ID
func GetMessage(c *gin.Context) {
	id := c.Param("id")
	var message models.Message

	if err := config.DB.Preload("User").Preload("Channel").First(&message, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Message not found"})
		return
	}

	c.JSON(http.StatusOK, message.ToResponse())
}

// GetMessageImage returns the image data for a message
func GetMessageImage(c *gin.Context) {
	id := c.Param("id")
	var message models.Message

	if err := config.DB.First(&message, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Message not found"})
		return
	}

	if len(message.Image) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Message has no image"})
		return
	}

	// Return the image as PNG
	c.Data(http.StatusOK, "image/png", message.Image)
}

// DeleteMessage deletes a message
func DeleteMessage(c *gin.Context) {
	id := c.Param("id")
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	var message models.Message
	if err := config.DB.First(&message, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Message not found"})
		return
	}

	// Get current user to check permissions
	var user models.User
	if err := config.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get user"})
		return
	}

	// Check if user owns the message OR is an admin
	if message.UserID != userID.(uint) && !user.IsAdmin() {
		c.JSON(http.StatusForbidden, gin.H{"error": "You can only delete your own messages"})
		return
	}

	if err := config.DB.Delete(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete message"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Message deleted successfully"})
}

// GetMessages returns all messages with pagination
func GetMessages(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	offset := (page - 1) * limit

	var messages []models.Message
	if err := config.DB.
		Preload("User").
		Preload("Channel").
		Order("created_at desc").
		Limit(limit).
		Offset(offset).
		Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch messages"})
		return
	}

	var responses []models.MessageResponse
	for _, msg := range messages {
		responses = append(responses, msg.ToResponse())
	}

	c.JSON(http.StatusOK, responses)
}
