#!/bin/bash

# Define AWS Region
REGION="us-east-1"

# Generate random names with compliant structure
BUCKET_NAME="techit-$(date +%s)"
DYNAMODB_TABLE_NAME="Lock-Files-EKSNew"

# Ensure AWS CLI uses the correct region
export AWS_DEFAULT_REGION=$REGION

# Create the S3 bucket with the specified region
aws s3 mb s3://"$BUCKET_NAME" --region $REGION

# Enable versioning on the S3 bucket
aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled

# Create the DynamoDB table
aws dynamodb create-table --table-name "$DYNAMODB_TABLE_NAME" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $REGION