#!/bin/bash

# Blot Parser Lambda Deployment Script
# Deploys the blot-parser Lambda function to AWS

set -e

echo "🚀 Deploying Blot Parser Lambda Function..."

# Load environment variables
if [ -f .env ]; then
    source .env
    echo "📋 Loaded environment configuration"
else
    echo "❌ .env file not found. Please run aws-infra/deploy-infrastructure.sh first."
    exit 1
fi

# Configuration
LAMBDA_FUNCTION_NAME="blot-parser-${ENVIRONMENT:-dev}"
DEPLOY_DIR="lambda-deployment"
ZIP_FILE="blot-parser-lambda.zip"

# Create deployment directory
rm -rf $DEPLOY_DIR
mkdir -p $DEPLOY_DIR

echo "📦 Creating deployment package..."

# Copy Python files
cp lambda_function.py $DEPLOY_DIR/
cp lambda_handler.py $DEPLOY_DIR/
cp blot_parser.py $DEPLOY_DIR/
cp field_mapper.py $DEPLOY_DIR/
cp excel_processor.py $DEPLOY_DIR/
cp vendor_detector.py $DEPLOY_DIR/
cp file_manager.py $DEPLOY_DIR/
cp config.py $DEPLOY_DIR/

# Copy mappings directory
cp -r mappings $DEPLOY_DIR/

# Install dependencies
echo "📥 Installing dependencies..."
pip install -r requirements-lambda.txt -t $DEPLOY_DIR/

# Create deployment package
echo "📦 Creating ZIP package..."
cd $DEPLOY_DIR
zip -r ../$ZIP_FILE .
cd ..

echo "✅ Deployment package created: $ZIP_FILE"

# Upload to S3
echo "📤 Uploading to S3..."
aws s3 cp $ZIP_FILE s3://$DEPLOYMENT_BUCKET/

# Deploy or update Lambda function
echo "🚀 Deploying Lambda function..."

# Check if function exists
if aws lambda get-function --function-name $LAMBDA_FUNCTION_NAME --region $AWS_REGION > /dev/null 2>&1; then
    echo "Updating existing Lambda function..."
    aws lambda update-function-code \
        --function-name $LAMBDA_FUNCTION_NAME \
        --s3-bucket $DEPLOYMENT_BUCKET \
        --s3-key $ZIP_FILE \
        --region $AWS_REGION
    
    # Update environment variables
    aws lambda update-function-configuration \
        --function-name $LAMBDA_FUNCTION_NAME \
        --environment Variables="{
            DYNAMODB_TABLE_NAME=$DATA_TABLE,
            S3_BUCKET=$INPUT_BUCKET,
            AWS_REGION=$AWS_REGION
        }" \
        --region $AWS_REGION
else
    echo "Creating new Lambda function..."
    aws lambda create-function \
        --function-name $LAMBDA_FUNCTION_NAME \
        --runtime python3.11 \
        --role $LAMBDA_ROLE_ARN \
        --handler lambda_function.lambda_handler \
        --code S3Bucket=$DEPLOYMENT_BUCKET,S3Key=$ZIP_FILE \
        --timeout 300 \
        --memory-size 512 \
        --environment Variables="{
            DYNAMODB_TABLE_NAME=$DATA_TABLE,
            S3_BUCKET=$INPUT_BUCKET,
            AWS_REGION=$AWS_REGION
        }" \
        --region $AWS_REGION
fi

# Add S3 trigger
echo "🔗 Configuring S3 trigger..."
aws s3api put-bucket-notification-configuration \
    --bucket $INPUT_BUCKET \
    --notification-configuration '{
        "LambdaConfigurations": [
            {
                "Id": "blot-parser-trigger",
                "LambdaFunctionArn": "'$(aws lambda get-function --function-name $LAMBDA_FUNCTION_NAME --query 'Configuration.FunctionArn' --output text --region $AWS_REGION)'",
                "Events": ["s3:ObjectCreated:*"],
                "Filter": {
                    "Key": {
                        "FilterRules": [
                            {
                                "Name": "suffix",
                                "Value": ".xlsx"
                            }
                        ]
                    }
                }
            }
        ]
    }'

# Grant S3 permission to invoke Lambda
aws lambda add-permission \
    --function-name $LAMBDA_FUNCTION_NAME \
    --statement-id s3-trigger \
    --action lambda:InvokeFunction \
    --principal s3.amazonaws.com \
    --source-arn "arn:aws:s3:::$INPUT_BUCKET" \
    --region $AWS_REGION 2>/dev/null || echo "Permission already exists"

# Clean up
rm -rf $DEPLOY_DIR
rm -f $ZIP_FILE

echo "✅ Lambda function deployed successfully!"
echo ""
echo "📋 Function Details:"
echo "   Function Name: $LAMBDA_FUNCTION_NAME"
echo "   DynamoDB Table: $DATA_TABLE"
echo "   S3 Input Bucket: $INPUT_BUCKET"
echo "   Region: $AWS_REGION"

echo ""
echo "🧪 Testing:"
echo "1. Upload an Excel file to: $INPUT_BUCKET"
echo "2. Check CloudWatch logs for processing status"
echo "3. Verify data in DynamoDB table: $DATA_TABLE"
