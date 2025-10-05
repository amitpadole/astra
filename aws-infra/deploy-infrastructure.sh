#!/bin/bash

# AWS Infrastructure Deployment Script
# Deploys shared infrastructure for all Lambda functions

set -e

echo "🏗️ Deploying AWS Infrastructure for Blot Parser..."

# Configuration
STACK_NAME="blot-parser-infrastructure"
ENVIRONMENT=${1:-dev}
REGION=${2:-us-east-1}

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

echo "📋 Deployment Configuration:"
echo "   Stack Name: $STACK_NAME"
echo "   Environment: $ENVIRONMENT"
echo "   Region: $REGION"

# Deploy CloudFormation stack
echo "🚀 Deploying CloudFormation stack..."

aws cloudformation deploy \
    --template-file cloudformation.yaml \
    --stack-name $STACK_NAME \
    --parameter-overrides \
        Environment=$ENVIRONMENT \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION

# Get stack outputs
echo "📊 Getting stack outputs..."

INPUT_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query 'Stacks[0].Outputs[?OutputKey==`InputBucketName`].OutputValue' \
    --output text \
    --region $REGION)

DATA_TABLE=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query 'Stacks[0].Outputs[?OutputKey==`DataTableName`].OutputValue' \
    --output text \
    --region $REGION)

LAMBDA_ROLE=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query 'Stacks[0].Outputs[?OutputKey==`LambdaRoleArn`].OutputValue' \
    --output text \
    --region $REGION)

DEPLOYMENT_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query 'Stacks[0].Outputs[?OutputKey==`DeploymentBucketName`].OutputValue' \
    --output text \
    --region $REGION)

echo "✅ Infrastructure deployed successfully!"
echo ""
echo "📋 Infrastructure Details:"
echo "   Input S3 Bucket: $INPUT_BUCKET"
echo "   DynamoDB Table: $DATA_TABLE"
echo "   Lambda IAM Role: $LAMBDA_ROLE"
echo "   Deployment S3 Bucket: $DEPLOYMENT_BUCKET"
echo "   Region: $REGION"

# Create environment file for Lambda deployments
cat > ../blot-parser/.env << EOF
# AWS Infrastructure Configuration
AWS_REGION=$REGION
INPUT_BUCKET=$INPUT_BUCKET
DATA_TABLE=$DATA_TABLE
LAMBDA_ROLE_ARN=$LAMBDA_ROLE
DEPLOYMENT_BUCKET=$DEPLOYMENT_BUCKET
ENVIRONMENT=$ENVIRONMENT
EOF

echo ""
echo "🔗 Next steps:"
echo "1. Deploy individual Lambda functions using their deployment scripts"
echo "2. Test by uploading Excel files to: $INPUT_BUCKET"
echo "3. Check DynamoDB table: $DATA_TABLE for processed data"
