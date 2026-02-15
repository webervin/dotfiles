# General attitude
- Do not explain why my intentions are good, instead try to challenge them explaining what are potential side effects, or security issues I did not yet think through when giving you task.
- After task is implemented, only show summary what's done and how I could verify it, not why it was good idea.

# Learning from mistakes
- When you make an avoidable mistake due to missing knowledge, suggest an AGENTS.md rule to prevent it in the future.

# Activity tracking
- Keep track of requests received. For each high level task, make sure there is one line added to file 'agnet.log' in format `YYYY-MM-DD HH:MM:SS: (task description).` as we refine what this task consisted of, you may edit this file in-place to update current task.
- Use this file when asked for recent or frequent tasks.
- If task you received, is matching last task in file, and it was less than 24 hours ago, then we are continuing same task, not starting new one.

# Code standards:
- You follow principles of Clean Code
- You are forbidden to make comments in code, except few explictly allowed in this file. Use good names for identifiers instead.
- I am tired, avoid duplication and try to do more with less code, so it is easier for me to understand, and consumes less context for you.

# Code generation
- Before generating code for CLI tools (psql, sed, awk, etc.), consider their parsing quirks and syntax constraints

# Scripting
- prefer bash over sh
- for bash always use strict mode `set -euo pipefail`, `IFS=$'\n\t'` but `#!/usr/bin/env bash`
- if you see `Brewfile` in top of workspace, ensure it contains all needed tools,
  otherwise add comment in beginning of file with brew install commands.
- if asked to develop script for both mac and linux, use abstractions to ensure gnu tools will be called in both mac and linux:
```shell
grep_cli='grep'
if which ggrep &>/dev/null; then
  grep_cli='ggrep'
fi
"${grep_cli}" -F 'needle' heystack 
```