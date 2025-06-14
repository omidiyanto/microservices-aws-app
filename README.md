# MiNo - Your Simple Note Taking App

A serverless microservices application built with AWS services on LocalStack.

![MiNo Screenshot](https://via.placeholder.com/800x450.png?text=MiNo+App+Screenshot)

## Overview

MiNo (Minimal Notes) is a serverless web application that allows users to create, read, update, and delete notes. The application is built using a microservices architecture and deployed on AWS services running locally in LocalStack.

## Features

- **User Authentication**: Secure sign-up and login
- **Note Management**: Create, read, update, and delete notes
- **Responsive Design**: Works on mobile, tablet, and desktop
- **Dark Mode UI**: Modern dark-themed interface
- **Serverless Architecture**: Fully serverless implementation

## Tech Stack

### Frontend
- HTML5
- Tailwind CSS
- Vanilla JavaScript
- Font Awesome icons

### Backend
- Go (Golang) Lambda functions
- DynamoDB for data storage
- API Gateway for RESTful API
- S3 for static website hosting

### Infrastructure
- Terraform for infrastructure as code
- LocalStack for local AWS service emulation
- AWS CLI for deployment

## Architecture

This application uses the following AWS services:
- S3: Frontend static hosting
- Lambda: Backend functions (Golang)
- DynamoDB: Data storage for users and notes
- API Gateway: RESTful API endpoints
- IAM: Roles and permissions

## Structure
- `/frontend`: HTML, Tailwind CSS, JavaScript frontend
- `/backend`: Golang Lambda functions
- `/infrastructure`: Terraform configuration for AWS resources

## Setup Instructions

### Prerequisites
- LocalStack running at 192.168.0.250:4566
- Terraform
- AWS CLI configured for LocalStack
- Go 1.16+
- Bash shell

### Quick Start

```bash
# Clone repository
git clone [your-repository-url]
cd mino-app

# Make the script executable
chmod +x mino.sh

# Run the application management script
./mino.sh
```

You'll be presented with an interactive menu where you can:
- Configure AWS CLI for LocalStack
- Initialize and deploy infrastructure
- Build and deploy backend and frontend
- Clean up resources
- Run the entire process automatically

To run the entire process automatically:

```bash
./mino.sh 13
```

For detailed deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md).

## API Endpoints

| Method | Endpoint         | Description                      | Auth Required |
|--------|------------------|----------------------------------|--------------|
| POST   | /auth            | Authenticate user                | No           |
| POST   | /register        | Register new user                | No           |
| GET    | /notes           | List all notes for a user        | Yes          |
| POST   | /notes           | Create a new note                | Yes          |
| PUT    | /notes/{noteId}  | Update an existing note          | Yes          |
| DELETE | /notes/{noteId}  | Delete a note                    | Yes          |

## Development

To run the application in development mode:

1. Deploy the infrastructure and backend:
   ```bash
   ./mino.sh 8  # Deploy all components
   ```

2. Access the frontend at:
   ```
   http://192.168.0.250:4566/s3/mino-frontend/index.html
   ```

## Cleanup

To clean up resources:
```bash
# Clean S3 buckets and build artifacts
./mino.sh 11  # Clean all resources

# Destroy all infrastructure
./mino.sh 12  # Destroy all infrastructure
```

## License

MIT

## Acknowledgments

- LocalStack for providing a local AWS environment
- Tailwind CSS for the UI framework
- Go community for excellent serverless function support

## Project Structure

```
mino/
├── backend/               # Go Lambda functions
│   ├── cmd/               # Individual Lambda packages
│   │   ├── auth/          # Authentication Lambda
│   │   ├── register/      # User registration Lambda
│   │   ├── get_notes/     # Get notes Lambda
│   │   ├── create_note/   # Create note Lambda
│   │   ├── update_note/   # Update note Lambda
│   │   └── delete_note/   # Delete note Lambda
│   ├── pkg/               # Shared Go packages
│   │   ├── auth/          # Authentication utilities
│   │   ├── db/            # Database utilities
│   │   └── models/        # Data models
│   └── bin/               # Compiled Lambda binaries/zips
│
├── frontend/              # Web frontend
│   ├── index.html         # Main page with Tailwind CSS
│   ├── app.js             # Frontend JavaScript
│   ├── styles.css         # Additional CSS
│   └── error.html         # Error page
│
├── infrastructure/        # Terraform IaC
│   ├── main.tf            # Main Terraform configuration
│   ├── variables.tf       # Terraform variables
│   ├── outputs.tf         # Terraform outputs
│   └── modules/           # Terraform modules
│       ├── apigateway/    # API Gateway module
│       ├── dynamodb/      # DynamoDB module
│       ├── lambda/        # Lambda module
│       └── s3/            # S3 module
│
└── mino.sh               # Main management script
```

## Prerequisites

- LocalStack (running on 192.168.0.250:4566)
- AWS CLI
- Terraform
- Go (1.17+)

## Deployment

The application is deployed using the `mino.sh` script which provides the following operations:

```bash
./mino.sh
```

This will show an interactive menu with options for:

1. Setup LocalStack configuration
2. Initialize Terraform
3. Build backend Lambda functions
4. Deploy infrastructure
5. Update API ID in frontend
6. Deploy frontend
7. Show deployment outputs
8. Deploy all components
9. Clean frontend resources
10. Clean backend resources  
11. Clean all resources
12. Destroy all infrastructure
13. Run all steps (setup, init, deploy all)

For more detailed deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md).

## Common Deployment Issues and Solutions

### Missing Lambda ZIP Files

If you see errors like:
```
Error: reading ZIP file: open modules/lambda/../../../backend/bin/auth.zip: The system cannot find the file specified.
```

This means you need to build the backend Lambda functions first before deploying infrastructure:

```bash
./mino.sh 3   # Build backend Lambda functions
./mino.sh 4   # Deploy infrastructure
```

Or use the deploy all option which handles the correct order:

```bash
./mino.sh 8   # Deploy all components
```

### API Gateway Integration Errors

If you see:
```
Error: putting API Gateway Integration Response: NotFoundException: No integration defined for method
```

This is typically due to resources being created in the wrong order. Using the deploy all option (8) or running the full process (13) should resolve this by ensuring proper resource creation order.

## Usage

After deployment:

1. Access the frontend at: http://192.168.0.250:4566/s3/mino-frontend/index.html
2. Register a new user
3. Log in with your credentials
4. Create, view, update and delete notes

## Cleanup

To clean up resources:

```bash
./mino.sh 11  # Clean all resources
./mino.sh 12  # Destroy all infrastructure
```
