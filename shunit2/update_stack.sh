#!/usr/bin/env bash

script_under_test=$(basename $0)

tearDown() {
  rm -f commands_log expected_log
}

aws() {
  echo "${FUNCNAME[0]} $*" >> commands_log
  case "${FUNCNAME[0]} $*" in
    'aws cloudformation describe-stacks --stack-name MyStack --query Stacks[].Parameters[]') cat shunit2/fixtures/parameters.json.before ;;
    'aws cloudformation update-stack --stack-name MyStack --use-previous-template --parameters file:///tmp/parameters.json') true ;;
    *)
      echo "No responses for: ${FUNCNAME[0]} $*"
    ;;
  esac
}

testUsage() {
  assertTrue "did not see usage message" ". $script_under_test -h | grep -qi usage"
}

testIncorrectInvocation() {
  assertTrue "did not see usage message" ". $script_under_test foo | grep -qi usage"
}

testIt() {
  . $script_under_test MyStack VpcId=vpc-bbb SubnetId=subnet-bbb
  assertEquals "unexpected parameters file generated" \
    "" "$(diff -wu shunit2/fixtures/parameters.json.after /tmp/parameters.json)"

  cat > expected_log <<EOF
aws cloudformation describe-stacks --stack-name MyStack --query Stacks[].Parameters[]
aws cloudformation update-stack --stack-name MyStack --use-previous-template --parameters file:///tmp/parameters.json
EOF

  assertEquals "unexpected sequence of commands issued" \
    "" "$(diff -wu expected_log commands_log)"
}

. shunit2
