#!/bin/bash
# Usage: ./show-cfn-errors.sh MyAppStack ap-southeast-2

STACK_NAME=$1
REGION=$2

if [ -z "$STACK_NAME" ] || [ -z "$REGION" ]; then
  echo "Usage: $0 <stack-name> <region>"
  exit 1
fi

echo "🔍 Checking errors for stack: $STACK_NAME in region: $REGION"
echo

# Get all nested stack IDs (including root)
STACKS=$(aws cloudformation describe-stack-resources \
  --stack-name $STACK_NAME \
  --region $REGION \
  --query "StackResources[?ResourceType=='AWS::CloudFormation::Stack'].PhysicalResourceId" \
  --output text)

STACKS="$STACK_NAME $STACKS"

for stack in $STACKS; do
  echo "===== Errors for stack: $stack ====="
  aws cloudformation describe-stack-events \
    --stack-name $stack \
    --region $REGION \
    --query "StackEvents[?contains(ResourceStatus, 'FAILED')].[Timestamp, LogicalResourceId, ResourceType, ResourceStatusReason]" \
    --output table
  echo
done
