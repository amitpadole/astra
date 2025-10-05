#!/bin/bash

# AWS Infrastructure Deployment Script
# Deploys shared infrastructure for all Lambda functions

set -e

echo "🏗️ Deploying AWS Infrastructure for Blot Parser..."

# Load credentials if available
if [ -f credentials.env ]; then
    echo "📋 Loading credentials from credentials.env..."
    source credentials.env
else
    echo "⚠️  credentials.env not found. Using default values and AWS CLI configuration."
    echo "   Create credentials.env from credentials.env.template for custom configuration."
fi

# Configuration with defaults
STACK_NAME=${STACK_NAME:-"blot-parser-infrastructure"}
ENVIRONMENT=${1:-${ENVIRONMENT:-dev}}
REGION=${2:-${AWS_REGION:-us-east-1}}
PROJECT_NAME=${PROJECT_NAME:-"blot-parser"}

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    echo "   Or set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in credentials.env"
    exit 1
fi

echo "📋 Deployment Configuration:"
echo "   Stack Name: $STACK_NAME"
echo "   Environment: $ENVIRONMENT"
echo "   Region: $REGION"
echo "   Project Name: $PROJECT_NAME"

# Upload child stack templates to S3
echo "📤 Uploading child stack templates to S3..."

# Create deployment bucket if it doesn't exist
DEPLOYMENT_BUCKET="${PROJECT_NAME}-deployments-${ENVIRONMENT}-${AWS_ACCOUNT_ID:-123456789012}"
aws s3 mb "s3://$DEPLOYMENT_BUCKET" --region $REGION 2>/dev/null || echo "Bucket $DEPLOYMENT_BUCKET already exists"

# Upload child stack templates
aws s3 cp aws-infra/cloudformation/s3.yaml "s3://$DEPLOYMENT_BUCKET/cloudformation/s3.yaml" --region $REGION
aws s3 cp aws-infra/cloudformation/dynamodb.yaml "s3://$DEPLOYMENT_BUCKET/cloudformation/dynamodb.yaml" --region $REGION
aws s3 cp aws-infra/cloudformation/iam.yaml "s3://$DEPLOYMENT_BUCKET/cloudformation/iam.yaml" --region $REGION
aws s3 cp aws-infra/cloudformation/lambda.yaml "s3://$DEPLOYMENT_BUCKET/cloudformation/lambda.yaml" --region $REGION
aws s3 cp aws-infra/cloudformation/monitoring.yaml "s3://$DEPLOYMENT_BUCKET/cloudformation/monitoring.yaml" --region $REGION

echo "✅ Child stack templates uploaded successfully!"

# Deploy Parent CloudFormation stack
echo "🚀 Deploying Parent CloudFormation stack..."

aws cloudformation deploy \
    --template-file cloudformation/parent.yaml \
    --stack-name $STACK_NAME \
    --parameter-overrides \
        Environment=$ENVIRONMENT \
        ProjectName=$PROJECT_NAME \
        AWSAccountId=${AWS_ACCOUNT_ID:-123456789012} \
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
PROJECT_NAME=$PROJECT_NAME
EOF

echo ""
echo "🔗 Next steps:"
echo "1. Deploy individual Lambda functions using their deployment scripts"
echo "2. Test by uploading Excel files to: $INPUT_BUCKET"
echo "3. Check DynamoDB table: $DATA_TABLE for processed data"
echo ""
echo "📝 Credentials:"
echo "   - AWS credentials are loaded from AWS CLI configuration"
echo "   - For custom configuration, create credentials.env from credentials.env.template"