package main

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/omidiyanto/mino/pkg/auth"
	"github.com/omidiyanto/mino/pkg/db"
	"github.com/omidiyanto/mino/pkg/models"
)

// Handler is the Lambda function handler
func Handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// Set CORS headers
	headers := map[string]string{
		"Content-Type":                 "application/json",
		"Access-Control-Allow-Origin":  "*",
		"Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key",
		"Access-Control-Allow-Methods": "POST,OPTIONS",
	}

	// Parse login credentials from request body
	var credentials models.UserCredentials
	if err := json.Unmarshal([]byte(request.Body), &credentials); err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 400,
			Headers:    headers,
			Body:       fmt.Sprintf(`{"success":false,"message":"Invalid request: %s"}`, err.Error()),
		}, nil
	}

	// Get user by email
	user, err := db.GetUserByEmail(credentials.Email)
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 401,
			Headers:    headers,
			Body:       `{"success":false,"message":"Invalid email or password"}`,
		}, nil
	}

	// Verify password
	if !auth.VerifyPassword(credentials.Password, user.Password) {
		return events.APIGatewayProxyResponse{
			StatusCode: 401,
			Headers:    headers,
			Body:       `{"success":false,"message":"Invalid email or password"}`,
		}, nil
	}

	// Generate token
	token, err := auth.GenerateToken(*user)
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Headers:    headers,
			Body:       `{"success":false,"message":"Failed to generate authentication token"}`,
		}, nil
	}

	// Create response
	response := models.AuthResponse{
		Token: token,
		User:  *user,
	}

	responseJSON, err := json.Marshal(response)
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Headers:    headers,
			Body:       `{"success":false,"message":"Failed to create response"}`,
		}, nil
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers:    headers,
		Body:       string(responseJSON),
	}, nil
}

func main() {
	lambda.Start(Handler)
}
