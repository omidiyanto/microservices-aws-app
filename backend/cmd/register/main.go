package main

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
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

	// Parse registration data from request body
	var registration models.UserRegistration
	if err := json.Unmarshal([]byte(request.Body), &registration); err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 400,
			Headers:    headers,
			Body:       fmt.Sprintf(`{"success":false,"message":"Invalid request: %s"}`, err.Error()),
		}, nil
	}

	// Validate registration data
	if registration.Email == "" || registration.Password == "" {
		return events.APIGatewayProxyResponse{
			StatusCode: 400,
			Headers:    headers,
			Body:       `{"success":false,"message":"Email and password are required"}`,
		}, nil
	}

	// Create user
	user, err := db.CreateUser(registration)
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 400,
			Headers:    headers,
			Body:       fmt.Sprintf(`{"success":false,"message":"%s"}`, err.Error()),
		}, nil
	}

	// Create response
	response := models.APIResponse{
		Success: true,
		Message: "User registered successfully",
		Data:    user,
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
		StatusCode: 201, // Created
		Headers:    headers,
		Body:       string(responseJSON),
	}, nil
}

func main() {
	lambda.Start(Handler)
}
