# update_stack

## Overview

This simple script allows you to update a running CloudFormation stack by specifying only the parameters to be updated on the command line.

## Usage

```text
▶ bash update_stack.sh -h
Usage: update_stack.sh [-h] STACK_NAME KEY1=VAL1 [KEY2=VAL2 ...]
Updates CloudFormation stacks based on parameters passed here as key=value pairs. All other parameters are based on existing values.
```

## Development

Run the tests:

```text
▶ make
```
