package models

import (
	"errors"
	"time"

	"gorm.io/gorm"
)

// Message represents a message in a channel
type Message struct {
	ID        uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	ChannelID uint           `gorm:"not null;index" json:"channel_id" binding:"required"`
	UserID    uint           `gorm:"not null;index" json:"user_id" binding:"required"`
	Content   *string        `gorm:"type:text" json:"content"`
	Image     []byte         `gorm:"type:bytea" json:"image,omitempty"`
	NbOfLines int            `gorm:"not null;default:1;check:nb_of_lines >= 1 AND nb_of_lines <= 5" json:"nb_of_lines" binding:"required,min=1,max=5"`
	CreatedAt time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
	Channel   Channel        `gorm:"foreignKey:ChannelID" json:"channel,omitempty"`
	User      User           `gorm:"foreignKey:UserID" json:"user,omitempty"`
}

// MessageResponse represents the message data returned to the client
type MessageResponse struct {
	ID        uint         `json:"id"`
	ChannelID uint         `json:"channel_id"`
	UserID    uint         `json:"user_id"`
	Content   *string      `json:"content"`
	HasImage  bool         `json:"has_image"`
	NbOfLines int          `json:"nb_of_lines"`
	User      UserResponse `json:"user"`
	CreatedAt time.Time    `json:"created_at"`
}

// ToResponse converts Message to MessageResponse
func (m *Message) ToResponse() MessageResponse {
	return MessageResponse{
		ID:        m.ID,
		ChannelID: m.ChannelID,
		UserID:    m.UserID,
		Content:   m.Content,
		HasImage:  len(m.Image) > 0,
		NbOfLines: m.NbOfLines,
		User:      m.User.ToResponse(),
		CreatedAt: m.CreatedAt,
	}
}

// BeforeCreate validates that at least one of content or image is provided
func (m *Message) BeforeCreate(tx *gorm.DB) error {
	if (m.Content == nil || *m.Content == "") && len(m.Image) == 0 {
		return errors.New("message must have at least one of content or image")
	}
	return nil
}

// BeforeUpdate validates that at least one of content or image is provided
func (m *Message) BeforeUpdate(tx *gorm.DB) error {
	if (m.Content == nil || *m.Content == "") && len(m.Image) == 0 {
		return errors.New("message must have at least one of content or image")
	}
	return nil
}
