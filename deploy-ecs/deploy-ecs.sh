#!/bin/bash
set -euo pipefail

# --- Params
CLUSTER_NAME="$1"
SERVICE_NAME="$2"
TASK_FAMILY="$3"
REPOSITORY="$4"
IMAGE_TAG="$5"
AWS_REGION="${AWS_REGION:-eu-central-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}"

# --- Build Image URI
IMAGE_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY}:${IMAGE_TAG}"

echo "Updating ECS Task Definition for family: ${TASK_FAMILY}"
echo "New Image: ${IMAGE_URI}"

# --- Fetch current task definition
TASK_DEF_JSON=$(aws ecs describe-task-definition \
  --task-definition "$TASK_FAMILY" \
  --region "$AWS_REGION" \
  --query 'taskDefinition' \
  --output json)

# --- Replace image URI
NEW_TASK_DEF=$(echo "$TASK_DEF_JSON" | jq --arg IMAGE "$IMAGE_URI" '
  .containerDefinitions[0].image = $IMAGE |
  del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)
')

# --- Register new task definition
NEW_TASK_ARN=$(aws ecs register-task-definition \
  --region "$AWS_REGION" \
  --cli-input-json "$NEW_TASK_DEF" \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text)

echo "Registered new Task Definition: $NEW_TASK_ARN"
echo "Updating service '$SERVICE_NAME' in cluster '$CLUSTER_NAME'..."

aws ecs update-service \
  --region "$AWS_REGION" \
  --cluster "$CLUSTER_NAME" \
  --service "$SERVICE_NAME" \
  --task-definition "$NEW_TASK_ARN" \
  --output text > /dev/null

# --- Await cluster stabilization
echo "Waiting for ECS service to stabilize..."

aws ecs wait services-stable \
  --region "$AWS_REGION" \
  --cluster "$CLUSTER_NAME" \
  --services "$SERVICE_NAME"

echo "ECS service '$SERVICE_NAME' is stable and running the new task."
