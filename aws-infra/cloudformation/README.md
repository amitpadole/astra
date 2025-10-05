# CloudFormation Templates - Modular Architecture

This directory contains the modular CloudFormation templates for the Blot Parser infrastructure.

## Architecture Overview

The infrastructure is organized using a **parent-child stack pattern** for better modularity, maintainability, and reusability:

```
Parent Stack (parent.yaml)
├── S3 Stack (s3.yaml)
├── DynamoDB Stack (dynamodb.yaml)
├── IAM Stack (iam.yaml)
├── Lambda Stack (lambda.yaml)
└── Monitoring Stack (monitoring.yaml)
```

## Stack Descriptions

### 1. Parent Stack (`parent.yaml`)
- **Purpose**: Orchestrates all child stacks
- **Responsibilities**: 
  - Parameter passing between stacks
  - Output aggregation
  - Cross-stack references
- **Dependencies**: All child stacks

### 2. S3 Stack (`s3.yaml`)
- **Purpose**: S3 buckets for input files and deployments
- **Resources**:
  - Input bucket for Excel files
  - Deployment bucket for Lambda packages
  - Bucket policies and encryption
- **Features**:
  - Versioning enabled
  - Server-side encryption
  - Lifecycle policies
  - Public access blocked

### 3. DynamoDB Stack (`dynamodb.yaml`)
- **Purpose**: Data storage for processed records
- **Resources**:
  - Main data table with GSI indexes
  - Status tracking table
  - Point-in-time recovery
- **Features**:
  - Pay-per-request billing
  - Global Secondary Indexes
  - TTL support
  - Encryption at rest

### 4. IAM Stack (`iam.yaml`)
- **Purpose**: IAM roles and policies
- **Resources**:
  - Lambda execution role
  - CloudFormation deployment role
  - S3 notification policies
- **Features**:
  - Least privilege access
  - Resource-specific permissions
  - Cross-service access

### 5. Lambda Stack (`lambda.yaml`)
- **Purpose**: Lambda functions and triggers
- **Resources**:
  - Main processing Lambda
  - Test Lambda function
  - S3 event triggers
  - CloudWatch log groups
- **Features**:
  - Environment variables
  - Function aliases
  - S3 event integration

### 6. Monitoring Stack (`monitoring.yaml`)
- **Purpose**: Monitoring and alerting
- **Resources**:
  - CloudWatch dashboard
  - CloudWatch alarms
  - SNS notification topic
- **Features**:
  - Custom metrics
  - Error rate monitoring
  - Performance tracking

## Deployment Process

### Prerequisites
1. AWS CLI configured
2. S3 bucket for storing child stack templates
3. Appropriate IAM permissions

### Deployment Steps

1. **Upload Child Templates**:
   ```bash
   # Templates are automatically uploaded to S3 during deployment
   aws s3 cp cloudformation/s3.yaml s3://deployment-bucket/cloudformation/s3.yaml
   ```

2. **Deploy Parent Stack**:
   ```bash
   aws cloudformation deploy \
     --template-file cloudformation/parent.yaml \
     --stack-name blot-parser-infrastructure \
     --capabilities CAPABILITY_NAMED_IAM
   ```

3. **Verify Deployment**:
   ```bash
   aws cloudformation describe-stacks --stack-name blot-parser-infrastructure
   ```

## Benefits of Modular Architecture

### 1. **Separation of Concerns**
- Each stack has a single responsibility
- Easier to understand and maintain
- Independent updates possible

### 2. **Reusability**
- Child stacks can be reused across environments
- Template sharing between projects
- Standardized resource patterns

### 3. **Deployment Flexibility**
- Deploy only what's needed
- Faster updates for specific components
- Reduced blast radius

### 4. **Team Collaboration**
- Different teams can own different stacks
- Parallel development possible
- Clear ownership boundaries

### 5. **Testing and Validation**
- Individual stack testing
- Easier rollback scenarios
- Better change tracking

## Stack Dependencies

```
Parent Stack
├── S3 Stack (no dependencies)
├── DynamoDB Stack (no dependencies)
├── IAM Stack (depends on: S3, DynamoDB)
├── Lambda Stack (depends on: S3, DynamoDB, IAM)
└── Monitoring Stack (depends on: Lambda, DynamoDB)
```

## Environment-Specific Configuration

Each stack supports environment-specific parameters:

- **Environment**: `dev`, `staging`, `prod`
- **Project Name**: Used for resource naming
- **AWS Account ID**: For unique resource names

## Outputs and Exports

The parent stack aggregates outputs from all child stacks:

- **S3 Buckets**: Input and deployment bucket names/ARNs
- **DynamoDB Tables**: Table names and ARNs
- **IAM Roles**: Lambda execution role ARN
- **Lambda Functions**: Function names and ARNs
- **Monitoring**: Dashboard URLs and alarm names

## Best Practices

1. **Naming Convention**: Use consistent naming across all stacks
2. **Parameter Validation**: Validate all input parameters
3. **Resource Tagging**: Tag all resources for cost tracking
4. **Security**: Follow least privilege principle
5. **Monitoring**: Include monitoring in all stacks
6. **Documentation**: Keep templates well-documented

## Troubleshooting

### Common Issues

1. **Stack Dependencies**: Ensure child stacks are uploaded to S3
2. **Parameter Mismatch**: Verify parameter names and types
3. **Resource Limits**: Check AWS service limits
4. **Permissions**: Ensure sufficient IAM permissions

### Debugging Commands

```bash
# Check stack status
aws cloudformation describe-stacks --stack-name <stack-name>

# View stack events
aws cloudformation describe-stack-events --stack-name <stack-name>

# Validate template
aws cloudformation validate-template --template-body file://parent.yaml
```

## Future Enhancements

1. **Cross-Region Replication**: For disaster recovery
2. **Multi-AZ Deployment**: For high availability
3. **Cost Optimization**: Reserved capacity and spot instances
4. **Security Hardening**: Additional security controls
5. **Automated Testing**: CI/CD pipeline integration
