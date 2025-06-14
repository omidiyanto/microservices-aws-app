package auth

import (
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/golang-jwt/jwt"
	"github.com/omidiyanto/mino/pkg/models"
	"golang.org/x/crypto/bcrypt"
)

// JWTClaims represents the JWT claims
type JWTClaims struct {
	UserID string `json:"userId"`
	Email  string `json:"email"`
	jwt.StandardClaims
}

// GenerateToken generates a JWT token for a user
func GenerateToken(user models.User) (string, error) {
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "local-dev-jwt-secret" // Fallback for local development
	}

	// Token expires in 24 hours
	expirationTime := time.Now().Add(24 * time.Hour)

	claims := &JWTClaims{
		UserID: user.UserID,
		Email:  user.Email,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: expirationTime.Unix(),
			IssuedAt:  time.Now().Unix(),
			Issuer:    "mino-app",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(jwtSecret))

	return tokenString, err
}

// VerifyPassword verifies if a password matches the hash
func VerifyPassword(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

// ParseToken parses a JWT token and returns the claims
func ParseToken(tokenStr string) (*JWTClaims, error) {
	// Remove "Bearer " prefix if present
	tokenStr = strings.Replace(tokenStr, "Bearer ", "", 1)

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "local-dev-jwt-secret" // Fallback for local development
	}

	token, err := jwt.ParseWithClaims(tokenStr, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(jwtSecret), nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*JWTClaims); ok && token.Valid {
		return claims, nil
	}

	return nil, fmt.Errorf("invalid token")
}
