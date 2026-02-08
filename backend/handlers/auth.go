package handlers

import (
	"net/http"

	"pictorial-backend/config"
	"pictorial-backend/models"
	"pictorial-backend/utils"

	"github.com/gin-gonic/gin"
)

// RegisterRequest represents the registration request body
type RegisterRequest struct {
	Name     string `json:"name" binding:"required,min=3,max=50"`
	Password string `json:"password" binding:"required,min=6"`
}

// LoginRequest represents the login request body
type LoginRequest struct {
	Name     string `json:"name" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// AuthResponse represents the authentication response
type AuthResponse struct {
	Token string              `json:"token"`
	User  models.UserResponse `json:"user"`
}

// Register handles user registration
func Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Hash password
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// Create user
	user := models.User{
		Name:     req.Name,
		Password: hashedPassword,
		Role:     "user", // Default role
	}

	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Username already exists"})
		return
	}

	// Generate token
	token, err := utils.GenerateToken(user.ID, user.Name, config.GetJWTSecret())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusCreated, AuthResponse{
		Token: token,
		User:  user.ToResponse(),
	})
}

// Login handles user authentication
func Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Find user
	var user models.User
	if err := config.DB.Where("name = ?", req.Name).First(&user).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	// Check password
	if err := utils.CheckPassword(user.Password, req.Password); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	// Generate token
	token, err := utils.GenerateToken(user.ID, user.Name, config.GetJWTSecret())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, AuthResponse{
		Token: token,
		User:  user.ToResponse(),
	})
}

// GetCurrentUser returns the currently authenticated user's information
func GetCurrentUser(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	var user models.User
	if err := config.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	c.JSON(http.StatusOK, user.ToResponse())
}
