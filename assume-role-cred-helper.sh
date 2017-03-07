#!/bin/bash
 
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN AWS_ACCESS_KEY AWS_SECRET_KEY AWS_DELEGATION_TOKEN
 
ROLE_ARN=""
SESSION_NAME="git@`hostname -s`"
 
CREDENTIALS_TRIPLE=(`aws sts assume-role --role-arn "$ROLE_ARN" \
                          --region us-east-1 \
                          --role-session-name "$SESSION_NAME" \
                          --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' \
                          --output text`)
 
export AWS_ACCESS_KEY_ID="${CREDENTIALS_TRIPLE[0]}"
export AWS_SECRET_ACCESS_KEY="${CREDENTIALS_TRIPLE[1]}"
export AWS_SESSION_TOKEN="${CREDENTIALS_TRIPLE[2]}"
 
aws codecommit credential-helper "$@"
