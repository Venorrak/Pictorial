package models

import (
	"time"

	"gorm.io/gorm"
)

// Channel represents a communication channel
type Channel struct {
	ID          uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	Name        string         `gorm:"size:50;not null;unique" json:"name" binding:"required"`
	Description string         `gorm:"type:text" json:"description"`
	CreatedAt   time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
	Messages    []Message      `gorm:"foreignKey:ChannelID" json:"-"`
}
