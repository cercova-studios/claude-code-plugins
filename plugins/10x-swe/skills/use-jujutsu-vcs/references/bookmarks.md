<overview>
Bookmarks are jj's named pointers to commits, analogous to Git branches. They're primarily used for collaboration and sharing work via remotes.
</overview>

<bookmark_basics>

**What bookmarks are:**
- Named references to specific commits
- Used for pushing/pulling with Git remotes
- Map directly to Git branches when interacting with Git

**What bookmarks are NOT:**
- Required for daily work (anonymous heads work fine)
- Auto-advancing (unlike Git's HEAD behavior)
- A record of what you're "checked out" to

</bookmark_basics>

<creating_bookmarks>

```bash
# Create at current commit
jj bookmark create feature-name

# Create at specific commit
jj bookmark create feature-name -r <change-id>

# Shorthand
jj b c feature-name
```

</creating_bookmarks>

<listing_bookmarks>

```bash
# List local bookmarks
jj bookmark list

# List all (including remote)
jj bookmark list --all-remotes

# Show where bookmarks point
jj log -r 'bookmarks()'
```

**Output format:**
```
feature-name: kmstxplo 2024-01-15 Description
main: rstuqxyz 2024-01-10 Initial commit
main@origin: rstuqxyz 2024-01-10 Initial commit
```

</listing_bookmarks>

<moving_bookmarks>

**Important**: Bookmarks don't auto-advance. Move them explicitly:

```bash
# Move to current commit
jj bookmark move feature-name --to @

# Move to specific commit
jj bookmark move feature-name --to <change-id>

# Move to parent
jj bookmark move feature-name --to @-
```

**Common pattern after adding commits:**
```bash
jj new -m "More work"
# ... make changes ...
jj bookmark move feature-name --to @-  # Point to new commit
```

</moving_bookmarks>

<deleting_bookmarks>

```bash
# Delete local bookmark
jj bookmark delete feature-name

# Delete multiple
jj bookmark delete feature-a feature-b

# Delete remote bookmark (via push)
jj git push --delete feature-name
```

</deleting_bookmarks>

<remote_bookmarks>

**Remote bookmarks track state on remotes:**

```bash
# Notation: <bookmark>@<remote>
main@origin      # main as it exists on origin
feature@upstream # feature as it exists on upstream
```

**Tracking behavior:**
- Tracked remote bookmarks update local bookmarks on fetch
- Untracked remote bookmarks are visible but don't affect local

```bash
# Track a remote bookmark
jj bookmark track feature@origin

# Stop tracking
jj bookmark untrack feature@origin

# List tracking status
jj bookmark list --tracked
```

</remote_bookmarks>

<pushing_bookmarks>

```bash
# Push specific bookmark
jj git push --bookmark feature-name

# Push new bookmark (first time)
jj git push --bookmark feature-name --allow-new

# Push to specific remote
jj git push --bookmark feature-name --remote upstream

# Push multiple bookmarks
jj git push --bookmark feature-a --bookmark feature-b
```

**Auto-generated bookmark names:**

```bash
# Push current commit with auto-generated bookmark
jj git push -c @

# Creates bookmark like "push-kmstxplo" from change ID
```

</pushing_bookmarks>

<bookmark_conflicts>

Bookmarks can conflict when:
- Local and remote diverge
- Concurrent edits from different machines

**Detecting conflicts:**
```bash
jj bookmark list
# Shows: feature-name?? (conflicted)

jj log -r 'feature-name'
# Shows multiple commits
```

**Resolving conflicts:**
```bash
# Move bookmark to desired commit
jj bookmark move feature-name --to <change-id>

# Or delete and recreate
jj bookmark delete feature-name
jj bookmark create feature-name -r <change-id>
```

</bookmark_conflicts>

<automatic_bookmark_updates>

Bookmarks follow commits when they're rewritten:

```bash
# feature-name points to A
jj edit A
# ... make changes to A, creating A' ...

# feature-name now points to A' automatically
```

When commits are abandoned:
- Bookmarks pointing to abandoned commits are deleted
- Remote bookmarks are NOT auto-deleted

</automatic_bookmark_updates>

<push_safety>

jj implements safety checks before pushing:

1. **Lease check**: Remote must match last-known state (like `--force-with-lease`)
2. **Conflict check**: Can't push conflicted bookmarks
3. **Tracking check**: Existing remote bookmarks must be tracked

```bash
# If push is rejected, fetch first:
jj git fetch
# Resolve any conflicts
jj git push --bookmark feature-name
```

</push_safety>

<bookmark_vs_anonymous>

**When to use bookmarks:**

| Scenario | Use Bookmark? |
|----------|---------------|
| Pushing to remote | Yes |
| Creating PR | Yes |
| Local experiment | No (anonymous head) |
| Quick fix then squash | No |
| Collaborating with team | Yes |
| Personal backup | Optional |

**Anonymous heads are fine for:**
- Local work-in-progress
- Experiments you might abandon
- Short-lived changes

</bookmark_vs_anonymous>

<common_patterns>

**Feature branch workflow:**
```bash
# Start feature
jj new main -m "Feature: Add X"
jj bookmark create feature-x

# Work on feature
# ... make changes ...
jj new -m "More work"
jj bookmark move feature-x --to @-

# Push for review
jj git push --bookmark feature-x --allow-new
```

**Sync with upstream:**
```bash
# Fetch latest
jj git fetch

# Rebase feature onto updated main
jj rebase -b feature-x -d main@origin

# Push updated feature
jj git push --bookmark feature-x
```

**After PR merge:**
```bash
jj git fetch
jj bookmark delete feature-x
```

</common_patterns>

<configuration>

```toml
# ~/.config/jj/config.toml

# Default remote for push/fetch
[git]
fetch = "origin"
push = "origin"

# Auto-track new remote bookmarks
[git.auto-local-bookmark]
all = true

# Or selective tracking
[git.auto-local-bookmark]
glob = ["main", "develop", "release-*"]
```

</configuration>

<tips>

1. **Don't over-use bookmarks** - Anonymous heads are fine for local work
2. **Move bookmarks explicitly** - They don't auto-advance
3. **Use tracking** - Makes fetch/push smoother
4. **Resolve conflicts early** - Before they compound
5. **Delete after merge** - Keep bookmark list clean

</tips>
