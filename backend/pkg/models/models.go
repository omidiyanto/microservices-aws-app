package models

import "time"

// User represents a MiNo user
type User struct {
	UserID    string `json:"userId" dynamodbav:"userId"`
	Email     string `json:"email" dynamodbav:"email"`
	Password  string `json:"-" dynamodbav:"password"` // Password hash, not sent to client
	CreatedAt string `json:"createdAt" dynamodbav:"createdAt"`
}

// Note represents a user's note
type Note struct {
	NoteID    string `json:"noteId" dynamodbav:"noteId"`
	UserID    string `json:"userId" dynamodbav:"userId"`
	Title     string `json:"title" dynamodbav:"title"`
	Content   string `json:"content" dynamodbav:"content"`
	CreatedAt string `json:"createdAt" dynamodbav:"createdAt"`
	UpdatedAt string `json:"updatedAt" dynamodbav:"updatedAt"`
}

// UserCredentials represents login credentials
type UserCredentials struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// UserRegistration represents registration data
type UserRegistration struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// AuthResponse represents the response after authentication
type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

// APIResponse represents a standard API response
type APIResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// GetTimeNow returns the current time in ISO8601 format
func GetTimeNow() string {
	return time.Now().UTC().Format(time.RFC3339)
}
