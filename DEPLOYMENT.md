# MiNo - Deployment Guide

This document provides instructions for deploying the MiNo application to LocalStack.

## Prerequisites

1. **LocalStack** running at 192.168.0.250:4566
2. **AWS CLI** installed and configured for LocalStack
3. **Terraform** installed (v0.14+)
4. **Go** installed (v1.16+)
5. **Bash shell**

## Setup

1. Clone the repository:

```bash
git clone [your-repository-url]
cd mino-app
```

2. Make the script executable:

```bash
chmod +x mino.sh
```

3. Run the application management script:

```bash
./mino.sh
```

## Using the Management Script

The management script provides an interactive menu with the following options:

### Initial Setup

1) **Configure AWS CLI for LocalStack**
   - Sets up AWS CLI credentials for LocalStack

2) **Initialize Terraform**
   - Initializes Terraform in the infrastructure directory

### Deployment

3) **Deploy infrastructure**
   - Deploys all AWS infrastructure with Terraform

4) **Build and deploy backend**
   - Compiles and packages Go Lambda functions

5) **Update API ID in frontend**
   - Retrieves API Gateway ID and updates frontend configuration

6) **Deploy frontend**
   - Uploads frontend files to S3

7) **Show deployment outputs**
   - Displays Terraform outputs

8) **Deploy all components**
   - Runs steps 3-7 in sequence

### Cleanup

9) **Clean frontend resources**
   - Removes objects from S3 bucket

10) **Clean backend resources**
    - Removes backend build artifacts

11) **Clean all resources**
    - Runs steps 9-10

12) **Destroy all infrastructure**
    - Destroys all AWS resources managed by Terraform

### Full Process

13) **Run all steps**
    - Sets up LocalStack, initializes Terraform, and deploys everything

## Manual Deployment

If you prefer to run specific steps manually:

1. **Configure AWS CLI for LocalStack**:
   ```bash
   ./mino.sh 1
   ```

2. **Initialize Terraform**:
   ```bash
   ./mino.sh 2
   ```
   
3. **Deploy Infrastructure**:
   ```bash
   ./mino.sh 3
   ```
   
4. **Build and Deploy Backend**:
   ```bash
   ./mino.sh 4
   ```
   
5. **Update API ID in Frontend**:
   ```bash
   ./mino.sh 5
   ```
   
6. **Deploy Frontend**:
   ```bash
   ./mino.sh 6
   ```

## Automated Deployment

For fully automated deployment:

```bash
./mino.sh 13
```

This runs all steps in sequence.

## Testing the Application

1. After deployment completes, check the deployment outputs:
   ```bash
   ./mino.sh 7
   ```

2. Access the frontend at:
   ```
   http://192.168.0.250:4566/s3/mino-frontend/index.html
   ```

## Cleanup

To remove all resources:

```bash
# Clean S3 buckets and build artifacts
./mino.sh 11

# Destroy all infrastructure
./mino.sh 12
```

## Troubleshooting

### Common Issues

1. **API Gateway Connectivity Issues**
   - Ensure LocalStack is running and accessible at 192.168.0.250:4566
   - Verify that the API ID in app.js matches the deployed API

2. **Lambda Function Errors**
   - Check Lambda logs: 
     ```
     aws --endpoint-url=http://192.168.0.250:4566 logs describe-log-streams --log-group-name /aws/lambda/mino_auth
     ```

3. **S3 Access Issues**
   - Verify bucket exists:
     ```
     aws --endpoint-url=http://192.168.0.250:4566 s3 ls
     ```
   - Check bucket contents:
     ```
     aws --endpoint-url=http://192.168.0.250:4566 s3 ls s3://mino-frontend
     ```

## Architecture Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│             │     │             │     │             │
│  S3 Bucket  │◄────┤ API Gateway │◄────┤   Lambda    │
│ (Frontend)  │     │  (Routes)   │     │ (Backend)   │
│             │     │             │     │             │
└─────────────┘     └─────────────┘     └─────┬───────┘
                                              │
                                              │
                                        ┌─────▼───────┐
                                        │             │
                                        │  DynamoDB   │
                                        │ (Storage)   │
                                        │             │
                                        └─────────────┘
```

The application uses a serverless architecture with:
- S3 for static website hosting
- API Gateway for RESTful API endpoints
- Lambda (Go) for backend functions
- DynamoDB for data storage 