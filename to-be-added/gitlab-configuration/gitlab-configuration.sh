#!/bin/bash

# Variables
GITLAB_URL="https://gitlab.apps.cluster-vp7mj.vp7mj.gcp.redhatworkshops.io"
ROOT_USER="root"
ROOT_PASS="fZrEMvDqlEp14CE3ipMUbL3vBnMBOjDnHd4j9502KWJAfpXACVNHgahPWqWdNtBK"
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
  --data "import_sources[]=github"

echo "GitHub import capability enabled."

echo "GitHub import capability enabled."

# Import GitHub repositories
echo "Importing GitHub repository 1: $GITHUB_REPO_1"
IMPORT_REPO_1=$(curl -s --header "Authorization: Bearer $GITLAB_TOKEN" \
  --header "content-type: application/json" \
  --request POST "$GITLAB_URL/api/v4/import/github" \
  --data '{
    "new_name": "importtest",
    "github_hostname": "https://github.example.com"
}')

exit 1

# https://docs.gitlab.com/ee/api/import.html 

curl --request POST \
  --url "https://gitlab.example.com/api/v4/import/github" \
  --header "content-type: application/json" \
  --header "Authorization: Bearer <your_access_token>" \
  --data '{
    "personal_access_token": "aBc123abC12aBc123abC12abC123+_A/c123",
    "repo_id": "12345",
    "target_namespace": "group/subgroup",
    "new_name": "NEW-NAME",
    "github_hostname": "https://github.example.com",
    "optional_stages": {
      "single_endpoint_notes_import": true,
      "attachments_import": true,
      "collaborators_import": true
    }
}'


if echo "$IMPORT_REPO_1" | grep -q '"message":"403 Forbidden"'; then
  echo "Failed to import GitHub repository 1. Response: $IMPORT_REPO_1"
  exit 1
fi

echo "Importing GitHub repository 2: $GITHUB_REPO_2"
IMPORT_REPO_2=$(curl -s --header "Authorization: Bearer $GITLAB_TOKEN" \
  --request POST "$GITLAB_URL/api/v4/projects" \
  --data "name=$(basename $GITHUB_REPO_2 .git)" \
  --data "import_url=$GITHUB_REPO_2")

if echo "$IMPORT_REPO_2" | grep -q '"message":"403 Forbidden"'; then
  echo "Failed to import GitHub repository 2. Response: $IMPORT_REPO_2"
  exit 1
fi

echo "GitHub repositories imported successfully."