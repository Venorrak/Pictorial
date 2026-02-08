package config

import "os"

// GetJWTSecret returns the JWT secret from environment variable
func GetJWTSecret() []byte {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = "your-super-secret-jwt-key-change-this-in-production"
	}
	return []byte(secret)
}
