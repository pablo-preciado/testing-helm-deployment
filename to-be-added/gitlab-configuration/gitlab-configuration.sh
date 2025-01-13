#!/bin/bash

# Variables
GITLAB_URL="https://gitlab.apps.cluster-jqv2z.jqv2z.gcp.redhatworkshops.io"
ROOT_USER="root"
ROOT_PASS="K1xZVRdxgY8OBbH6LyFQD62uLNsqULtiN13JXJMUcirJlYZ7D2jNnpidMxkH3Sbz"
GITHUB_PAT=''
GITHUB_REPO_1="https://github.com/pablo-preciado/aap-ocpv"
GITHUB_REPO_2="https://github.com/pablo-preciado/testing-helm-deployment"

# Authenticate and get GitLab access token
echo "Authenticating with GitLab..."
GITLAB_TOKEN=$(curl -s --request POST "$GITLAB_URL/oauth/token" \
  --data "grant_type=password" \
  --data "username=$ROOT_USER" \
  --data "password=$ROOT_PASS" \
  | jq -r '.access_token')

if [ -z "$GITLAB_TOKEN" ] || [ "$GITLAB_TOKEN" == "null" ]; then
  echo "Authentication failed. Check your credentials."
  exit 1
fi

echo "GitLab authentication successful. Token: $GITLAB_TOKEN"

# Enable GitHub import capability
echo "Enabling GitHub import capability..."

curl -s --header "Authorization: Bearer $GITLAB_TOKEN" \
  --request PUT "$GITLAB_URL/api/v4/application/settings" \
  --data "import_sources[]=github" > /dev/null

echo "GitHub import capability enabled."

# Create user1
echo "Creating user1..."
CREATE_USER=$(curl -s --header "Authorization: Bearer $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --request POST "$GITLAB_URL/api/v4/users" \
  --data "$(cat <<EOF
{
  "email": "user1@example.com",
  "username": "user1",
  "name": "User One",
  "password": "$ROOT_PASS",
  "skip_confirmation": true
}
EOF
)")

USER_ID=$(echo "$CREATE_USER" | jq -r '.id')
if [ -z "$USER_ID" ] || [ "$USER_ID" == "null" ]; then
  echo "Failed to create user1. Response: $CREATE_USER"
  exit 1
fi

echo "User1 created successfully. User ID: $USER_ID"

# Import GitHub repositories
echo "Importing GitHub repository 1: $GITHUB_REPO_1"

# Retrieve repository details
GITHUB_REPO_API=$(echo "$GITHUB_REPO_1" | sed -E 's|https://github.com/||')
REPO_DETAILS=$(curl -s "https://api.github.com/repos/$GITHUB_REPO_API")

# Extract the numeric repository ID
REPO_ID=$(echo "$REPO_DETAILS" | jq -r '.id')

echo "Extracted Github repository ID: $REPO_ID"

IMPORT_REPO_1=$(curl -s --header "Authorization: Bearer $GITLAB_TOKEN" \
  --header "content-type: application/json" \
  --request POST "$GITLAB_URL/api/v4/import/github" \
  --data "$(cat <<EOF
{
  "personal_access_token": "$GITHUB_PAT",
  "repo_id": "$REPO_ID",
  "target_namespace": "user1",
  "new_name": "maju"
}
EOF
)")

# echo $IMPORT_REPO_1

# Import GitHub repositories
echo "Importing GitHub repository 2: $GITHUB_REPO_2"

# Retrieve repository details
GITHUB_REPO_API=$(echo "$GITHUB_REPO_2" | sed -E 's|https://github.com/||')
REPO_DETAILS=$(curl -s "https://api.github.com/repos/$GITHUB_REPO_API")

# Extract the numeric repository ID
REPO_ID=$(echo "$REPO_DETAILS" | jq -r '.id')

echo "Extracted Github repository ID: $REPO_ID"

IMPORT_REPO_2=$(curl -s --header "Authorization: Bearer $GITLAB_TOKEN" \
  --header "content-type: application/json" \
  --request POST "$GITLAB_URL/api/v4/import/github" \
  --data "$(cat <<EOF
{
  "personal_access_token": "$GITHUB_PAT",
  "repo_id": "$REPO_ID",
  "target_namespace": "user1",
  "new_name": "mana"
}
EOF
)")

echo "GitHub repositories imported successfully."