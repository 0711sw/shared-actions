#!/bin/bash
set -euo pipefail

FAMILY="$1"
KEEP="${2:-5}"

if [ -z "$FAMILY" ]; then
  echo "Usage: $0 <task-definition-family> [keep-count]"
  exit 1
fi

echo "Fetching task definition revisions for family '$FAMILY'..."

# Fetch all task definitions (newest first)
TASK_DEFS=($(aws ecs list-task-definitions \
  --family-prefix "$FAMILY" \
  --sort DESC \
  --query "taskDefinitionArns" \
  --output text))

echo "Found ${#TASK_DEFS[@]} revisions"
echo "Keeping the latest $KEEP revisions, cleaning up the rest..."

COUNT=0
for TD in "${TASK_DEFS[@]}"; do
  COUNT=$((COUNT+1))
  if [ "$COUNT" -le "$KEEP" ]; then
    echo "Keeping: $TD"
  else
    echo "Deregistering: $TD"
    aws ecs deregister-task-definition --task-definition "$TD" > /dev/null
  fi
done

echo "Done! Old revisions have been deregistered."
