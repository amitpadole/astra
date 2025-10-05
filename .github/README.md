# GitHub Actions CI/CD

This directory contains GitHub Actions workflows for automated deployment and testing of the Blot Parser project.

## Workflows Overview

### 🔄 Automated Workflows

| Workflow | Trigger | Purpose | Environments |
|----------|---------|---------|-------------|
| **Test** | Push/PR to main/develop | Run tests and validation | - |
| **Deploy Infrastructure** | Push to main/develop, Manual | Deploy AWS infrastructure | DEV, PROD |
| **Deploy Lambda** | Push to main/develop, Manual | Deploy Lambda functions | DEV, PROD |
| **Cleanup** | Manual only | Clean up AWS resources | DEV, PROD |

### 🚀 Deployment Strategy

#### **DEV Environment**
- **Trigger**: Push to `develop` branch or manual dispatch
- **Protection**: 1 reviewer required
- **Wait Time**: 0 minutes
- **Stack Name**: `blot-parser-infrastructure-dev`

#### **PROD Environment**
- **Trigger**: Push to `main` branch or manual dispatch
- **Protection**: 2 reviewers required
- **Wait Time**: 5 minutes
- **Stack Name**: `blot-parser-infrastructure-prod`
- **Required Checks**: All tests must pass

## Workflow Details

### 1. Test Workflow (`test.yml`)

**Purpose**: Validate code quality and functionality

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`

**Steps**:
1. **Python Setup**: Install Python 3.11
2. **Dependencies**: Install project dependencies
3. **Linting**: Run flake8 code quality checks
4. **Unit Tests**: Test individual components
5. **CloudFormation Validation**: Validate template syntax

**Components Tested**:
- `ExcelProcessor` - Excel file processing
- `FieldMapper` - Field mapping logic
- `VendorDetector` - Vendor name detection
- `FileManager` - File operations
- CloudFormation templates

### 2. Deploy Infrastructure (`deploy-infrastructure.yml`)

**Purpose**: Deploy AWS infrastructure using modular CloudFormation

**Triggers**:
- Push to `develop` → Deploy to DEV
- Push to `main` → Deploy to PROD
- Manual dispatch with environment selection

**Steps**:
1. **Checkout**: Get latest code
2. **AWS Setup**: Configure AWS credentials
3. **Template Upload**: Upload child stacks to S3
4. **Stack Deployment**: Deploy parent CloudFormation stack
5. **Output Retrieval**: Get stack outputs
6. **Environment File**: Create `.env` for Lambda
7. **Commit**: Update environment configuration

**Resources Created**:
- S3 buckets (input, deployment)
- DynamoDB tables (data, status)
- IAM roles and policies
- Lambda functions
- CloudWatch monitoring

### 3. Deploy Lambda (`deploy-lambda.yml`)

**Purpose**: Deploy and update Lambda functions

**Triggers**:
- Push to `develop` → Deploy to DEV
- Push to `main` → Deploy to PROD
- Manual dispatch with environment selection

**Steps**:
1. **Checkout**: Get latest code
2. **Python Setup**: Install Python 3.11
3. **AWS Setup**: Configure AWS credentials
4. **Dependencies**: Install Lambda dependencies
5. **Package Creation**: Create deployment ZIP
6. **S3 Upload**: Upload package to S3
7. **Lambda Update**: Update function code
8. **Testing**: Test Lambda function
9. **Cleanup**: Remove temporary files

**Lambda Configuration**:
- **Runtime**: Python 3.11
- **Timeout**: 300 seconds
- **Memory**: 512 MB
- **Environment Variables**: Auto-configured

### 4. Cleanup (`cleanup.yml`)

**Purpose**: Safely remove AWS resources

**Triggers**:
- Manual dispatch only
- Requires confirmation ("DELETE")

**Steps**:
1. **Confirmation**: Verify deletion intent
2. **AWS Setup**: Configure credentials
3. **S3 Cleanup**: Empty all buckets
4. **Stack Deletion**: Delete CloudFormation stack
5. **Verification**: Confirm cleanup completion

## Environment Configuration

### Required Secrets

Configure these secrets in your GitHub repository:

| Secret | Description | Required For |
|--------|-------------|--------------|
| `AWS_ACCESS_KEY_ID` | AWS access key | All deployments |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | All deployments |

### Environment Variables

| Variable | DEV | PROD | Description |
|----------|-----|------|-------------|
| `AWS_REGION` | us-east-1 | us-east-1 | AWS region |
| `PROJECT_NAME` | blot-parser | blot-parser | Project identifier |
| `ENVIRONMENT` | dev | prod | Environment name |
| `STACK_NAME` | blot-parser-infrastructure-dev | blot-parser-infrastructure-prod | CloudFormation stack |

## Deployment Process

### 🚀 Automatic Deployment

#### DEV Environment
```bash
# 1. Make changes to develop branch
git checkout develop
git add .
git commit -m "Add new feature"
git push origin develop

# 2. GitHub Actions automatically:
#    - Runs tests
#    - Deploys infrastructure to DEV
#    - Deploys Lambda to DEV
```

#### PROD Environment
```bash
# 1. Merge develop to main
git checkout main
git merge develop
git push origin main

# 2. GitHub Actions automatically:
#    - Runs tests
#    - Deploys infrastructure to PROD
#    - Deploys Lambda to PROD
```

### 🎯 Manual Deployment

#### Deploy Infrastructure
1. Go to **Actions** → **Deploy Infrastructure**
2. Click **Run workflow**
3. Select environment (dev/prod)
4. Click **Run workflow**

#### Deploy Lambda
1. Go to **Actions** → **Deploy Lambda Functions**
2. Click **Run workflow**
3. Select environment (dev/prod)
4. Click **Run workflow**

#### Cleanup
1. Go to **Actions** → **Cleanup Infrastructure**
2. Click **Run workflow**
3. Select environment (dev/prod)
4. Type "DELETE" in confirmation field
5. Click **Run workflow**

## Monitoring and Troubleshooting

### 📊 Monitoring

#### CloudWatch Dashboard
- **URL**: Available in deployment outputs
- **Metrics**: Lambda invocations, errors, duration
- **DynamoDB**: Read/write capacity, throttles
- **Logs**: Real-time Lambda function logs

#### GitHub Actions
- **Status**: Check workflow runs in Actions tab
- **Logs**: View detailed logs for each step
- **Artifacts**: Download deployment packages

### 🔧 Troubleshooting

#### Common Issues

1. **AWS Credentials**
   ```bash
   # Check if secrets are configured
   # Go to Repository Settings → Secrets and variables → Actions
   ```

2. **CloudFormation Errors**
   ```bash
   # Check stack events
   aws cloudformation describe-stack-events --stack-name blot-parser-infrastructure-dev
   ```

3. **Lambda Deployment Failures**
   ```bash
   # Check Lambda logs
   aws logs tail /aws/lambda/blot-parser-dev --follow
   ```

4. **Permission Issues**
   ```bash
   # Verify IAM permissions
   aws sts get-caller-identity
   ```

#### Debug Commands

```bash
# Check workflow status
gh run list --workflow=deploy-infrastructure.yml

# View workflow logs
gh run view <run-id> --log

# Test AWS connectivity
aws sts get-caller-identity

# Check CloudFormation stacks
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE
```

## Security

### 🔒 Security Measures

1. **Environment Protection**
   - PROD requires 2 reviewers
   - 5-minute wait time for PROD
   - Required status checks

2. **AWS Credentials**
   - Stored as GitHub Secrets
   - Not exposed in logs
   - Environment-specific access

3. **Resource Isolation**
   - Separate stacks for DEV/PROD
   - Environment-specific naming
   - No cross-environment access

### 🛡️ Best Practices

1. **Code Review**
   - All changes require PR review
   - PROD deployments need 2 approvals
   - Automated testing before deployment

2. **Access Control**
   - Least privilege IAM roles
   - Environment-specific permissions
   - Regular access reviews

3. **Monitoring**
   - CloudWatch alarms for errors
   - GitHub Actions status checks
   - Regular security scans

## Cost Optimization

### 💰 Cost Management

1. **Resource Tagging**
   - All resources tagged with environment
   - Cost allocation by project
   - Automated cleanup for DEV

2. **Monitoring**
   - CloudWatch cost metrics
   - Budget alerts
   - Regular cost reviews

3. **Optimization**
   - Pay-per-request DynamoDB
   - S3 lifecycle policies
   - Lambda memory optimization

## Support

### 📞 Getting Help

1. **GitHub Issues**: Create issues for bugs/features
2. **Workflow Logs**: Check Actions tab for errors
3. **AWS Console**: Monitor resources directly
4. **Documentation**: Check project README files

### 🔗 Useful Links

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Project Main README](../README.md)
