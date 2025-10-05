"""
AWS Lambda Function Entry Point
This is the main entry point for the Lambda function
"""

from lambda_handler import lambda_handler

# Export the handler for AWS Lambda
__all__ = ['lambda_handler']
