#!/usr/bin/env bash
source .config.sh

delete_user() {
  local user_id=$1
  local project=$2

  api_key=${project}_API_KEY
  secret_key=${project}_SECRET_KEY
  log_file=response_${project}.log

  echo "Delete user '${user_id}' on ${project}..."
  http_response=$(curl -s -o "${log_file}" -w "%{http_code}" -X POST https://amplitude.com/api/2/deletions/users \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -u "${!api_key}:${!secret_key}" \
    -d '{"user_ids": ["'"${user_id}"'"], "requester": "'"${REQUESTER_EMAIL}"'", "ignore_invalid_id": "False"}')
  if [[ ${http_response} -eq 200 ]]
  then
    echo "HTTP 200 - Success - Looks all good!"
    cat "${log_file}" | json_pp
  else
    echo "HTTP 400 - Bad request - User not found?"
  fi
  echo "...request finished."
}

if [[ $# -eq 1 ]]
then
  echo "Requesting to delete a user from Amplitude on behalf of '${REQUESTER_EMAIL}'."
  echo "Please check the output below for sanity (at least some deletion jobs should be scheduled):"
  delete_user "$@" "STAGING"
  delete_user "$@" "PRODUCTION"
  exit 0
else
  echo "Usage: ./user_deletion.sh <user_id>"
fi
exit 1
