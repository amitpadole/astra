# VPC Architecture Documentation

## 🌐 **LCPL VPC Overview**

The LCPL VPC is designed with high availability, security, and scalability in mind, providing a robust foundation for the Blot Parser application.

### **📊 VPC Specifications**

| Component | Specification | Details |
|-----------|---------------|---------|
| **VPC Name** | `lcpl-vpc` | Custom VPC for LCPL project |
| **CIDR Block** | `10.0.0.0/20` | 4096 IP addresses total |
| **Availability Zones** | 1 (us-east-1a) | Single AZ for cost optimization |
| **Public Subnets** | 1 (20% of IPs) | ~819 IPs |
| **Private Subnets** | 1 (80% of IPs) | ~3277 IPs |
| **NAT Gateways** | 1 (single AZ) | Cost-optimized for development |

## 🏗️ **Network Architecture**

### **VPC CIDR Allocation**

```
VPC: 10.0.0.0/20 (4096 IPs)
├── Public Subnet (20% = ~819 IPs)
│   └── us-east-1a: 10.0.0.0/22   (1024 IPs)
└── Private Subnet (80% = ~3277 IPs)
    └── us-east-1a: 10.0.4.0/22   (1024 IPs)
```

### **Subnet Distribution**

| AZ | Public Subnet | Private Subnet | NAT Gateway |
|----|---------------|----------------|-------------|
| us-east-1a | 10.0.0.0/22 | 10.0.4.0/22 | ✅ |

## 🔒 **Security Architecture**

### **Security Groups**

#### **Default Security Group**
- **Name**: `lcpl-vpc-default-sg-{environment}`
- **Description**: Default security group for LCPL VPC
- **Ingress Rules**:
  - Allow all traffic within the security group
- **Egress Rules**:
  - Allow all outbound traffic (0.0.0.0/0)

### **Network ACLs**
- **Default Network ACLs**: Inherited from VPC
- **Custom ACLs**: Can be added as needed

## 🌐 **Internet Connectivity**

### **Public Subnets**
- **Internet Gateway**: Direct internet access
- **Route Table**: Routes to Internet Gateway (0.0.0.0/0)
- **Auto-assign Public IP**: Enabled
- **Use Cases**: Load balancers, NAT gateways, bastion hosts

### **Private Subnets**
- **NAT Gateways**: Outbound internet access
- **Route Tables**: Routes to NAT Gateways (0.0.0.0/0)
- **No Direct Internet**: Secure, controlled access
- **Use Cases**: Application servers, databases, Lambda functions

## 🔗 **VPC Endpoints**

### **Gateway Endpoints**
- **S3 Endpoint**: Private access to S3 services
- **DynamoDB Endpoint**: Private access to DynamoDB services

### **Interface Endpoints** (Optional)
- Can be added for other AWS services as needed
- Provides private connectivity to AWS services

## 🚀 **GitHub Actions Integration**

### **Deployment Requirements**
- **NAT Gateways**: Enable outbound internet access for GitHub Actions
- **VPC Endpoints**: Private access to AWS services
- **Security Groups**: Allow necessary traffic

### **Deployment Flow**
1. **GitHub Actions** triggers deployment
2. **CloudFormation** creates VPC infrastructure
3. **NAT Gateways** provide internet access for deployments
4. **VPC Endpoints** enable private service access

## 📋 **Resource Naming Convention**

### **VPC Resources**
```
{project-name}-{environment}-{resource-type}
```

### **Examples**
- `blot-parser-dev-vpc`
- `blot-parser-dev-public-subnet-1a`
- `blot-parser-dev-private-subnet-1a`
- `blot-parser-dev-nat-gateway-1a`
- `blot-parser-dev-default-sg`

## 💰 **Cost Optimization**

### **NAT Gateway Costs**
- **1 NAT Gateway**: ~$45/month (Single AZ for cost optimization)
- **Data Processing**: $0.045/GB processed
- **Elastic IP**: $3.65/month per IP

### **Cost Optimization Strategies**
1. **Single NAT Gateway**: ✅ Implemented for cost savings
2. **VPC Endpoints**: ✅ Implemented to reduce NAT Gateway usage
3. **Single AZ**: ✅ Single availability zone for development

## 🔧 **Deployment Process**

### **1. VPC Stack Deployment**
```bash
# Deploy VPC infrastructure
aws cloudformation deploy \
  --template-file cloudformation/vpc.yaml \
  --stack-name blot-parser-vpc-dev \
  --parameter-overrides \
    Environment=dev \
    ProjectName=blot-parser \
  --capabilities CAPABILITY_NAMED_IAM
```

### **2. Parent Stack Deployment**
```bash
# Deploy complete infrastructure
aws cloudformation deploy \
  --template-file cloudformation/parent.yaml \
  --stack-name blot-parser-infrastructure-dev \
  --parameter-overrides \
    Environment=dev \
    ProjectName=blot-parser \
    AWSAccountId=123456789012 \
  --capabilities CAPABILITY_NAMED_IAM
```

## 🧪 **Testing and Validation**

### **Connectivity Tests**
```bash
# Test VPC connectivity
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=lcpl-vpc-dev"

# Test subnet connectivity
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxxxxxx"

# Test NAT Gateway status
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=vpc-xxxxxxxxx"
```

### **Security Validation**
```bash
# Check security groups
aws ec2 describe-security-groups --filters "Name=group-name,Values=lcpl-vpc-default-sg-dev"

# Check route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-xxxxxxxxx"
```

## 📊 **Monitoring and Logging**

### **CloudWatch Metrics**
- **VPC Flow Logs**: Network traffic monitoring
- **NAT Gateway Metrics**: Data processing and availability
- **Security Group Metrics**: Traffic patterns

### **Alarms and Notifications**
- **NAT Gateway Availability**: Monitor gateway health
- **Data Processing**: Track NAT Gateway usage
- **Security Events**: Monitor security group changes

## 🔄 **High Availability Features**

### **Single AZ Deployment**
- **1 Availability Zone**: us-east-1a (Cost-optimized for development)
- **NAT Gateway**: Single NAT Gateway for cost savings
- **Subnets**: Single public and private subnet

### **Fault Tolerance**
- **AZ Failure**: Single point of failure (acceptable for development)
- **NAT Gateway Failure**: Private subnet loses internet access
- **Internet Gateway**: Highly available AWS service

## 🚨 **Troubleshooting**

### **Common Issues**

1. **NAT Gateway Not Available**
   - Check Elastic IP allocation
   - Verify subnet configuration
   - Check IAM permissions

2. **Private Subnet Connectivity**
   - Verify route table configuration
   - Check security group rules
   - Validate NAT Gateway status

3. **VPC Endpoint Issues**
   - Check endpoint policy
   - Verify route table associations
   - Test endpoint connectivity

### **Debug Commands**
```bash
# Check VPC status
aws ec2 describe-vpcs --vpc-ids vpc-xxxxxxxxx

# Check NAT Gateway status
aws ec2 describe-nat-gateways --nat-gateway-ids nat-xxxxxxxxx

# Check route tables
aws ec2 describe-route-tables --route-table-ids rtb-xxxxxxxxx

# Test connectivity
ping 8.8.8.8  # From private subnet instance
```

## 📚 **Best Practices**

### **Security**
- Use private subnets for sensitive resources
- Implement least privilege security groups
- Enable VPC Flow Logs for monitoring
- Use VPC endpoints for AWS services

### **Cost Management**
- Monitor NAT Gateway usage
- Use VPC endpoints to reduce NAT Gateway traffic
- Consider single NAT Gateway for cost savings
- Implement proper tagging for cost allocation

### **Performance**
- Distribute resources across multiple AZs
- Use appropriate instance types for NAT Gateways
- Monitor network performance metrics
- Optimize security group rules

## 🔗 **Related Documentation**

- [AWS VPC User Guide](https://docs.aws.amazon.com/vpc/)
- [NAT Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
- [VPC Endpoints Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-endpoints.html)
- [Security Groups Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
