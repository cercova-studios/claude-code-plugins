# Workflow: Collaborating with GitHub

<required_reading>
**Read these reference files NOW:**
1. references/bookmarks.md
2. references/common-patterns.md
</required_reading>

<process>

## Step 1: Set Up Remote

```bash
# View configured remotes
jj git remote list

# Add a remote
jj git remote add origin https://github.com/user/repo.git

# For SSH
jj git remote add origin git@github.com:user/repo.git
```

## Step 2: Fetch Latest Changes

```bash
# Fetch from default remote
jj git fetch

# Fetch from specific remote
jj git fetch --remote origin

# Fetch all remotes
jj git fetch --all-remotes
```

**Note**: jj has no direct `pull` command. Fetch + rebase is the pattern:

```bash
jj git fetch
jj rebase -d main@origin
```

## Step 3: Create a Feature Bookmark

Bookmarks are jj's equivalent to Git branches:

```bash
# Create bookmark at current commit
jj bookmark create feature-name

# Create bookmark at specific commit
jj bookmark create feature-name -r <change-id>

# List bookmarks
jj bookmark list
```

## Step 4: Push Changes

```bash
# Push specific bookmark
jj git push --bookmark feature-name

# Push current bookmark
jj git push

# Push and create new remote bookmark
jj git push --bookmark feature-name --allow-new

# Push with auto-generated bookmark name
jj git push -c @  # Creates bookmark from change ID
```

## Step 5: Create Pull Request

After pushing:

```bash
# Using GitHub CLI
gh pr create --title "Feature: Add X" --body "Description"

# Or use GitHub web interface
# Navigate to: https://github.com/user/repo/pull/new/feature-name
```

## Step 6: Update PR with New Changes

**Option A: Add commits (preserves history)**

```bash
# Make changes
# ... edit files ...

# Create new commit
jj new -m "Address review feedback"

# Move bookmark forward
jj bookmark move feature-name --to @-

# Push
jj git push --bookmark feature-name
```

**Option B: Amend existing commit (rewrites history)**

```bash
# Edit the original commit
jj edit <change-id>

# Make changes
# ... edit files ...

# Changes are auto-committed to that commit

# Force push (bookmark auto-followed the rewrite)
jj git push --bookmark feature-name
```

## Step 7: Sync with Main Branch

```bash
# Fetch latest
jj git fetch

# Rebase your feature onto updated main
jj rebase -b feature-name -d main@origin

# Resolve any conflicts (see resolve-conflicts workflow)
```

## Step 8: After PR Merge

```bash
# Fetch to get merged state
jj git fetch

# Clean up local bookmark
jj bookmark delete feature-name

# Start fresh for next feature
jj new main@origin -m "Next feature"
```

</process>

<multiple_remotes>

For fork-based workflow:

```bash
# Add upstream
jj git remote add upstream https://github.com/original/repo.git

# Configure default fetch/push
# In .jj/repo/config.toml:
[git]
fetch = ["upstream", "origin"]
push = "origin"

# Sync with upstream
jj git fetch --remote upstream
jj rebase -d main@upstream
jj git push --bookmark main
```

</multiple_remotes>

<bookmark_management>

```bash
# Track a remote bookmark locally
jj bookmark track feature-name@origin

# Stop tracking
jj bookmark untrack feature-name@origin

# Move bookmark to different commit
jj bookmark move feature-name --to <change-id>

# Delete remote bookmark
jj git push --delete feature-name
```

**Important**: Unlike Git, bookmarks don't auto-advance when you create new commits. You must explicitly move them.

</bookmark_management>

<stacked_prs>

For stacked/dependent PRs:

```bash
# Create base feature
jj new main -m "Feature A"
jj bookmark create feature-a
# ... make changes ...

# Create dependent feature
jj new -m "Feature B (depends on A)"
jj bookmark create feature-b
# ... make changes ...

# Push both
jj git push --bookmark feature-a --allow-new
jj git push --bookmark feature-b --allow-new

# Create PRs: feature-a → main, feature-b → feature-a
```

When feature-a is merged:
```bash
jj git fetch
jj rebase -b feature-b -d main@origin
jj git push --bookmark feature-b
# Update PR base to main
```

</stacked_prs>

<anti_patterns>

Avoid:
- Pushing without a bookmark (creates detached commits on remote)
- Forgetting to move bookmark after adding commits
- Force-pushing to shared/protected branches
- Not fetching before rebasing onto remote

</anti_patterns>

<success_criteria>

Collaboration workflow is successful when:
- [ ] Changes pushed to correct remote/bookmark
- [ ] PR created and reviewable
- [ ] Updates pushed cleanly
- [ ] Local state synced after merge

</success_criteria>
