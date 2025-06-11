# Initialize parallel git worktree directories [FEATURE_NAME] [NUMBER_OF_PARALLEL_WORKTREES]

## Variables
FEATURE_NAME: $ARGUMENTS
NUMBER_OF_PARALLEL_WORKTREES: $ARGUMENTS

## Execute these commands
> Execute the loop in parallel with the Batch and Task tool

- create a new dir `trees/`
- for i in NUMBER_OF_PARALLEL_WORKTREES
  - BRANCH_NAME = IF NUMBER_OF_PARALLEL_WORKTREES == 1 THEN FEATURE_NAME ELSE FEATURE_NAME-i
  - RUN `git worktree add -b BRANCH_NAME ./trees/BRANCH_NAME`
  - RUN `cd trees/BRANCH_NAME`, `git ls-files` to validate
- RUN `git worktree list` to verify all trees were created properly
