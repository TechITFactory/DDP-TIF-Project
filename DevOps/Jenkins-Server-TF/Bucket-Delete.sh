#!/bin/bash

BUCKET_NAME="techit-1707043777"
DYNAMODB_TABLE_NAME="Lock-Files"
REGION="us-east-1"

export AWS_DEFAULT_REGION=$REGION

# Function to delete all versions and delete markers from the S3 bucket
delete_all_versions() {
    echo "Deleting all versions and delete markers from $BUCKET_NAME..."
    
    # Delete all object versions
    aws s3api list-object-versions --bucket "$BUCKET_NAME" \
        --query 'Versions[].{Key:Key,VersionId:VersionId}' --output text |
    while read -r KEY VERSION_ID; do
        aws s3api delete-object --bucket "$BUCKET_NAME" --key "$KEY" --version-id "$VERSION_ID"
    done

    # Delete all delete markers
    aws s3api list-object-versions --bucket "$BUCKET_NAME" \
        --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output text |
    while read -r KEY VERSION_ID; do
        aws s3api delete-object --bucket "$BUCKET_NAME" --key "$KEY" --version-id "$VERSION_ID"
    done
}

# Delete all versions and delete markers
delete_all_versions

# Attempt to delete the S3 bucket
if aws s3 rb "s3://$BUCKET_NAME" --force; then
    echo "Bucket $BUCKET_NAME successfully deleted."
else
    echo "Failed to delete bucket $BUCKET_NAME."
    exit 1
fi

# Delete the DynamoDB table
echo "Deleting DynamoDB table $DYNAMODB_TABLE_NAME..."
if aws dynamodb delete-table --table-name "$DYNAMODB_TABLE_NAME"; then
    echo "DynamoDB table $DYNAMODB_TABLE_NAME successfully deleted."
else
    echo "Failed to delete DynamoDB table $DYNAMODB_TABLE_NAME."
    exit 1
fi