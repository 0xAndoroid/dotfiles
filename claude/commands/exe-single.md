# Task Execution [BRANCH_NAME] [PLAN_TO_EXECUTE_FILE]

## Variables
BRANCH_NAME: $ARGUMENTS
PLAN_TO_EXECUTE: $ARGUMENTS

## Run these commands top to bottom
READ: PLAN_TO_EXECUTE
RUN: cd trees/BRANCH_NAME/

## Instructions

You will implement the engineering plan detailed in PLAN_TO_EXECUTE in their respective workspace.

You will be working in the trees/BRANCH_NAME/ directory.

The code in trees/BRANCH_NAME/ will be identical to the code in the current branch. It will be setup and ready for you to build the feature end to end.

When you complete the work, report their final changes made in a comprehensive `RESULTS.md` file at the root of their respective workspace.

When running agents make sure they compile the code as little as possible. Make sure only specific tests are being run, not all tests.

Unless absolutely necessary, stick to pre-approved commands only, as using other commands requires manual confirmation of user.
