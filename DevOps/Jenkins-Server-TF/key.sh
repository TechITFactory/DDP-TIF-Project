#!/bin/bash

# Define variables
KEY_BASE_NAME="jenkins-key"
VARS_FILE="variables.tfvars"
TMP_FILE="${VARS_FILE}.tmp"
BUCKET_NAME="techit-1707034503" # Replace with your actual S3 bucket name

# Generate a unique name for the key pair
UNIQUE_KEY_NAME="${KEY_BASE_NAME}-$(date +%s)"

# Create a new AWS key pair
aws ec2 create-key-pair --key-name "$UNIQUE_KEY_NAME" --query 'KeyMaterial' --output text > "${UNIQUE_KEY_NAME}.pem" && chmod 400 "${UNIQUE_KEY_NAME}.pem"

# Upload the key pair to S3
aws s3 cp "${UNIQUE_KEY_NAME}.pem" s3://$BUCKET_NAME/${UNIQUE_KEY_NAME}.pem

# Initialize a flag to track if key-name has been found
found=0

# Read variables.tfvars line by line
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == key-name* ]]; then
        # Replace the key-name line
        echo "key-name = \"${UNIQUE_KEY_NAME}\"" >> "$TMP_FILE"
        found=1
    else
        # Copy the line as is
        echo "$line" >> "$TMP_FILE"
    fi
done < "$VARS_FILE"

# If key-name was not found, append it
if [[ $found -eq 0 ]]; then
    echo "key-name = \"${UNIQUE_KEY_NAME}\"" >> "$TMP_FILE"
fi

# Replace the old variables.tfvars file with the new one
mv "$TMP_FILE" "$VARS_FILE"

echo "AWS Key Pair created, $VARS_FILE updated, and key uploaded to S3."