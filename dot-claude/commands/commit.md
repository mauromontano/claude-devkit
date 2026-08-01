---
description: Commit the current changes using the conventional commit format.
argument-hint: [optional context]
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*)
---

Create a commit for the current changes. Context: $ARGUMENTS

1. Run `git status` and `git diff` (staged and unstaged) to see everything that changed.
2. Group the changes logically. If the diff mixes unrelated topics (e.g. a refactor
   plus a feature), propose splitting into separate commits instead of one mixed one.
3. Write the message following the Conventional Commits block in the constitution:
   `<type>(<scope>): <imperative summary>`, body with the why.
4. Stage the right files and commit. Show the final message.
