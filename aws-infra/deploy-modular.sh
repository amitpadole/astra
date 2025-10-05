#!/bin/bash

# aws-infra/deploy-modular.sh
# Script to deploy the modular CloudFormation stacks for Blot Parser

set -e

echo "🏗️ Deploying Modular AWS Infrastructure for Blot Parser..."

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
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "123456789012")}

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
echo "   AWS Account ID: $AWS_ACCOUNT_ID"

# Create deployment bucket
DEPLOYMENT_BUCKET="${PROJECT_NAME}-deployments-${ENVIRONMENT}-${AWS_ACCOUNT_ID}"
echo "📦 Creating deployment bucket: $DEPLOYMENT_BUCKET"

aws s3 mb "s3://$DEPLOYMENT_BUCKET" --region $REGION 2>/dev/null || echo "Bucket $DEPLOYMENT_BUCKET already exists"

# Upload child stack templates
echo "📤 Uploading child stack templates to S3..."

aws s3 cp cloudformation/s3.yaml "s3://$DEPLOYMENT_BUCKET/cloudformation/s3.yaml" --region $REGION
aws s3 cp cloudformation/dynamodb.yaml "s3://$DEPLOYMENT_BUCKET/cloudformation/dynamodb.yaml" --region $REGION
aws s3 cp cloudformation/iam.yaml "s3://$DEPLOYMENT_BUCKET/cloudformation/iam.yaml" --region $REGION
aws s3 cp cloudformation/lambda.yaml "s3://$DEPLOYMENT_BUCKET/cloudformation/lambda.yaml" --region $REGION
aws s3 cp cloudformation/monitoring.yaml "s3://$DEPLOYMENT_BUCKET/cloudformation/monitoring.yaml" --region $REGION

echo "✅ Child stack templates uploaded successfully!"

# Deploy Parent CloudFormation stack
echo "🚀 Deploying Parent CloudFormation stack..."

aws cloudformation deploy \
    --template-file cloudformation/parent.yaml \
    --stack-name $STACK_NAME \
    --parameter-overrides \
        Environment=$ENVIRONMENT \
        ProjectName=$PROJECT_NAME \
        AWSAccountId=$AWS_ACCOUNT_ID \
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

DEPLOYMENT_BUCKET_OUTPUT=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query 'Stacks[0].Outputs[?OutputKey==`DeploymentBucketName`].OutputValue' \
    --output text \
    --region $REGION)

LAMBDA_FUNCTION=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query 'Stacks[0].Outputs[?OutputKey==`LambdaFunctionName`].OutputValue' \
    --output text \
    --region $REGION)

DASHBOARD_URL=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudWatchDashboardUrl`].OutputValue' \
    --output text \
    --region $REGION)

echo "✅ Modular infrastructure deployed successfully!"
echo ""
echo "📋 Infrastructure Details:"
echo "   Input S3 Bucket: $INPUT_BUCKET"
echo "   DynamoDB Table: $DATA_TABLE"
echo "   Lambda IAM Role: $LAMBDA_ROLE"
echo "   Deployment S3 Bucket: $DEPLOYMENT_BUCKET_OUTPUT"
echo "   Lambda Function: $LAMBDA_FUNCTION"
echo "   CloudWatch Dashboard: $DASHBOARD_URL"
echo "   Region: $REGION"

# Create environment file for Lambda deployments
cat > ../blot-parser/.env << EOF
# AWS Infrastructure Configuration (Modular Deployment)
AWS_REGION=$REGION
INPUT_BUCKET=$INPUT_BUCKET
DATA_TABLE=$DATA_TABLE
LAMBDA_ROLE_ARN=$LAMBDA_ROLE
DEPLOYMENT_BUCKET=$DEPLOYMENT_BUCKET_OUTPUT
LAMBDA_FUNCTION_NAME=$LAMBDA_FUNCTION
ENVIRONMENT=$ENVIRONMENT
PROJECT_NAME=$PROJECT_NAME
LOG_LEVEL=INFO
EOF

echo ""
echo "🔗 Next steps:"
echo "1. Deploy individual Lambda functions using their deployment scripts"
echo "2. Test by uploading Excel files to: $INPUT_BUCKET"
echo "3. Check DynamoDB table: $DATA_TABLE for processed data"
echo "4. Monitor via CloudWatch Dashboard: $DASHBOARD_URL"
echo ""
echo "📝 Architecture:"
echo "   - Modular CloudFormation stacks deployed"
echo "   - Parent stack orchestrates child stacks"
echo "   - Each component has its own stack for better maintainability"
