#!/bin/bash

# Variables
GITLAB_URL="https://gitlab.apps.cluster-vvnkz.vvnkz.gcp.redhatworkshops.io"
ROOT_USER="root"
ROOT_PASS="ag0xvp5B2I9ltyvFXbAUFOmNNMtXwOcf9LSkIfxLSWIOSAX3dulTx1QVOWT9HRDP"
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

# Create a new application for keycloak integration
KEYCLOAK_APPLICATION_NAME="keycloak"
KEYCLOAK_REDIRECT_URI="https://keycloak.apps.cluster-4hxrj.4hxrj.gcp.redhatworkshops.io"
SCOPES="openid api read_api"

echo "Creating a new application in GitLab..."
#APPLICATION_RESPONSE=$(curl -s --request POST "$GITLAB_URL/api/v4/applications" \
#  --header "Authorization: Bearer $GITLAB_TOKEN" \
#  --data "name=$APPLICATION_NAME" \
#  --data "redirect_uri=$REDIRECT_URI" \
#  --data "scopes=$SCOPES")
APPLICATION_RESPONSE=$(curl -s --request POST "$GITLAB_URL/api/v4/applications" \
  --header "Authorization: Bearer $GITLAB_TOKEN" \
  --data "name=$KEYCLOAK_APPLICATION_NAME" \
  --data "redirect_uri=$KEYCLOAK_REDIRECT_URI" \
  --data "scopes=$SCOPES" \
  --data "confidential=false")

APPLICATION_ID=$(echo $APPLICATION_RESPONSE | jq -r '.id')

# Extract the client_id and client_secret using Python
CLIENT_ID=$(echo "$APPLICATION_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['application_id'])")
CLIENT_SECRET=$(echo "$APPLICATION_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['secret'])")

if [ -z "$APPLICATION_ID" ] || [ "$APPLICATION_ID" == "null" ]; then
  echo "Failed to create the application. Response: $APPLICATION_RESPONSE"
  exit 1
fi

echo "Application created successfully. ID: $APPLICATION_ID"
echo "Application Client ID: $CLIENT_ID"
echo "Application Client Secret: $CLIENT_SECRET"

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