#!/bin/bash

# MiNo - Serverless Microservices App Management Script
# ====================================================

# Colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Success function
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Error function
error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Warning function
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Setup LocalStack configuration
setup_localstack() {
    log "Configuring AWS CLI for LocalStack at 192.168.0.250:4566..."
    
    aws configure set aws_access_key_id test
    aws configure set aws_secret_access_key test
    aws configure set region us-east-1
    aws configure set output json
    
    success "AWS CLI configured for LocalStack."
}

# Initialize Terraform
init_terraform() {
    log "Initializing MiNo application..."
    log "Setting up Terraform..."
    
    cd infrastructure || { error "Infrastructure directory not found!"; return 1; }
    terraform init
    
    cd ..
    success "Terraform initialization completed."
}

# Update API ID in frontend
update_api_id() {
    log "Updating API ID in frontend/app.js..."
    
    # Check if LocalStack is running
    log "Checking if LocalStack is running at 192.168.0.250:4566..."
    if ! curl -s http://192.168.0.250:4566/health | grep -q "running"; then
        error "LocalStack doesn't seem to be running. Please start LocalStack first."
        return 1
    fi
    
    # Get the API ID
    log "Retrieving API ID from LocalStack..."
    API_ID=$(aws --endpoint-url=http://192.168.0.250:4566 apigateway get-rest-apis --query "items[?name=='MiNoAPI'].id" --output text)
    
    if [ -z "$API_ID" ]; then
        error "Could not find MiNoAPI. Have you deployed the infrastructure yet?"
        return 1
    fi
    
    success "Found API ID: $API_ID"
    
    # Update app.js
    log "Updating frontend/app.js with the API ID..."
    sed -i "s|{API_ID}|$API_ID|g" frontend/app.js
    
    success "Updated frontend/app.js with API ID: $API_ID"
}

# Build backend functions
build_backend() {
    log "Building backend Lambda functions..."
    
    cd backend || { error "Backend directory not found!"; return 1; }
    
    log "Building Lambda functions..."
    mkdir -p bin
    
    MODULES="auth register get_notes create_note update_note delete_note"
    for module in $MODULES; do
        log "Building $module..."
        
        # Move to module directory, compile, zip, then cleanup
        if cd cmd/$module; then
            GOOS=linux GOARCH=amd64 go build -o ../../bin/$module main.go
            cd ../../bin || { error "Failed to navigate to bin directory"; return 1; }
            zip -q $module.zip $module && rm $module
            cd .. || { error "Failed to navigate up from bin directory"; return 1; }
        else
            error "Failed to navigate to module directory: cmd/$module"
            return 1
        fi
    done
    
    cd ..
    success "Backend Lambda build completed."
}

# Deploy infrastructure
deploy_infrastructure() {
    log "Deploying infrastructure with Terraform..."
    
    cd infrastructure || { error "Infrastructure directory not found!"; return 1; }
    terraform apply -auto-approve
    
    cd ..
    success "Infrastructure deployment completed."
}

# Deploy frontend to S3
deploy_frontend() {
    log "Deploying frontend files to S3..."
    
    cd frontend || { error "Frontend directory not found!"; return 1; }
    
    # Check if bucket exists, if not, the infrastructure might not be deployed
    if ! aws --endpoint-url=http://192.168.0.250:4566 s3 ls s3://mino-frontend/ &>/dev/null; then
        warning "Bucket mino-frontend might not exist. Make sure infrastructure is deployed."
    fi
    
    # Deploy frontend files
    aws --endpoint-url=http://192.168.0.250:4566 s3 cp index.html s3://mino-frontend/
    aws --endpoint-url=http://192.168.0.250:4566 s3 cp app.js s3://mino-frontend/
    aws --endpoint-url=http://192.168.0.250:4566 s3 cp styles.css s3://mino-frontend/
    aws --endpoint-url=http://192.168.0.250:4566 s3 cp error.html s3://mino-frontend/
    
    cd ..
    success "Frontend deployment completed."
}

# Show deployment output
show_outputs() {
    log "Displaying deployment outputs..."
    
    cd infrastructure || { error "Infrastructure directory not found!"; return 1; }
    terraform output
    
    cd ..
    success "Deployment information displayed."
}

# Deploy all components
deploy_all() {
    log "Starting full deployment process..."
    
    # Build the backend first so Lambda ZIP files are available
    build_backend || { error "Backend build failed!"; return 1; }
    
    # Deploy infrastructure only after backend is built
    deploy_infrastructure || { error "Infrastructure deployment failed!"; return 1; }
    
    # Update API ID and deploy frontend
    update_api_id || { error "API ID update failed!"; return 1; }
    deploy_frontend || { error "Frontend deployment failed!"; return 1; }
    
    show_outputs
    
    success "Full deployment completed successfully!"
}

# Clean frontend
clean_frontend() {
    log "Cleaning S3 bucket..."
    
    aws --endpoint-url=http://192.168.0.250:4566 s3 rm s3://mino-frontend --recursive
    
    success "S3 bucket cleaned."
}

# Clean backend
clean_backend() {
    log "Cleaning backend build artifacts..."
    
    cd backend || { error "Backend directory not found!"; return 1; }
    rm -rf bin
    
    cd ..
    success "Backend build artifacts cleaned."
}

# Clean all resources
clean_all() {
    log "Cleaning all application resources..."
    
    clean_frontend || warning "Frontend cleaning encountered issues."
    clean_backend || warning "Backend cleaning encountered issues."
    
    success "All application resources cleaned."
}

# Destroy all infrastructure
destroy_all() {
    log "Destroying all infrastructure..."
    
    cd infrastructure || { error "Infrastructure directory not found!"; return 1; }
    terraform destroy -auto-approve
    
    cd ..
    success "All infrastructure destroyed successfully."
}

# Run all steps in sequence
run_all() {
    setup_localstack || { error "LocalStack setup failed!"; return 1; }
    init_terraform || { error "Terraform initialization failed!"; return 1; }
    
    # Build and deploy
    build_backend || { error "Backend build failed!"; return 1; }
    deploy_infrastructure || { error "Infrastructure deployment failed!"; return 1; }
    update_api_id || { error "API ID update failed!"; return 1; }
    deploy_frontend || { error "Frontend deployment failed!"; return 1; }
    
    success "All operations completed successfully!"
    log "You can now access the application at: http://192.168.0.250:4566/s3/mino-frontend/index.html"
}

# Show menu
show_menu() {
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${BLUE}   MiNo - Serverless Microservices Application   ${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo ""
    echo "Please select an option:"
    echo ""
    echo "Initial Setup:"
    echo "  1) Configure AWS CLI for LocalStack"
    echo "  2) Initialize Terraform"
    echo ""
    echo "Deployment:"
    echo "  3) Build backend Lambda functions"
    echo "  4) Deploy infrastructure"
    echo "  5) Update API ID in frontend"
    echo "  6) Deploy frontend"
    echo "  7) Show deployment outputs"
    echo "  8) Deploy all components"
    echo ""
    echo "Cleanup:"
    echo "  9) Clean frontend resources"
    echo "  10) Clean backend resources"
    echo "  11) Clean all resources"
    echo "  12) Destroy all infrastructure"
    echo ""
    echo "Full Process:"
    echo "  13) Run all steps (setup, init, deploy all)"
    echo ""
    echo "  0) Exit"
    echo ""
    echo -n "Enter your choice [0-13]: "
}

# Main function
main() {
    # Check if argument provided
    if [ $# -eq 1 ]; then
        option=$1
    else
        show_menu
        read -r option
    fi
    
    case $option in
        1) setup_localstack ;;
        2) init_terraform ;;
        3) build_backend ;;
        4) deploy_infrastructure ;;
        5) update_api_id ;;
        6) deploy_frontend ;;
        7) show_outputs ;;
        8) deploy_all ;;
        9) clean_frontend ;;
        10) clean_backend ;;
        11) clean_all ;;
        12) destroy_all ;;
        13) run_all ;;
        0) echo "Exiting..."; exit 0 ;;
        *) error "Invalid option"; return 1 ;;
    esac
    
    # Return to menu if no arguments were provided
    if [ $# -eq 0 ]; then
        echo
        echo -n "Press Enter to continue..."
        read -r
        clear
        main
    fi
}

# Run the main function with any provided arguments
main "$@" 