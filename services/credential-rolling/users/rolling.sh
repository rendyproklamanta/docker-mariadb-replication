#!/bin/bash

# Variables
DB_USER="${DB_USER}"
DB_PREFIX="${DB_PREFIX}"
DB_HOST="${DB_HOST}"
PMA_URL="${PMA_URL}"
IP_ADDRESS="${IP_ADDRESS}"
SUPER_PASSWORD="${SUPER_PASSWORD_FILE}"
SUPER_USER="${SUPER_USER}"
PASSWORD=$(openssl rand -base64 12)  # Generate a random password

GITLAB_TOKEN="${GITLAB_TOKEN}"
GITLAB_PROJECT_ID="${GITLAB_PROJECT_ID}"
GITLAB_API_URL="${GITLAB_API_URL}/api/v4/snippets"
GITLAB_SNIPPET_TITLE="Database Credential"

# Change the user password or create user if not exists
mysql -u$SUPER_USER -p"${SUPER_PASSWORD}" -h $DB_HOST <<EOF
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$PASSWORD';
GRANT ALL PRIVILEGES ON ${DB_PREFIX}_* TO '$DB_USER'@'%';
ALTER USER '$DB_USER'@'%' IDENTIFIED BY '$PASSWORD';
EOF

# Prepare the content for the snippet
CONTENT="User : $DB_USER\nPass : $PASSWORD\n\nIP : $IP_ADDRESS\nPort : 6033\nPMA : $PMA_URL"

# Fetch existing snippets and delete the one with the matching title
EXISTING_SNIPPET_ID=$(curl --silent --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_API_URL?project_id=$GITLAB_PROJECT_ID" | jq --arg title "$GITLAB_SNIPPET_TITLE" '.[] | select(.title == $title) | .id')

if [ -n "$EXISTING_SNIPPET_ID" ]; then
  echo "Deleting existing snippet with ID: $EXISTING_SNIPPET_ID"
  curl --request DELETE "$GITLAB_API_URL/$EXISTING_SNIPPET_ID" --header "PRIVATE-TOKEN: $GITLAB_TOKEN"
fi

# Create a new snippet in GitLab
curl --request POST "$GITLAB_API_URL" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --form "title=$GITLAB_SNIPPET_TITLE" \
  --form "content=$CONTENT" \
  --form "visibility=private" \
  --form "project_id=$GITLAB_PROJECT_ID"

# Optionally, log the new password to a file (ensure this file is secured)
echo -e "New password for $DB_USER:\n$CONTENT" >> /var/log/secrets.log
