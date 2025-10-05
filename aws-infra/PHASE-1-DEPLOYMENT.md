# 🚀 Phase 1 Deployment Guide - Network Infrastructure

## **Overview**
This is a **minimal, phased deployment** approach. We start with just the essential infrastructure and gradually add more components.

## **Phase 1: What We're Deploying** ✅

### **Infrastructure Components**
1. **S3 Buckets** (Input + Deployment)
2. **VPC Network** (10.0.0.0/20 CIDR)
3. **Public Subnet** (10.0.0.0/22)
4. **Private Subnet** (10.0.4.0/22)
5. **NAT Gateway** (for private subnet internet access)
6. **Security Groups** (basic VPC security)

### **What We're NOT Deploying Yet** ⏳
- DynamoDB tables
- Lambda functions
- IAM roles
- CloudWatch monitoring
- VPC Endpoints

## **Deployment Steps** 📋

### **Step 1: Deploy Network Infrastructure**
```bash
# Option 1: Manual trigger via GitHub Actions
gh workflow run deploy-network.yaml -f environment=dev

# Option 2: Push to develop branch (auto-trigger)
git push origin develop
```

### **Step 2: Deploy Application Infrastructure (S3 + Network)**
```bash
# Option 1: Manual trigger via GitHub Actions
gh workflow run deploy-infrastructure.yaml -f environment=dev

# Option 2: Push to develop branch (auto-trigger)
git push origin develop
```

## **Expected Results** 🎯

### **CloudFormation Stacks Created**
1. `astra-network-dev` - Network infrastructure
2. `astra-infrastructure-dev-{timestamp}` - S3 + Network via parent stack

### **AWS Resources Created**
- **S3 Buckets**: `astra-input-dev-{account-id}`, `astra-deployments-dev-{account-id}`
- **VPC**: `astra-vpc-dev` (10.0.0.0/20)
- **Subnets**: Public (10.0.0.0/22), Private (10.0.4.0/22)
- **NAT Gateway**: `astra-nat-dev`
- **Security Group**: `astra-default-sg-dev`

## **Cost Estimate** 💰

### **Phase 1 Costs (Monthly)**
- **NAT Gateway**: $45.00
- **Elastic IP**: $3.65
- **S3 Storage**: ~$1.00 (minimal usage)
- **VPC**: $0.00
- **Total**: ~$50/month

### **Cost Optimization Notes**
- Single AZ deployment (cost-optimized for DEV)
- No VPC Endpoints (saves $14.40/month)
- No Lambda functions (saves compute costs)

## **Verification Steps** ✅

### **1. Check CloudFormation Stacks**
```bash
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE --query "StackSummaries[?contains(StackName, 'astra')].{Name:StackName,Status:StackStatus}" --output table
```

### **2. Check S3 Buckets**
```bash
aws s3 ls | grep astra
```

### **3. Check VPC Resources**
```bash
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=astra" --query "Vpcs[].{VpcId:VpcId,CidrBlock:CidrBlock,State:State}"
```

## **Troubleshooting** 🔧

### **Common Issues**
1. **S3 Bucket Already Exists**: Delete old buckets or use different environment
2. **VPC CIDR Conflict**: Change CIDR in network.yaml if needed
3. **Permissions**: Ensure GitHub secrets are correctly configured

### **Debug Commands**
```bash
# Check stack events
aws cloudformation describe-stack-events --stack-name astra-network-dev

# Check stack outputs
aws cloudformation describe-stacks --stack-name astra-network-dev --query 'Stacks[0].Outputs'
```

## **Next Phases** 🚀

### **Phase 2: Database + IAM**
- DynamoDB tables
- IAM roles and policies
- Basic Lambda function

### **Phase 3: Application Logic**
- Lambda functions
- S3 event triggers
- Data processing pipeline

### **Phase 4: Monitoring + Optimization**
- CloudWatch dashboards
- Cost optimization
- Security hardening

## **Success Criteria** ✅

- [ ] Network infrastructure deploys successfully
- [ ] S3 buckets are created and accessible
- [ ] VPC and subnets are properly configured
- [ ] NAT Gateway provides internet access to private subnet
- [ ] Security groups allow necessary traffic
- [ ] Total cost is under $60/month
- [ ] Ready for Phase 2 deployment

## **Rollback Plan** 🔄

If deployment fails:
1. **Delete CloudFormation stacks** in reverse order
2. **Clean up S3 buckets** manually
3. **Verify no resources remain** in AWS Console
4. **Fix issues** and retry deployment

```bash
# Delete stacks
aws cloudformation delete-stack --stack-name astra-infrastructure-dev-{timestamp}
aws cloudformation delete-stack --stack-name astra-network-dev
```
