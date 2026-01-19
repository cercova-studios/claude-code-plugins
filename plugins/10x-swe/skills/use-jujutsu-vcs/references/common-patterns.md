<overview>
Common workflows and patterns for effective jj usage. These patterns leverage jj's unique features for maximum productivity.
</overview>

<squash_workflow>

**The recommended daily workflow:**

```bash
# 1. Describe what you're about to do
jj describe -m "Add user authentication"

# 2. Create a new working commit
jj new

# 3. Make changes (auto-tracked)
# ... edit files ...

# 4. Check your work
jj diff          # What changed
jj diff -r @-    # What's in the described commit

# 5. Squash into described commit when ready
jj squash

# 6. Repeat for next logical unit
```

**Why this works:**
- `jj diff` shows only recent changes (not entire feature)
- Natural checkpoints for review
- Easy to see "staged" (parent) vs "unstaged" (working copy)
- Squash is the "commit" action

</squash_workflow>

<checkpoint_pattern>

**Save work-in-progress frequently:**

```bash
# Working on something complex
# ... make some changes ...

# Create checkpoint
jj new -m "WIP: checkpoint"

# Continue working
# ... more changes ...

# Another checkpoint
jj new -m "WIP: another checkpoint"

# When done, squash all WIP commits together
jj squash --from <first-wip> --into <feature-commit>
```

</checkpoint_pattern>

<edit_old_commit>

**Directly modify historical commits:**

```bash
# Find the commit to edit
jj log

# Edit it (makes it the working copy)
jj edit <change-id>

# Make changes
# ... edit files ...

# Return to where you were
jj new <original-working-copy>

# Descendants automatically rebased!
```

**Note**: No need for interactive rebase. Just edit directly.

</edit_old_commit>

<split_pattern>

**Break up commits that got too big:**

```bash
# Option 1: Interactive split
jj split -r <change-id>
# Opens editor to select which changes go in first commit

# Option 2: Split by files
jj split -r <change-id> path/to/file1 path/to/file2

# Option 3: Split from working copy
jj split  # Split current commit
```

**Useful when:**
- Commit mixes unrelated changes
- Need to reorder changes
- Want to extract a fix for separate PR

</split_pattern>

<parallel_features>

**Work on multiple things simultaneously:**

```bash
# Start from main
jj new main -m "Feature A"
# ... work on A ...

# Start another feature (from main, not A)
jj new main -m "Feature B"
# ... work on B ...

# Both are visible as anonymous heads
jj log

# Switch between them
jj edit <change-id-of-A>
jj edit <change-id-of-B>
```

**No need to name them until pushing.**

</parallel_features>

<stash_equivalent>

**"Stash" work to do something else:**

```bash
# Option 1: New commit on parent
jj new @-  # Start fresh on parent
# ... do urgent work ...
jj edit <original-change-id>  # Go back

# Option 2: Just start new work
jj new  # Leave current work as a commit
# ... do other work ...
jj edit <previous-work>  # Return

# Option 3: Squash if you want to combine
jj squash --from <temp-work> --into <original>
```

</stash_equivalent>

<fixup_pattern>

**Apply fixes to earlier commits:**

```bash
# Make fix in working copy
# ... fix the bug ...

# Move fix to the commit that introduced the bug
jj squash --into <buggy-commit-change-id>

# Descendants automatically rebase with the fix
```

**No need for `git commit --fixup` + `git rebase --autosquash`.**

</fixup_pattern>

<rebase_onto_updated_main>

**Keep feature branches up to date:**

```bash
# Fetch latest
jj git fetch

# Rebase your work onto updated main
jj rebase -d main@origin

# If you have a bookmark
jj rebase -b feature-name -d main@origin
```

**Resolve conflicts inline - no "rebase in progress" state.**

</rebase_onto_updated_main>

<safe_experimentation>

**Try risky operations safely:**

```bash
# Note current operation
jj op log  # Remember the top operation ID

# Do something risky
jj rebase -d <somewhere>  # or any operation

# If it went wrong
jj op restore <saved-operation-id>

# Or simply
jj undo
```

**Everything is reversible via operation log.**

</safe_experimentation>

<merge_workflow>

**Create merge commits:**

```bash
# Merge two branches
jj new feature-a feature-b -m "Merge feature-a and feature-b"

# Merge into main
jj new main feature-x -m "Merge feature-x into main"
jj bookmark move main --to @
```

</merge_workflow>

<cherry_pick_pattern>

**Copy commits between branches:**

```bash
# Duplicate a commit
jj duplicate <change-id>

# Duplicate onto specific parent
jj duplicate <change-id> -d main

# Duplicate multiple commits
jj duplicate <id1> <id2> <id3>
```

**Note**: Duplicate creates new commits with new change IDs.

</cherry_pick_pattern>

<review_changes>

**Before pushing, review all changes:**

```bash
# See all commits in your branch
jj log -r 'main@origin..@'

# See combined diff
jj diff -r main@origin

# See each commit's diff
jj log -r 'main@origin..@' -p
```

</review_changes>

<cleanup_history>

**Clean up before sharing:**

```bash
# Find empty commits
jj log -r 'empty() & mine()'

# Abandon them
jj abandon <empty-change-ids>

# Squash WIP commits
jj squash -r <wip-commit> --into <target>

# Improve commit messages
jj describe -r <change-id> -m "Better message"
```

</cleanup_history>

<multiple_workspaces>

**Work on different commits in different directories:**

```bash
# Create additional workspace
jj workspace add ../project-test

# In that workspace, check out a different commit
cd ../project-test
jj edit <test-commit>

# Run tests while continuing development in original

# List workspaces
jj workspace list

# Remove workspace when done
jj workspace forget project-test
```

</multiple_workspaces>

<handling_colocated_git>

**When using colocated repository:**

```bash
# If you made Git changes, import them
jj git import

# If jj and Git diverged
jj git import
jj git export  # Sync back to Git

# Check sync status
git status  # Compare with
jj st
```

**Tip**: Stick to jj commands. Only use Git when tools require it.

</handling_colocated_git>

<configuration_patterns>

**Useful config settings:**

```toml
# ~/.config/jj/config.toml

[user]
name = "Your Name"
email = "your.email@example.com"

[ui]
# Pager like Git
pager = "less -FRX"

# Editor for commit messages
editor = "code --wait"

# Diff format
diff.format = "git"

[revset-aliases]
# Custom revsets
"wip()" = "description(exact:\"\") & mine()"
"feature()" = "trunk()..@"

[aliases]
# Command shortcuts
st = ["status"]
ci = ["commit"]
br = ["bookmark"]
```

</configuration_patterns>

<ai_agent_tips>

**For AI agents using jj:**

1. **Always check state first**: `jj st` and `jj log` before operations
2. **Use change IDs**: They're stable across rebases
3. **Prefer squash workflow**: Creates clean history
4. **Check for conflicts**: `jj st` shows them clearly
5. **Use operation log**: `jj op log` for debugging
6. **Undo mistakes immediately**: `jj undo` is your friend
7. **Don't fear history editing**: Auto-rebase makes it safe

</ai_agent_tips>
