package db

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	"github.com/google/uuid"
	"github.com/omidiyanto/mino/pkg/models"
	"golang.org/x/crypto/bcrypt"
)

// DynamoDB client
var dynamoClient *dynamodb.Client

func init() {
	// Configure AWS SDK for LocalStack
	customResolver := aws.EndpointResolverWithOptionsFunc(func(service, region string, options ...interface{}) (aws.Endpoint, error) {
		return aws.Endpoint{
			URL: "http://192.168.0.250:4566",
		}, nil
	})

	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("us-east-1"),
		config.WithEndpointResolverWithOptions(customResolver),
		config.WithCredentialsProvider(aws.CredentialsProviderFunc(func(ctx context.Context) (aws.Credentials, error) {
			return aws.Credentials{
				AccessKeyID:     "test",
				SecretAccessKey: "test",
			}, nil
		})),
	)
	if err != nil {
		log.Fatalf("Unable to load SDK config: %v", err)
	}

	dynamoClient = dynamodb.NewFromConfig(cfg)
}

// GetUserByEmail retrieves a user by their email
func GetUserByEmail(email string) (*models.User, error) {
	usersTable := os.Getenv("USERS_TABLE")

	params := &dynamodb.QueryInput{
		TableName:              aws.String(usersTable),
		IndexName:              aws.String("EmailIndex"),
		KeyConditionExpression: aws.String("email = :email"),
		ExpressionAttributeValues: map[string]types.AttributeValue{
			":email": &types.AttributeValueMemberS{Value: email},
		},
		Limit: aws.Int32(1),
	}

	result, err := dynamoClient.Query(context.TODO(), params)
	if err != nil {
		return nil, err
	}

	if len(result.Items) == 0 {
		return nil, fmt.Errorf("user not found")
	}

	var user models.User
	err = attributevalue.UnmarshalMap(result.Items[0], &user)
	if err != nil {
		return nil, err
	}

	return &user, nil
}

// GetUserByID retrieves a user by their ID
func GetUserByID(userID string) (*models.User, error) {
	usersTable := os.Getenv("USERS_TABLE")

	params := &dynamodb.GetItemInput{
		TableName: aws.String(usersTable),
		Key: map[string]types.AttributeValue{
			"userId": &types.AttributeValueMemberS{Value: userID},
		},
	}

	result, err := dynamoClient.GetItem(context.TODO(), params)
	if err != nil {
		return nil, err
	}

	if result.Item == nil {
		return nil, fmt.Errorf("user not found")
	}

	var user models.User
	err = attributevalue.UnmarshalMap(result.Item, &user)
	if err != nil {
		return nil, err
	}

	return &user, nil
}

// CreateUser creates a new user in DynamoDB
func CreateUser(userReg models.UserRegistration) (*models.User, error) {
	usersTable := os.Getenv("USERS_TABLE")

	// Check if user already exists
	_, err := GetUserByEmail(userReg.Email)
	if err == nil {
		return nil, fmt.Errorf("user with this email already exists")
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(userReg.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	// Create user
	user := models.User{
		UserID:    uuid.New().String(),
		Email:     userReg.Email,
		Password:  string(hashedPassword),
		CreatedAt: models.GetTimeNow(),
	}

	item, err := attributevalue.MarshalMap(user)
	if err != nil {
		return nil, err
	}

	_, err = dynamoClient.PutItem(context.TODO(), &dynamodb.PutItemInput{
		TableName: aws.String(usersTable),
		Item:      item,
	})

	if err != nil {
		return nil, err
	}

	return &user, nil
}

// GetNotesByUserID gets all notes for a user
func GetNotesByUserID(userID string) ([]models.Note, error) {
	notesTable := os.Getenv("NOTES_TABLE")

	params := &dynamodb.QueryInput{
		TableName:              aws.String(notesTable),
		IndexName:              aws.String("UserIdIndex"),
		KeyConditionExpression: aws.String("userId = :userId"),
		ExpressionAttributeValues: map[string]types.AttributeValue{
			":userId": &types.AttributeValueMemberS{Value: userID},
		},
		ScanIndexForward: aws.Bool(false), // Descending order by sort key (createdAt)
	}

	result, err := dynamoClient.Query(context.TODO(), params)
	if err != nil {
		return nil, err
	}

	var notes []models.Note
	err = attributevalue.UnmarshalListOfMaps(result.Items, &notes)
	if err != nil {
		return nil, err
	}

	return notes, nil
}

// GetNoteByID gets a note by its ID and userID
func GetNoteByID(noteID string, userID string) (*models.Note, error) {
	notesTable := os.Getenv("NOTES_TABLE")

	params := &dynamodb.GetItemInput{
		TableName: aws.String(notesTable),
		Key: map[string]types.AttributeValue{
			"noteId": &types.AttributeValueMemberS{Value: noteID},
			"userId": &types.AttributeValueMemberS{Value: userID},
		},
	}

	result, err := dynamoClient.GetItem(context.TODO(), params)
	if err != nil {
		return nil, err
	}

	if result.Item == nil {
		return nil, fmt.Errorf("note not found")
	}

	var note models.Note
	err = attributevalue.UnmarshalMap(result.Item, &note)
	if err != nil {
		return nil, err
	}

	return &note, nil
}

// CreateNote creates a new note
func CreateNote(note models.Note) error {
	notesTable := os.Getenv("NOTES_TABLE")

	note.NoteID = uuid.New().String()
	note.CreatedAt = models.GetTimeNow()
	note.UpdatedAt = note.CreatedAt

	item, err := attributevalue.MarshalMap(note)
	if err != nil {
		return err
	}

	_, err = dynamoClient.PutItem(context.TODO(), &dynamodb.PutItemInput{
		TableName: aws.String(notesTable),
		Item:      item,
	})

	return err
}

// UpdateNote updates an existing note
func UpdateNote(note models.Note) error {
	notesTable := os.Getenv("NOTES_TABLE")

	// Check if note exists
	existingNote, err := GetNoteByID(note.NoteID, note.UserID)
	if err != nil {
		return err
	}

	// Update note fields
	note.CreatedAt = existingNote.CreatedAt
	note.UpdatedAt = models.GetTimeNow()

	item, err := attributevalue.MarshalMap(note)
	if err != nil {
		return err
	}

	_, err = dynamoClient.PutItem(context.TODO(), &dynamodb.PutItemInput{
		TableName: aws.String(notesTable),
		Item:      item,
	})

	return err
}

// DeleteNote deletes a note
func DeleteNote(noteID string, userID string) error {
	notesTable := os.Getenv("NOTES_TABLE")

	_, err := dynamoClient.DeleteItem(context.TODO(), &dynamodb.DeleteItemInput{
		TableName: aws.String(notesTable),
		Key: map[string]types.AttributeValue{
			"noteId": &types.AttributeValueMemberS{Value: noteID},
			"userId": &types.AttributeValueMemberS{Value: userID},
		},
	})

	return err
}
