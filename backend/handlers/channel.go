package handlers

import (
	"net/http"
	"strconv"

	"pictorial-backend/config"
	"pictorial-backend/models"

	"github.com/gin-gonic/gin"
)

// CreateChannel handles channel creation
func CreateChannel(c *gin.Context) {
	var channel models.Channel
	if err := c.ShouldBindJSON(&channel); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := config.DB.Create(&channel).Error; err != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Channel name already exists"})
		return
	}

	c.JSON(http.StatusCreated, channel)
}

// GetChannels returns all channels
func GetChannels(c *gin.Context) {
	var channels []models.Channel
	if err := config.DB.Order("created_at desc").Find(&channels).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch channels"})
		return
	}

	c.JSON(http.StatusOK, channels)
}

// GetChannel returns a single channel by ID
func GetChannel(c *gin.Context) {
	id := c.Param("id")
	var channel models.Channel

	if err := config.DB.First(&channel, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Channel not found"})
		return
	}

	c.JSON(http.StatusOK, channel)
}

// UpdateChannel updates a channel
func UpdateChannel(c *gin.Context) {
	id := c.Param("id")
	var channel models.Channel

	if err := config.DB.First(&channel, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Channel not found"})
		return
	}

	var updateData models.Channel
	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Update only allowed fields
	updates := map[string]interface{}{}
	if updateData.Name != "" {
		updates["name"] = updateData.Name
	}
	if updateData.Description != "" {
		updates["description"] = updateData.Description
	}

	if err := config.DB.Model(&channel).Updates(updates).Error; err != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Channel name already exists"})
		return
	}

	c.JSON(http.StatusOK, channel)
}

// DeleteChannel deletes a channel
func DeleteChannel(c *gin.Context) {
	id := c.Param("id")
	var channel models.Channel

	if err := config.DB.First(&channel, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Channel not found"})
		return
	}

	if err := config.DB.Delete(&channel).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete channel"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Channel deleted successfully"})
}

// GetChannelMessages returns all messages for a specific channel
func GetChannelMessages(c *gin.Context) {
	id := c.Param("id")
	channelID, err := strconv.ParseUint(id, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid channel ID"})
		return
	}

	// Check if channel exists
	var channel models.Channel
	if err := config.DB.First(&channel, channelID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Channel not found"})
		return
	}

	// Get pagination parameters
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	offset := (page - 1) * limit

	var messages []models.Message
	if err := config.DB.
		Preload("User").
		Where("channel_id = ?", channelID).
		Order("created_at desc").
		Limit(limit).
		Offset(offset).
		Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch messages"})
		return
	}

	// Convert to response format
	var responses []models.MessageResponse
	for _, msg := range messages {
		responses = append(responses, msg.ToResponse())
	}

	c.JSON(http.StatusOK, responses)
}
