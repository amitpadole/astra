# GitHub Secrets Setup Guide

This guide will help you configure GitHub secrets for automated deployment.

## 🔐 Required GitHub Secrets

You need to add these secrets to your GitHub repository:

| Secret Name | Description | Required For |
|-------------|-------------|--------------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key ID | All deployments |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Access Key | All deployments |

## 📋 Step-by-Step Setup

### Step 1: Create AWS IAM User

1. **Go to AWS IAM Console**
   - Navigate to [AWS IAM Console](https://console.aws.amazon.com/iam/)
   - Click "Users" in the left sidebar

2. **Create New User**
   - Click "Create user"
   - Username: `github-actions-blot-parser`
   - Access type: "Programmatic access"

3. **Attach Policies**
   - Click "Attach existing policies directly"
   - Search and select these policies:
     - `CloudFormationFullAccess`
     - `S3FullAccess`
     - `DynamoDBFullAccess`
     - `LambdaFullAccess`
     - `IAMFullAccess`
     - `CloudWatchFullAccess`

4. **Create Access Keys**
   - After user creation, go to "Security credentials" tab
   - Click "Create access key"
   - Choose "Application running outside AWS"
   - **IMPORTANT**: Save the Access Key ID and Secret Access Key

### Step 2: Configure GitHub Secrets

1. **Go to Your GitHub Repository**
   - Navigate to your repository on GitHub
   - Click "Settings" (top right of repository)

2. **Navigate to Secrets**
   - In the left sidebar, click "Secrets and variables"
   - Click "Actions"

3. **Add AWS_ACCESS_KEY_ID**
   - Click "New repository secret"
   - Name: `AWS_ACCESS_KEY_ID`
   - Value: `Your AWS Access Key ID from Step 1`
   - Click "Add secret"

4. **Add AWS_SECRET_ACCESS_KEY**
   - Click "New repository secret"
   - Name: `AWS_SECRET_ACCESS_KEY`
   - Value: `Your AWS Secret Access Key from Step 1`
   - Click "Add secret"

### Step 3: Verify Configuration

1. **Run Verification Script**
   ```bash
   cd aws-infra
   ./verify-credentials.sh
   ```

2. **Test GitHub Actions**
   - Go to "Actions" tab in your GitHub repository
   - Click "Deploy Infrastructure"
   - Click "Run workflow"
   - Select "dev" environment
   - Click "Run workflow"

## 🔒 Security Best Practices

### IAM User Permissions
- **Least Privilege**: Only grant necessary permissions
- **Separate User**: Use dedicated user for GitHub Actions
- **Regular Rotation**: Rotate access keys regularly

### GitHub Secrets
- **Never Commit**: Never commit secrets to code
- **Repository Level**: Secrets are repository-specific
- **Environment Protection**: PROD environment requires approval

## 🧪 Testing Your Setup

### Local Testing
```bash
# Test AWS credentials
aws sts get-caller-identity

# Test CloudFormation access
aws cloudformation list-stacks --max-items 1

# Test S3 access
aws s3 ls

# Test DynamoDB access
aws dynamodb list-tables

# Test Lambda access
aws lambda list-functions --max-items 1
```

### GitHub Actions Testing
1. **Create Test Branch**
   ```bash
   git checkout -b test-github-actions
   git push origin test-github-actions
   ```

2. **Trigger Workflow**
   - Go to Actions tab
   - Select "Deploy Infrastructure"
   - Click "Run workflow"
   - Select "dev" environment

3. **Monitor Progress**
   - Watch workflow execution
   - Check logs for any errors
   - Verify AWS resources are created

## 🚨 Troubleshooting

### Common Issues

1. **Invalid Credentials**
   - Error: "The security token included in the request is invalid"
   - Solution: Check if credentials are correct and not expired

2. **Insufficient Permissions**
   - Error: "User is not authorized to perform: cloudformation:CreateStack"
   - Solution: Ensure IAM user has required policies attached

3. **Region Mismatch**
   - Error: "The specified bucket does not exist"
   - Solution: Ensure AWS_REGION is set correctly

4. **GitHub Secrets Not Found**
   - Error: "AWS_ACCESS_KEY_ID not found"
   - Solution: Verify secrets are added to repository settings

### Debug Commands

```bash
# Check AWS configuration
aws configure list

# Test specific service access
aws cloudformation describe-stacks --stack-name test-stack
aws s3 ls s3://your-bucket-name
aws dynamodb describe-table --table-name your-table-name
aws lambda get-function --function-name your-function-name
```

## 📚 Additional Resources

- [AWS IAM User Guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [AWS CloudFormation Permissions](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-iam-template.html)

## ✅ Verification Checklist

- [ ] AWS IAM user created with required policies
- [ ] Access keys generated and saved securely
- [ ] GitHub secrets configured (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
- [ ] Local AWS CLI working (`aws sts get-caller-identity`)
- [ ] GitHub Actions workflow can access AWS
- [ ] Test deployment successful

## 🆘 Getting Help

If you encounter issues:

1. **Check GitHub Actions Logs**: Go to Actions tab → Select workflow → View logs
2. **Verify AWS Permissions**: Run `./verify-credentials.sh`
3. **Check AWS Console**: Verify resources are being created
4. **Review Documentation**: Check component README files

## 🔄 Next Steps

After successful setup:

1. **Deploy to DEV**: Push to `develop` branch
2. **Deploy to PROD**: Merge to `main` branch
3. **Monitor Deployments**: Check GitHub Actions and AWS Console
4. **Test Functionality**: Upload Excel files to S3 bucket
