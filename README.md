# MiNo - Your Simple Note Taking App

<div align="center">

[![LocalStack](https://img.shields.io/badge/LocalStack-Ready-brightgreen.svg)](https://localstack.cloud)
[![Terraform](https://img.shields.io/badge/Terraform-1.0%2B-623CE4.svg)](https://www.terraform.io/)
[![Go](https://img.shields.io/badge/Go-1.17%2B-00ADD8.svg)](https://go.dev/)

</div>

A zero-cost DevOps showcase demonstrating Infrastructure as Code (IaC) principles using AWS microservices on LocalStack.

![MiNo Screenshot](https://via.placeholder.com/800x450.png?text=MiNo+App+Screenshot)

## 🎯 Project Goals

MiNo demonstrates modern DevOps practices and Infrastructure as Code (IaC) principles by deploying a microservices application on a local AWS-compatible environment. This project serves as:

- **Zero-Cost AWS Development**: Complete AWS-compatible environment without cloud costs
- **IaC Showcase**: Terraform-based infrastructure provisioning and management
- **DevOps Pipeline Example**: Automated build, deploy, and testing workflows
- **Microservices Architecture**: Practical implementation of serverless microservices

## 🛠️ Tech Stack

### Frontend
- 🌐 HTML5
- 🎨 Tailwind CSS
- 📜 Vanilla JavaScript
- 🔍 Font Awesome icons

### Backend
- 🚀 Go (Golang) Lambda functions
- 🗄️ DynamoDB for data storage
- 🔌 API Gateway for RESTful API
- 🪣 S3 for static website hosting

### Infrastructure
- 📦 Terraform for infrastructure as code
- 🏠 LocalStack for local AWS service emulation
- 🧰 AWS CLI for deployment

## 🏗️ Architecture

This application uses the following AWS services:
- **S3**: Frontend static hosting
- **Lambda**: Backend functions (Golang)
- **DynamoDB**: Data storage for users and notes
- **API Gateway**: RESTful API endpoints
- **IAM**: Roles and permissions

## 📂 Structure
- `/frontend`: HTML, Tailwind CSS, JavaScript frontend
- `/backend`: Golang Lambda functions
- `/infrastructure`: Terraform configuration for AWS resources

## 🚀 Setup Instructions

### Prerequisites
- LocalStack running at 192.168.0.250:4566
- Terraform
- AWS CLI configured for LocalStack
- Go 1.16+
- Bash shell

### Quick Start

```bash
# Clone repository
git clone https://github.com/omidiyanto/microservices-aws-app.git
cd microservices-aws-app

# Make the script executable
chmod +x mino.sh

# Check dependencies and LocalStack status
./mino.sh 0

# Run the application management script
./mino.sh
```

You'll be presented with an interactive menu where you can:
- Configure AWS CLI for LocalStack
- Initialize and deploy infrastructure
- Build and deploy backend and frontend
- Clean up resources
- Run the entire process automatically

## 🔌 API Endpoints

| Method | Endpoint         | Description                      | Auth Required |
|--------|------------------|----------------------------------|--------------|
| POST   | /auth            | Authenticate user                | No           |
| POST   | /register        | Register new user                | No           |
| GET    | /notes           | List all notes for a user        | Yes          |
| POST   | /notes           | Create a new note                | Yes          |
| PUT    | /notes/{noteId}  | Update an existing note          | Yes          |
| DELETE | /notes/{noteId}  | Delete a note                    | Yes          |

## 💻 Deployment

To run the application in development mode:

1. To run the entire process automatically:
   ```bash
   ./mino.sh 13
   ```

2. Access the frontend at:
   ```
   http://192.168.0.250:4566/mino-frontend/index.html
   ```

## 🧹 Cleanup

To clean up resources:
```bash
# Clean S3 buckets and build artifacts
./mino.sh 11  # Clean all resources

# Destroy all infrastructure
./mino.sh 12  # Destroy all infrastructure
```

## 📁 Project Structure

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

## 📊 DevOps Benefits Demonstrated

- **Cost Efficiency**: Develop and test on LocalStack without AWS charges
- **Infrastructure as Code**: All resources defined and versioned in Terraform
- **Reproducible Environments**: Consistent setup across development machines
- **Automation**: One-command deployment and cleanup processes
- **Microservices Architecture**: Independently deployable services