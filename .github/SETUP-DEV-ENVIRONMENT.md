# DEV Environment Setup Guide

This guide will help you configure and test the DEV environment for automated deployment.

## 🔐 GitHub Environment Configuration

### **Current Setup Status**
✅ **DEV Environment**: Configured with AWS credentials  
✅ **Environment Protection**: No reviewers required, 0-minute wait  
✅ **Workflows**: Updated to focus on DEV environment  

### **Required GitHub Secrets (DEV Environment)**

Your DEV environment should have these secrets configured:

| Secret Name | Description | Required For |
|-------------|-------------|--------------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key ID | All deployments |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Access Key | All deployments |

## 🚀 **Deployment Triggers**

### **Automatic Deployment**
- **Push to `develop` branch** → Deploy to DEV
- **Pull Request to `develop`** → Deploy to DEV

### **Manual Deployment**
- Go to **Actions** tab → **Deploy Infrastructure** → **Run workflow**
- Select **dev** environment
- Click **Run workflow**

## 🛠️ **Workflow Configuration**

### **Infrastructure Deployment**
- **Trigger**: Push to `develop` branch
- **Environment**: `dev`
- **Stack Name**: `blot-parser-infrastructure-dev`
- **Region**: `us-east-1`

### **Lambda Deployment**
- **Trigger**: Push to `develop` branch
- **Environment**: `dev`
- **Function Name**: `blot-parser-dev`
- **Region**: `us-east-1`

## 📋 **Deployment Process**

### **1. Infrastructure Deployment**
1. **Upload CloudFormation templates** to S3
2. **Deploy parent stack** with child stack references
3. **Get stack outputs** (buckets, tables, roles)
4. **Create environment file** for Lambda
5. **Commit configuration** to repository

### **2. Lambda Deployment**
1. **Install dependencies** from `requirements-lambda.txt`
2. **Create deployment package** with all dependencies
3. **Deploy to AWS Lambda** using deployment bucket
4. **Update function configuration** with environment variables

## 🧪 **Testing Your Setup**

### **Local Testing**
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

### **GitHub Actions Testing**
1. **Create Test Branch**
   ```bash
   git checkout -b test-dev-deployment
   git push origin test-dev-deployment
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

## 🔍 **Verification Steps**

### **1. Check Environment Secrets**
- Go to Repository Settings → Secrets and variables → Actions
- Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set for DEV environment

### **2. Test Deployment**
- Push a change to `develop` branch
- Monitor the deployment in GitHub Actions
- Check AWS Console for created resources

### **3. Verify Resources**
- **S3 Buckets**: Input and deployment buckets created
- **DynamoDB Table**: Data table created
- **Lambda Function**: Parser function deployed
- **IAM Roles**: Execution roles created

## 🚨 **Troubleshooting**

### **Common Issues**

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
   - Solution: Check if secrets are set for DEV environment

### **Debug Commands**
```bash
# Check AWS CLI configuration
aws configure list

# Test specific permissions
aws cloudformation describe-stacks --max-items 1
aws s3 ls
aws dynamodb list-tables
aws lambda list-functions --max-items 1
```

## 📚 **Next Steps**

1. **Test DEV Deployment**: Push to `develop` branch
2. **Monitor Resources**: Check AWS Console
3. **Verify Lambda**: Test function execution
4. **Add PROD Environment**: When ready for production

## 🔒 **Security Best Practices**

### **Environment Protection**
- **DEV**: No reviewers required, 0-minute wait
- **Secrets**: Environment-specific, not repository-wide
- **Access**: Limited to specific branches

### **IAM Permissions**
- **Least Privilege**: Only necessary permissions
- **Separate User**: Dedicated user for GitHub Actions
- **Regular Rotation**: Rotate access keys regularly

### **GitHub Security**
- **Environment Secrets**: Isolated per environment
- **Branch Protection**: Specific branch triggers
- **Review Process**: Required approvals for deployments
