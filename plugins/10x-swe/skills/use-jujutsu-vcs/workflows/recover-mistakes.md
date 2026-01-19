# Workflow: Recovering from Mistakes

<required_reading>
**Read these reference files NOW:**
1. references/core-concepts.md
2. references/troubleshooting.md
</required_reading>

<process>

## Step 1: Understand the Operation Log

Every jj operation is recorded:

```bash
# View operation history
jj op log

# Output shows:
# @  abc123 user@host 2024-01-15 10:30:00
# │  new commit
# ○  def456 user@host 2024-01-15 10:29:00
# │  describe commit
# ...
```

Each operation has an ID you can reference.

## Step 2: Simple Undo

Reverse the most recent operation:

```bash
# Undo last operation
jj undo

# Undo is itself an operation, so you can:
jj undo  # Undo the undo (redo)
```

Multiple undos:
```bash
jj undo  # Undo once
jj undo  # Undo again
# etc.
```

## Step 3: View State at Any Operation

Inspect without modifying:

```bash
# View log as it was after specific operation
jj log --at-op <op-id>

# View status at that point
jj st --at-op <op-id>

# Compare current to historical state
jj diff --at-op <op-id>
```

## Step 4: Restore to Specific Operation

Go back to an exact historical state:

```bash
# Restore entire repo to state after specific operation
jj op restore <op-id>

# This creates a NEW operation that restores that state
# Previous operations still exist for further recovery
```

## Step 5: Revert Specific Operation

Undo just one operation (not necessarily the latest):

```bash
# Revert a specific operation's effects
jj op revert <op-id>
```

**Difference from restore:**
- `restore`: Sets repo to exact state at that operation
- `revert`: Undoes just that operation's changes, keeping later work

## Step 6: Recover Abandoned Commits

Commits are never truly deleted:

```bash
# Find the operation where commit existed
jj op log

# Look for "abandon" operations or before

# View what commits existed at that operation
jj log --at-op <op-id>

# Restore to recover them
jj op restore <op-id>

# Or duplicate the specific commit from history
jj duplicate <change-id> --at-op <op-id>
```

## Step 7: Fix a Bad Rebase

```bash
# Find operation before the rebase
jj op log
# Look for "rebase" operation

# Restore to just before that operation
jj op restore <op-id-before-rebase>

# Or undo if it was recent
jj undo
```

## Step 8: Recover from Conflict Mess

If conflicts got out of hand:

```bash
# Find clean state
jj op log
# Look for last operation before conflicts

# Restore
jj op restore <op-id>

# Try again with different approach
```

</process>

<safety_net>

**The operation log is your safety net:**

1. Every action is recorded (commits, rebases, undos, etc.)
2. Nothing is permanently deleted
3. You can always go back
4. Operations are atomic

This makes jj extremely safe for experimentation.

</safety_net>

<common_recovery_scenarios>

**"I accidentally abandoned my work"**
```bash
jj op log  # Find abandon operation
jj undo    # If recent
# or
jj op restore <op-before-abandon>
```

**"My rebase made a mess"**
```bash
jj undo  # Simple case
# or
jj op restore <op-before-rebase>
```

**"I edited the wrong commit"**
```bash
jj undo  # Reverses the edit
# Then edit the correct one
jj edit <correct-change-id>
```

**"I lost track of a commit"**
```bash
# View all operations
jj op log

# Find when you last saw it
jj log --at-op <op-id>

# The change ID is stable, search for it
jj log -r '<change-id>' --at-op <op-id>
```

**"I want to try something risky"**
```bash
# Note current operation
jj op log  # Remember the top ID

# Do risky thing
jj <risky-operation>

# If it failed
jj op restore <saved-op-id>
```

</common_recovery_scenarios>

<operation_log_maintenance>

The operation log grows over time. jj automatically handles cleanup, but you can also:

```bash
# View operation log stats
jj op log | wc -l

# The log is pruned of very old operations automatically
# No manual maintenance typically needed
```

</operation_log_maintenance>

<anti_patterns>

Avoid:
- Panicking before checking `jj op log`
- Manually editing `.jj/` directory
- Assuming work is lost (it rarely is)
- Not using `--at-op` to inspect before restoring

</anti_patterns>

<success_criteria>

Recovery is successful when:
- [ ] Desired state restored
- [ ] No work lost
- [ ] Operation log shows recovery operation
- [ ] Working copy is in expected state

</success_criteria>
