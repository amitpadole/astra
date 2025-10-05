#!/bin/bash

# aws-infra/verify-dev-setup.sh
# Script to verify DEV environment setup for GitHub Actions

set -e

echo "🔐 Verifying DEV Environment Setup for GitHub Actions..."

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
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
    
    echo "✅ AWS CLI configured successfully"
    echo "   Account ID: $ACCOUNT_ID"
    echo "   User ARN: $USER_ARN"
    
    # Test specific permissions
    echo ""
    echo "🧪 Testing AWS permissions..."
    
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
    echo "   Your DEV environment should have these secrets:"
    echo ""
    echo "   Secret Name: AWS_ACCESS_KEY_ID"
    echo "   Secret Value: [Your AWS Access Key ID]"
    echo ""
    echo "   Secret Name: AWS_SECRET_ACCESS_KEY"
    echo "   Secret Value: [Your AWS Secret Access Key]"
    echo ""
    echo "   Note: These should be set at the environment level, not repository level"
    echo "   DEV Environment: No reviewers required, 0-minute wait"
    
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
echo "1. Verify GitHub Secrets are set for DEV environment"
echo "2. Test deployment by pushing to 'develop' branch"
echo "3. Monitor deployment in GitHub Actions tab"
echo "4. Check AWS Console for created resources"
echo ""
echo "🔗 Useful Links:"
echo "   - GitHub Actions: https://github.com/YOUR_ORG/YOUR_REPO/actions"
echo "   - AWS Console: https://console.aws.amazon.com/"
echo "   - Environment Setup: .github/SETUP-DEV-ENVIRONMENT.md"
