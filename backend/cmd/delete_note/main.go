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
		"Access-Control-Allow-Methods": "DELETE,OPTIONS",
	}

	// Get authorization token
	authHeader := request.Headers["Authorization"]
	if authHeader == "" {
		return events.APIGatewayProxyResponse{
			StatusCode: 401,
			Headers:    headers,
			Body:       `{"success":false,"message":"Authorization required"}`,
		}, nil
	}

	// Verify token
	claims, err := auth.ParseToken(authHeader)
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 401,
			Headers:    headers,
			Body:       `{"success":false,"message":"Invalid token"}`,
		}, nil
	}

	// Get note ID from path parameters
	noteID := request.PathParameters["noteId"]
	if noteID == "" {
		return events.APIGatewayProxyResponse{
			StatusCode: 400,
			Headers:    headers,
			Body:       `{"success":false,"message":"Note ID is required"}`,
		}, nil
	}

	// Delete note
	err = db.DeleteNote(noteID, claims.UserID)
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
		Message: "Note deleted successfully",
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
