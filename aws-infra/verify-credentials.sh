#!/bin/bash

# aws-infra/verify-credentials.sh
# Script to verify AWS credentials and GitHub Actions readiness

set -e

echo "🔐 Verifying AWS Credentials for GitHub Actions..."

# Load credentials if available
if [ -f credentials.env ]; then
    echo "📋 Loading credentials from credentials.env..."
    source credentials.env
else
    echo "⚠️  credentials.env not found. Using AWS CLI configuration."
fi

# Check AWS CLI configuration
echo "🔍 Checking AWS CLI configuration..."

if aws sts get-caller-identity > /dev/null 2>&1; then
    echo "✅ AWS CLI is configured"
    
    # Get account information
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
    REGION=$(aws configure get region || echo "us-east-1")
    
    echo "📊 AWS Account Information:"
    echo "   Account ID: $ACCOUNT_ID"
    echo "   User ARN: $USER_ARN"
    echo "   Region: $REGION"
    
    # Check required permissions
    echo "🔐 Checking required permissions..."
    
    # Test CloudFormation access
    if aws cloudformation list-stacks --max-items 1 > /dev/null 2>&1; then
        echo "✅ CloudFormation access confirmed"
    else
        echo "❌ CloudFormation access denied"
    fi
    
    # Test S3 access
    if aws s3 ls > /dev/null 2>&1; then
        echo "✅ S3 access confirmed"
    else
        echo "❌ S3 access denied"
    fi
    
    # Test DynamoDB access
    if aws dynamodb list-tables > /dev/null 2>&1; then
        echo "✅ DynamoDB access confirmed"
    else
        echo "❌ DynamoDB access denied"
    fi
    
    # Test Lambda access
    if aws lambda list-functions --max-items 1 > /dev/null 2>&1; then
        echo "✅ Lambda access confirmed"
    else
        echo "❌ Lambda access denied"
    fi
    
    # Test IAM access
    if aws iam get-user > /dev/null 2>&1; then
        echo "✅ IAM access confirmed"
    else
        echo "❌ IAM access denied"
    fi
    
    echo ""
    echo "🎯 GitHub Actions Configuration:"
    echo "   Add these secrets to your GitHub repository:"
    echo ""
    echo "   Secret Name: AWS_ACCESS_KEY_ID"
    echo "   Secret Value: [Your AWS Access Key ID]"
    echo ""
    echo "   Secret Name: AWS_SECRET_ACCESS_KEY"
    echo "   Secret Value: [Your AWS Secret Access Key]"
    echo ""
    echo "   Note: Do NOT use temporary credentials (with session tokens)"
    echo "   Use permanent IAM user credentials for GitHub Actions"
    
else
    echo "❌ AWS CLI not configured or credentials invalid"
    echo ""
    echo "🔧 Setup Instructions:"
    echo "1. Run 'aws configure' to set up credentials"
    echo "2. Or set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables"
    echo "3. Ensure credentials have required permissions for CloudFormation, S3, DynamoDB, Lambda, and IAM"
fi

echo ""
echo "📚 Next Steps:"
echo "1. Create permanent AWS credentials (IAM user)"
echo "2. Add credentials as GitHub Secrets"
echo "3. Test deployment with GitHub Actions"
echo "4. Monitor deployments in GitHub Actions tab"
