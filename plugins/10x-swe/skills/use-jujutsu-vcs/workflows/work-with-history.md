# Workflow: Working with History

<required_reading>
**Read these reference files NOW:**
1. references/core-concepts.md
2. references/revsets.md
</required_reading>

<process>

## Step 1: View History

```bash
# Default log (recent commits)
jj log

# Show more commits
jj log -r 'ancestors(@, 20)'

# Show all commits
jj log -r 'all()'

# Show specific bookmark/branch history
jj log -r 'ancestors(main, 10)'
```

## Step 2: Edit Any Commit

Unlike Git, you can directly edit any commit:

```bash
# Switch to editing a specific commit
jj edit <change-id>

# Make your changes
# ... edit files ...

# Changes are auto-applied to that commit
# All descendants automatically rebase!

# Return to tip
jj new
```

## Step 3: Squash Changes

Combine changes from one commit into another:

```bash
# Squash working copy into parent
jj squash

# Squash specific commit into its parent
jj squash -r <change-id>

# Interactive squash (select which changes)
jj squash -i

# Squash into a specific destination
jj squash --into <dest-id>
```

## Step 4: Split Commits

Divide a commit into multiple:

```bash
# Interactive split of current commit
jj split

# Split specific commit
jj split -r <change-id>

# Split by paths (non-interactive)
jj split -r <change-id> path/to/file1 path/to/file2
```

The split command opens an editor to select which changes go in the first commit. Remaining changes stay in a second commit.

## Step 5: Rebase

Move commits to different parents:

```bash
# Rebase current commit onto new parent
jj rebase -d <new-parent>

# Rebase specific commit
jj rebase -r <change-id> -d <new-parent>

# Rebase a range of commits
jj rebase -s <source> -d <destination>

# Rebase entire branch
jj rebase -b <bookmark> -d main
```

**Rebase flags:**
- `-r` (revision): Just this commit, leave descendants
- `-s` (source): This commit and all descendants
- `-b` (branch): All commits reachable from bookmark

## Step 6: Duplicate Commits

Copy commits (like cherry-pick):

```bash
# Duplicate a commit
jj duplicate <change-id>

# Duplicate multiple
jj duplicate <id1> <id2>

# Duplicate and rebase onto destination
jj duplicate <change-id> -d <destination>
```

## Step 7: Abandon Commits

Remove commits from history:

```bash
# Abandon current commit
jj abandon

# Abandon specific commit
jj abandon <change-id>

# Abandon multiple
jj abandon <id1> <id2>
```

Abandoned commits are removed from the visible graph but can be recovered via `jj op log`.

## Step 8: Edit Commit Contents Directly

```bash
# Open diffedit to modify commit contents
jj diffedit -r <change-id>

# This opens your diff editor to add/remove changes
```

</process>

<automatic_rebasing>

**Key feature**: When you edit a commit, all descendants automatically rebase.

```
Before editing B:         After editing B:
A ← B ← C ← D            A ← B' ← C' ← D'
```

- Change IDs stay the same (C's change ID is unchanged)
- Commit IDs change (C' has new hash)
- Conflicts in descendants are recorded, not blocking

</automatic_rebasing>

<revset_patterns>

Common selections for history operations:

```bash
# All commits between main and here
main::@

# Commits on current branch only
(main..@) | @

# All descendants of a commit
<change-id>::

# Parent of current
@-

# All commits by you
author(your.email)
```

</revset_patterns>

<anti_patterns>

Avoid:
- Editing commits that are already pushed (unless force-push is ok)
- Creating long chains without intermediate bookmarks
- Abandoning commits you might need (use `jj op log` to recover)
- Rebasing when you meant to merge

</anti_patterns>

<success_criteria>

History manipulation is successful when:
- [ ] Commit graph is clean and logical
- [ ] No unintended conflicts introduced
- [ ] Descendants properly rebased
- [ ] Original state recoverable via `jj op log`

</success_criteria>
