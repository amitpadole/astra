# Astra - Blot Parser Project

A comprehensive Excel file processing system with AWS Lambda deployment and GitHub Actions CI/CD.

## 🏗️ Project Structure

```
astra/
├── blot-parser/           # Python Lambda function
├── aws-infra/            # AWS infrastructure (CloudFormation)
├── .github/              # GitHub Actions CI/CD
└── README.md             # This file
```

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured
- Python 3.11+
- Git

### Local Development
```bash
# 1. Clone repository
git clone <repository-url>
cd astra

# 2. Set up blot-parser
cd blot-parser
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 3. Test locally
./run_parser.sh
```

### AWS Deployment
```bash
# 1. Configure AWS credentials
cd aws-infra
./setup-credentials.sh

# 2. Deploy infrastructure
./deploy-modular.sh dev us-east-1

# 3. Deploy Lambda
cd ../blot-parser
./deploy-lambda.sh
```

## 🔄 CI/CD Pipeline

### Automated Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| **Test** | Push/PR | Run tests and validation |
| **Deploy Infrastructure** | Push to main/develop | Deploy AWS resources |
| **Deploy Lambda** | Push to main/develop | Deploy Lambda functions |
| **Cleanup** | Manual | Remove AWS resources |

### Environments

- **DEV**: `develop` branch → Automatic deployment
- **PROD**: `main` branch → Automatic deployment (with approval)

### Manual Deployment

1. Go to **Actions** tab in GitHub
2. Select workflow (Deploy Infrastructure/Lambda)
3. Click **Run workflow**
4. Select environment (dev/prod)

## 📁 Components

### blot-parser/
Python Lambda function for Excel processing:
- **Excel Processing**: Read and parse Excel files
- **Field Mapping**: Convert vendor-specific fields to generic format
- **DynamoDB Storage**: Save processed data
- **Modular Architecture**: Clean, maintainable code

### aws-infra/
AWS infrastructure as code:
- **Modular CloudFormation**: Parent-child stack pattern
- **S3 Buckets**: Input files and deployments
- **DynamoDB**: Data storage with GSI indexes
- **Lambda Functions**: Serverless processing
- **Monitoring**: CloudWatch dashboards and alarms

### .github/
GitHub Actions CI/CD:
- **Automated Testing**: Code quality and functionality
- **Environment Management**: DEV/PROD deployments
- **Security**: Environment protection and secrets
- **Dependabot**: Automated dependency updates

## 🛠️ Development

### Code Quality
- **Linting**: flake8 with custom rules
- **Testing**: Unit tests for all components
- **Validation**: CloudFormation template validation
- **Documentation**: Comprehensive README files

### Security
- **Environment Protection**: PROD requires 2 reviewers
- **Secrets Management**: GitHub Secrets for AWS credentials
- **IAM Roles**: Least privilege access
- **Resource Isolation**: Separate DEV/PROD environments

## 📊 Monitoring

### CloudWatch Dashboard
- Lambda function metrics
- DynamoDB performance
- Error rates and duration
- Real-time logs

### GitHub Actions
- Workflow status and logs
- Deployment history
- Test results
- Security scans

## 🔧 Troubleshooting

### Common Issues
1. **AWS Credentials**: Check GitHub Secrets
2. **CloudFormation Errors**: Check stack events
3. **Lambda Failures**: Check CloudWatch logs
4. **Permission Issues**: Verify IAM roles

### Debug Commands
```bash
# Check AWS connectivity
aws sts get-caller-identity

# View CloudFormation stacks
aws cloudformation list-stacks

# Check Lambda logs
aws logs tail /aws/lambda/blot-parser-dev --follow
```

## 📚 Documentation

- **[blot-parser/README.md](blot-parser/README.md)**: Lambda function documentation
- **[aws-infra/README.md](aws-infra/README.md)**: Infrastructure documentation
- **[.github/README.md](.github/README.md)**: CI/CD documentation

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Issues**: Create GitHub issues for bugs/features
- **Documentation**: Check component README files
- **CI/CD**: Check GitHub Actions logs
- **AWS**: Monitor CloudWatch dashboards
