#!/usr/bin/env bash

readonly PARAMS='/tmp/parameters.json'

usage() {
  echo "Usage: $0 [-h] STACK_NAME \
KEY1=VAL1 [KEY2=VAL2 ...]"
  echo "Updates CloudFormation stacks based on parameters \
passed here as key=value pairs. All other parameters are \
based on existing values."
  exit 1
}

edit() {
  local key=$1
  local value=$2
  jq --arg key "$key" \
     --arg value "$value" \
    '(.[] | select(.ParameterKey==$key)
    | .ParameterValue) |= $value' \
    "$PARAMS" > x ; mv x "$PARAMS"
}

{ [ "$1" == "-h" ] || [ -z "$2" ]; } && usage

stack_name=$1 ; shift

aws cloudformation describe-stacks \
  --stack-name "$stack_name" \
  --query 'Stacks[].Parameters[]' > $PARAMS

for data in "$@" ; do
  IFS='=' read -r key value <<< "$data"
  edit "$key" "$value" "$PARAMS"
done

aws cloudformation update-stack \
  --stack-name "$stack_name" \
  --use-previous-template \
  --parameters "file://$PARAMS"
