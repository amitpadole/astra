#!/bin/bash

# AWS Credentials Setup Script
# Helps configure AWS credentials for the project

set -e

echo "🔐 Setting up AWS Credentials for Blot Parser..."

# Check if credentials.env already exists
if [ -f credentials.env ]; then
    echo "⚠️  credentials.env already exists."
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled."
        exit 1
    fi
fi

# Copy template to credentials.env
cp credentials.env.template credentials.env
echo "✅ Created credentials.env from template"

# Get AWS account information
echo ""
echo "📋 AWS Account Configuration:"
echo "Please provide your AWS account details:"

# Get AWS Account ID
read -p "AWS Account ID (12 digits): " AWS_ACCOUNT_ID
if [[ ! $AWS_ACCOUNT_ID =~ ^[0-9]{12}$ ]]; then
    echo "❌ Invalid AWS Account ID. Must be 12 digits."
    exit 1
fi

# Get AWS Region
read -p "AWS Region [us-east-1]: " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}

# Get Environment
read -p "Environment [dev]: " ENVIRONMENT
ENVIRONMENT=${ENVIRONMENT:-dev}

# Get Project Name
read -p "Project Name [blot-parser]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-blot-parser}

# Get notification email
read -p "Notification Email (optional): " NOTIFICATION_EMAIL

# Update credentials.env with user input
sed -i.bak "s/AWS_ACCOUNT_ID=.*/AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID/" credentials.env
sed -i.bak "s/AWS_REGION=.*/AWS_REGION=$AWS_REGION/" credentials.env
sed -i.bak "s/ENVIRONMENT=.*/ENVIRONMENT=$ENVIRONMENT/" credentials.env
sed -i.bak "s/PROJECT_NAME=.*/PROJECT_NAME=$PROJECT_NAME/" credentials.env

if [ ! -z "$NOTIFICATION_EMAIL" ]; then
    sed -i.bak "s/NOTIFICATION_EMAIL=.*/NOTIFICATION_EMAIL=$NOTIFICATION_EMAIL/" credentials.env
fi

# Clean up backup file
rm credentials.env.bak

echo ""
echo "✅ Credentials configured successfully!"
echo ""
echo "📋 Configuration Summary:"
echo "   AWS Account ID: $AWS_ACCOUNT_ID"
echo "   AWS Region: $AWS_REGION"
echo "   Environment: $ENVIRONMENT"
echo "   Project Name: $PROJECT_NAME"
if [ ! -z "$NOTIFICATION_EMAIL" ]; then
    echo "   Notification Email: $NOTIFICATION_EMAIL"
fi

echo ""
echo "🔐 AWS Authentication:"
echo "Make sure you have AWS credentials configured:"
echo "1. AWS CLI: aws configure"
echo "2. Environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY"
echo "3. IAM roles (for EC2/ECS)"
echo "4. AWS SSO"

echo ""
echo "🧪 Test AWS Connection:"
if aws sts get-caller-identity > /dev/null 2>&1; then
    echo "✅ AWS credentials are working!"
    aws sts get-caller-identity
else
    echo "❌ AWS credentials not configured. Please run 'aws configure'"
fi

echo ""
echo "🚀 Next Steps:"
echo "1. Run ./deploy-infrastructure.sh to deploy AWS infrastructure"
echo "2. Run ../blot-parser/deploy-lambda.sh to deploy Lambda functions"
echo "3. Test by uploading Excel files to S3"
