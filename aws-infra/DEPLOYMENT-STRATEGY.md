# Astra Deployment Strategy

## 🏗️ **Two-Phase Deployment Architecture**

### **Phase 1: Network Infrastructure (Deploy Once)**
- **Purpose**: Shared network resources (VPC, subnets, NAT Gateway)
- **Frequency**: Deploy once per environment
- **Cost**: High initial cost, but shared across all applications
- **Template**: `network.yaml`
- **Workflow**: `deploy-network.yaml`

### **Phase 2: Application Infrastructure (Deploy Frequently)**
- **Purpose**: Application-specific resources (Lambda, DynamoDB, S3)
- **Frequency**: Deploy on every code change
- **Cost**: Low cost, reuses existing network
- **Template**: `parent.yaml` (references child stacks)
- **Workflow**: `deploy-infrastructure.yaml`

## 🎯 **Benefits of This Approach**

### **✅ Cost Optimization**
- **NAT Gateway**: $45/month per gateway (shared across all deployments)
- **VPC Endpoints**: Fixed cost, shared across applications
- **No duplicate network resources**

### **✅ Faster Deployments**
- **Network**: Deploy once, reuse forever
- **Application**: Quick deployments without network setup
- **No VPC creation delays**

### **✅ Resource Reuse**
- **Same VPC**: All applications use the same network
- **Same subnets**: Consistent network configuration
- **Same security groups**: Shared security policies

## 📋 **Deployment Process**

### **1. Initial Setup (One Time)**
```bash
# Deploy network infrastructure
gh workflow run deploy-network.yaml -f environment=dev
```

### **2. Application Deployments (Frequent)**
```bash
# Deploy application infrastructure
gh workflow run deploy-infrastructure.yaml -f environment=dev
```

## 🔧 **Network Infrastructure Details**

### **VPC Configuration**
- **CIDR**: `10.0.0.0/20` (4096 IPs)
- **Public Subnet**: `10.0.0.0/22` (1024 IPs)
- **Private Subnet**: `10.0.4.0/22` (1024 IPs)
- **AZ**: Single AZ for cost optimization

### **Shared Resources**
- **NAT Gateway**: Shared across all applications
- **VPC Endpoints**: S3 and DynamoDB
- **Security Groups**: Default security group
- **Route Tables**: Public and private routing

## 🚀 **Quick Start**

### **For New Environment**
1. **Deploy Network**: Run `deploy-network.yaml` once
2. **Deploy Apps**: Run `deploy-infrastructure.yaml` for each application

### **For Existing Environment**
1. **Network exists**: Skip network deployment
2. **Deploy Apps**: Run `deploy-infrastructure.yaml` directly

## 💰 **Cost Comparison**

### **Old Approach (Per Deployment)**
- VPC: $0
- NAT Gateway: $45/month
- VPC Endpoints: $7.20/month
- **Total**: $52.20/month per deployment

### **New Approach (Shared)**
- VPC: $0
- NAT Gateway: $45/month (shared)
- VPC Endpoints: $7.20/month (shared)
- **Total**: $52.20/month (shared across all deployments)

## 🔄 **Migration Strategy**

### **Existing Deployments**
1. **Keep existing stacks**: Don't delete them yet
2. **Deploy new network**: Create shared network infrastructure
3. **Update applications**: Point to shared network
4. **Cleanup old stacks**: Remove old network resources

### **New Deployments**
1. **Use shared network**: Reference existing VPC/subnets
2. **No network creation**: Only deploy application resources
3. **Faster deployments**: No network setup time
