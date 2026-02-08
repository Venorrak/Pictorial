package models

import (
	"time"

	"gorm.io/gorm"
)

// User represents a user in the system
type User struct {
	ID        uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	Name      string         `gorm:"size:50;not null;unique" json:"name" binding:"required"`
	Password  string         `gorm:"size:100;not null" json:"-"`
	Role      string         `gorm:"size:20;not null;default:'user'" json:"role"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
	Messages  []Message      `gorm:"foreignKey:UserID" json:"-"`
}

// IsAdmin checks if the user has admin role
func (u *User) IsAdmin() bool {
	return u.Role == "admin"
}

// UserResponse represents the user data returned to the client (without password)
type UserResponse struct {
	ID        uint      `json:"id"`
	Name      string    `json:"name"`
	Role      string    `json:"role"`
	CreatedAt time.Time `json:"created_at"`
}

// ToResponse converts User to UserResponse
func (u *User) ToResponse() UserResponse {
	return UserResponse{
		ID:        u.ID,
		Name:      u.Name,
		Role:      u.Role,
		CreatedAt: u.CreatedAt,
	}
}
