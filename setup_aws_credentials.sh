#!/usr/bin/env bash

set -e

# expects AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_ROLE_ARN, AWS_ROLE_SESSION_NAME, AWS_SESSION_DURATION_SECONDS and TEMP_AWS_PROFILE to be previously setup in env vars
if [ -z "$AWS_ACCESS_KEY_ID" ] || \
   [ -z "$AWS_SECRET_ACCESS_KEY" ] || \
   [ -z "$AWS_ROLE_ARN" ] || \
   [ -z "$AWS_ROLE_SESSION_NAME" ] || \
   [ -z "$AWS_SESSION_DURATION_SECONDS" ] || \
   [ -z "$TEMP_AWS_PROFILE" ]; then
    echo "AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_ROLE_ARN, AWS_ROLE_SESSION_NAME, AWS_SESSION_DURATION_SECONDS and TEMP_AWS_PROFILE must be set"
    exit 1
fi


# KST will be an array
KST=($(aws sts assume-role --role-arn "$AWS_ROLE_ARN" \
        --role-session-name "$AWS_ROLE_SESSION_NAME" \
        --duration-seconds $AWS_SESSION_DURATION_SECONDS \
        --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' \
        --output text))

aws configure set aws_region $AWS_REGION --profile $TEMP_AWS_PROFILE
aws configure set aws_access_key_id "${KST[0]}" --profile $TEMP_AWS_PROFILE
aws configure set aws_secret_access_key "${KST[1]}" --profile $TEMP_AWS_PROFILE
aws configure set aws_session_token "${KST[2]}" --profile $TEMP_AWS_PROFILE

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
