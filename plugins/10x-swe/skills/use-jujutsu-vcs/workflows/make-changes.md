# Workflow: Making Changes (Daily Development)

<required_reading>
**Read these reference files NOW:**
1. references/core-concepts.md
2. references/common-patterns.md
</required_reading>

<process>

## Step 1: Understand Current State

```bash
# View status (working copy changes)
jj st

# View commit graph
jj log

# Current commit diff
jj diff
```

The `@` symbol always refers to your current working-copy commit.

## Step 2: Choose Your Workflow

**Two main approaches:**

### Approach A: Simple Edit Workflow

Edit files directly, then describe when ready:

```bash
# 1. Edit files (changes auto-tracked)
# ... make your changes ...

# 2. Check what changed
jj diff

# 3. Describe your change
jj describe -m "Add user authentication"

# 4. Start next change
jj new
```

### Approach B: Squash Workflow (Recommended)

Create a described commit first, make incremental changes, squash when done:

```bash
# 1. Describe what you're about to do
jj describe -m "Add user authentication"

# 2. Create a new empty commit for editing
jj new

# 3. Make changes (auto-tracked in new commit)
# ... edit files ...

# 4. When satisfied, squash into parent
jj squash

# 5. Repeat for next logical unit
```

**Why squash workflow?**
- `jj diff` shows only recent changes (not everything)
- Easy to see what's "staged" vs "unstaged" conceptually
- Natural checkpoints for review

## Step 3: View Your Changes

```bash
# Working copy diff
jj diff

# Diff for specific commit
jj diff -r <change-id>

# Diff between two commits
jj diff --from <id1> --to <id2>

# Show specific commit content
jj show <change-id>
```

## Step 4: Edit Commit Messages

```bash
# Edit current commit message
jj describe

# Edit with inline message
jj describe -m "New message"

# Edit any commit's message
jj describe -r <change-id> -m "Updated message"
```

## Step 5: Create New Commits

```bash
# New empty commit on current
jj new

# New commit on specific parent
jj new <change-id>

# New commit with multiple parents (merge)
jj new <id1> <id2>

# New commit with message
jj new -m "Starting feature X"
```

## Step 6: Move Between Commits

```bash
# Edit a different commit (makes it the working copy)
jj edit <change-id>

# Create new commit based on another
jj new <change-id>
```

</process>

<no_staging_area>

**Key insight**: There's no staging area in jj.

In Git you do: `edit → git add → git commit`
In jj you do: `edit → jj describe` (or use squash workflow)

To selectively include changes:
- Use `jj split` to divide a commit
- Use `jj squash -i` for interactive selection
- Use `jj diffedit` to edit commit contents

</no_staging_area>

<file_tracking>

Files are auto-tracked by default. To manage tracking:

```bash
# Stop tracking a file
jj file untrack <path>

# Check what's tracked
jj file list

# Files matching .gitignore patterns are never auto-tracked
```

</file_tracking>

<anti_patterns>

Avoid:
- Running `jj commit` when you mean `jj new` (commit creates new commit AND moves to it)
- Forgetting to `jj describe` before moving on
- Leaving many undescribed commits in history

</anti_patterns>

<success_criteria>

A good change workflow:
- [ ] Each logical change has a descriptive message
- [ ] Working copy is clean or intentionally dirty
- [ ] `jj log` shows clear, understandable history
- [ ] No unnamed/empty commits left behind

</success_criteria>
