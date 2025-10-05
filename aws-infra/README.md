# AWS Infrastructure for Blot Parser

This directory contains the shared AWS infrastructure components for the Blot Parser project.

## Architecture

### Modular CloudFormation Design

The infrastructure uses a **parent-child stack pattern** for better modularity and maintainability:

```
Parent Stack (parent.yaml)
├── S3 Stack (s3.yaml) - Input and deployment buckets
├── DynamoDB Stack (dynamodb.yaml) - Data storage tables  
├── IAM Stack (iam.yaml) - Roles and policies
├── Lambda Stack (lambda.yaml) - Functions and triggers
└── Monitoring Stack (monitoring.yaml) - Dashboards and alarms
```

### Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Infrastructure                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │S3 Input     │  │Lambda       │  │DynamoDB     │        │
│  │Bucket       │  │Functions    │  │Table        │        │
│  │             │  │             │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│  ┌─────────────┐  ┌─────────────┐                        │
│  │S3 Deployment│  │IAM Roles    │                        │
│  │Bucket       │  │& Policies   │                        │
│  └─────────────┘  └─────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

## Components

### 🏗️ Infrastructure Components

| Component | Purpose | Type |
|-----------|---------|------|
| **S3 Input Bucket** | Stores Excel files for processing | S3 Bucket |
| **DynamoDB Table** | Stores processed JSON data | DynamoDB Table |
| **Lambda IAM Role** | Permissions for Lambda functions | IAM Role |
| **S3 Deployment Bucket** | Stores Lambda deployment packages | S3 Bucket |

### 📊 Data Flow

1. **Excel files** uploaded to S3 Input Bucket
2. **S3 triggers** Lambda function automatically
3. **Lambda processes** Excel file and maps fields
4. **Processed data** saved to DynamoDB table
5. **Results** available for querying and analysis

## Deployment

### Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Python 3.11+** installed
3. **pip** for dependency management

### Step 0: Configure Credentials

```bash
# Set up AWS credentials and configuration
./setup-credentials.sh

# This will create credentials.env with your AWS account details
# The file is automatically added to .gitignore for security
```

### Step 1: Deploy Infrastructure

You have two deployment options:

#### Option A: Modular Deployment (Recommended)

```bash
# Deploy modular infrastructure with parent-child stacks
./deploy-modular.sh [environment] [region]

# Examples:
./deploy-modular.sh dev us-east-1
./deploy-modular.sh prod us-west-2
```

#### Option B: Monolithic Deployment (Legacy)

```bash
# Deploy single CloudFormation stack
./deploy-infrastructure.sh [environment] [region]

# Examples:
./deploy-infrastructure.sh dev us-east-1
./deploy-infrastructure.sh prod us-west-2
```

**Benefits of Modular Deployment:**
- Better separation of concerns
- Easier to maintain and update
- Independent stack management
- Better for team collaboration

### Step 2: Deploy Lambda Functions

Each Lambda function is responsible for its own deployment:

```bash
# Deploy blot-parser Lambda
cd ../blot-parser
./deploy-lambda.sh
```

## Configuration

### Credentials Management

The project uses a secure credentials management system:

#### **credentials.env** (Not committed to git)
```bash
# AWS Account Configuration
AWS_ACCOUNT_ID=123456789012
AWS_REGION=us-east-1
ENVIRONMENT=dev

# Project Configuration
PROJECT_NAME=blot-parser
STACK_NAME=blot-parser-infrastructure

# Optional: AWS Access Keys (if not using AWS CLI profiles)
# AWS_ACCESS_KEY_ID=your_access_key_here
# AWS_SECRET_ACCESS_KEY=your_secret_key_here
```

#### **credentials.env.template** (Committed to git)
- Template file with placeholder values
- Safe to commit to version control
- Users copy this to `credentials.env` and fill in real values

### Environment Variables

The infrastructure deployment creates a `.env` file in each Lambda directory:

```bash
# AWS Infrastructure Configuration (auto-generated)
AWS_REGION=us-east-1
INPUT_BUCKET=blot-parser-input-dev-123456789
DATA_TABLE=blot-parser-data-dev
LAMBDA_ROLE_ARN=arn:aws:iam::123456789:role/blot-parser-lambda-role-dev
DEPLOYMENT_BUCKET=blot-parser-deployments-dev-123456789
ENVIRONMENT=dev
```

### IAM Permissions

The Lambda execution role includes:

- **S3 Access**: Read from input bucket
- **DynamoDB Access**: Write to data table
- **CloudWatch Logs**: Write logs
- **Basic Lambda Execution**: Standard Lambda permissions

## Monitoring

### CloudWatch Logs

- **Log Group**: `/aws/lambda/blot-parser-{environment}`
- **Retention**: 14 days (configurable)
- **Log Level**: INFO and above

### DynamoDB Metrics

- **Read/Write Capacity**: Pay-per-request mode
- **Monitoring**: CloudWatch metrics available
- **Alarms**: Can be configured for error rates

## Cost Optimization

### S3 Storage Classes

- **Standard**: Active processing files
- **IA**: Archived files (after 30 days)
- **Glacier**: Long-term archival (after 90 days)

### DynamoDB Optimization

- **On-Demand Billing**: Pay per request
- **TTL**: Automatic cleanup of old records
- **Indexes**: Optimized for common queries

## Security

### Encryption

- **S3**: Server-side encryption enabled
- **DynamoDB**: Encryption at rest enabled
- **Lambda**: Environment variables encrypted

### Access Control

- **IAM Roles**: Least privilege principle
- **S3 Bucket Policies**: Restricted access
- **VPC**: Can be configured for private access

## Troubleshooting

### Common Issues

1. **Lambda Timeout**: Increase timeout in function configuration
2. **Memory Issues**: Increase memory allocation
3. **Permission Errors**: Check IAM role permissions
4. **S3 Trigger Not Working**: Verify bucket notification configuration

### Debugging

```bash
# Check Lambda logs
aws logs tail /aws/lambda/blot-parser-dev --follow

# Test Lambda function
aws lambda invoke --function-name blot-parser-dev response.json

# Check DynamoDB items
aws dynamodb scan --table-name blot-parser-data-dev
```

## Cleanup

To remove all infrastructure:

```bash
# Delete CloudFormation stack
aws cloudformation delete-stack --stack-name blot-parser-infrastructure

# Empty S3 buckets first
aws s3 rm s3://blot-parser-input-dev-123456789 --recursive
aws s3 rm s3://blot-parser-deployments-dev-123456789 --recursive
```
