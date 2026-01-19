# Workflow: Resolving Conflicts

<required_reading>
**Read these reference files NOW:**
1. references/core-concepts.md
2. references/troubleshooting.md
</required_reading>

<process>

## Step 1: Understand Conflict State

In jj, conflicts don't block operations. They're recorded in commits:

```bash
# Check for conflicts
jj st

# Shows something like:
# Working copy changes:
# C path/to/file.rs
#   (conflict)
```

The `C` marker indicates a conflicted file.

## Step 2: View Conflict Details

```bash
# See what's conflicted
jj diff

# Show conflict in specific commit
jj show <change-id>

# List all conflicted files
jj resolve --list
```

## Step 3: Understand Conflict Markers

jj uses a different marker format than Git:

```
<<<<<<< Conflict 1 of 1
+++++++ Contents of side #1
First version content
%%%%%%% Changes from base to side #2
-Base content
+Second version content
>>>>>>> Conflict 1 of 1 ends
```

**Marker meanings:**
- `+++++++`: Complete content from one side (snapshot)
- `%%%%%%%`: Diff showing changes from base to other side
- Apply the diff to the snapshot to understand both sides

## Step 4: Resolve Conflicts

**Option A: Manual resolution**

Edit the file directly, replacing conflict markers with desired content:

```bash
# Edit the conflicted file
# Remove markers, keep what you want
# Save the file

# Verify resolution
jj st
jj diff
```

**Option B: Use jj resolve**

```bash
# Opens merge tool for each conflicted file
jj resolve

# Resolve specific file
jj resolve path/to/file.rs
```

**Option C: Accept one side**

```bash
# In the file, delete the markers and keep one side's content
# Or use diffedit for more control
jj diffedit
```

## Step 5: Verify Resolution

```bash
# Check no conflicts remain
jj st

# Should NOT show 'C' markers anymore

# View the resolved state
jj diff
```

## Step 6: Handle Descendant Conflicts

When you resolve a conflict, descendants may auto-resolve:

```bash
# After resolving in commit B:
jj st  # Check B is clean
jj new  # Move forward

# Descendants that only touched different files
# will automatically rebase without conflicts
```

If descendants still have conflicts, resolve them the same way.

## Step 7: Partial Resolution

You can partially resolve conflicts:

```bash
# Resolve only some hunks in a file
# Edit the file, fix what you can
# Leave remaining markers for later

# The file remains marked as conflicted
# but progress is saved
```

</process>

<conflict_format>

jj offers multiple conflict marker styles:

```bash
# Default (diff + snapshot)
# Shows one side completely, other as diff

# Snapshot style
jj config set --repo ui.conflict-marker-style "snapshot"
# Shows all sides as complete snapshots

# Git diff3 style
jj config set --repo ui.conflict-marker-style "diff3"
# Traditional base/ours/theirs markers
```

</conflict_format>

<multi_sided_conflicts>

jj handles conflicts with more than 2 sides (e.g., octopus merges):

```
<<<<<<< Conflict 1 of 1
+++++++ Contents of side #1
Version A
%%%%%%% Changes from base to side #2
 Version B changes
%%%%%%% Changes from base to side #3
 Version C changes
>>>>>>> Conflict 1 of 1 ends
```

Apply each diff section to the snapshot sequentially to understand all versions.

</multi_sided_conflicts>

<merge_tools>

Configure external merge tools:

```toml
# In ~/.config/jj/config.toml

[ui]
merge-editor = "vimdiff"  # or "code --wait", "meld", etc.

# Or more detailed config:
[merge-tools.meld]
program = "meld"
merge-args = ["$left", "$base", "$right", "-o", "$output"]
```

</merge_tools>

<anti_patterns>

Avoid:
- Ignoring conflicts and moving on (they'll compound)
- Deleting files instead of resolving
- Not verifying all markers are removed
- Force-pushing conflicted commits to shared branches

</anti_patterns>

<success_criteria>

Conflict resolution is complete when:
- [ ] `jj st` shows no `C` markers
- [ ] All conflict markers removed from files
- [ ] Code compiles/works as expected
- [ ] Descendant commits properly rebased

</success_criteria>
