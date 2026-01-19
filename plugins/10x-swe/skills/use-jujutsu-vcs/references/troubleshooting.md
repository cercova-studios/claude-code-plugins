<overview>
Common problems and solutions when using jj. Start here when something goes wrong.
</overview>

<state_inspection>

**First step for any issue - inspect current state:**

```bash
# What's the working copy state?
jj st

# What does the commit graph look like?
jj log

# Any conflicts?
jj log -r 'conflict()'

# What operations happened recently?
jj op log
```

</state_inspection>

<common_issues>

<issue name="Lost my work">

**Symptoms**: Can't find commits, work seems gone

**Diagnosis:**
```bash
# Check operation log
jj op log

# View repo at previous operation
jj log --at-op <operation-id>
```

**Solutions:**
```bash
# Undo recent operation
jj undo

# Restore to specific operation
jj op restore <operation-id>

# Find abandoned commits
jj log --at-op <before-abandon> -r 'all()'
```

**Prevention**: Work is rarely truly lost. Check `jj op log` first.

</issue>

<issue name="Unexpected conflicts">

**Symptoms**: Files show conflict markers, `C` in status

**Diagnosis:**
```bash
# See conflicted files
jj st

# List all conflicts
jj resolve --list

# View conflict details
jj diff
```

**Solutions:**
```bash
# Resolve manually
# Edit files, remove markers, save

# Use merge tool
jj resolve

# If conflict came from bad rebase, undo
jj undo

# Accept one side completely
# Edit file to keep only one version
```

</issue>

<issue name="Bookmark not moving">

**Symptoms**: Bookmark stays at old commit after creating new commits

**Explanation**: jj bookmarks don't auto-advance like Git branches.

**Solution:**
```bash
# Move bookmark to current commit
jj bookmark move feature-name --to @

# Or to parent of working copy
jj bookmark move feature-name --to @-
```

**Prevention**: Remember bookmarks are manual. Move them explicitly.

</issue>

<issue name="Push rejected">

**Symptoms**: `jj git push` fails

**Common causes:**

1. **Remote changed since last fetch:**
```bash
jj git fetch
jj rebase -d main@origin
jj git push --bookmark <name>
```

2. **Bookmark doesn't exist on remote:**
```bash
jj git push --bookmark <name> --allow-new
```

3. **Conflicted bookmark:**
```bash
jj bookmark list  # Check for ??
jj bookmark move <name> --to <change-id>
jj git push --bookmark <name>
```

4. **Untracked remote bookmark:**
```bash
jj bookmark track <name>@origin
jj git fetch
jj git push --bookmark <name>
```

</issue>

<issue name="Colocated repo out of sync">

**Symptoms**: Git and jj show different states

**Diagnosis:**
```bash
git status
jj st
# Compare outputs
```

**Solutions:**
```bash
# Import Git changes into jj
jj git import

# Export jj changes to Git
jj git export

# Full sync
jj git import && jj git export
```

**Prevention**: Stick to jj commands. Only use Git when necessary.

</issue>

<issue name="Working copy shows as empty">

**Symptoms**: `jj st` shows no changes but files were edited

**Possible causes:**

1. **Files not tracked (gitignored):**
```bash
cat .gitignore  # Check patterns
jj file list  # See what's tracked
```

2. **Snapshot not taken yet:**
```bash
jj st  # This triggers snapshot
```

3. **Working in wrong directory:**
```bash
pwd
jj workspace root  # Check repo root
```

</issue>

<issue name="Can't find commit by change ID">

**Symptoms**: `jj show <change-id>` says not found

**Diagnosis:**
```bash
# Check if commit was abandoned
jj op log  # Look for abandon operations

# Search in historical operations
jj log --at-op <older-operation> -r '<change-id>'
```

**Solutions:**
```bash
# Restore from operation that had it
jj op restore <operation-with-commit>

# Or duplicate from history
jj duplicate <change-id> --at-op <operation>
```

</issue>

<issue name="Rebase created mess">

**Symptoms**: Multiple conflicts, wrong parent, confusing history

**Solutions:**
```bash
# Simple: Undo the rebase
jj undo

# Or restore to pre-rebase state
jj op log  # Find operation before rebase
jj op restore <pre-rebase-operation>
```

**Prevention**: Before complex rebases, note the operation ID.

</issue>

<issue name="Descendants not rebased">

**Symptoms**: After editing commit, descendants still on old version

**This shouldn't happen** - jj auto-rebases. But if it does:

```bash
# Check current state
jj log

# Manual rebase if needed
jj rebase -s <descendant> -d <edited-commit>
```

**If using colocated repo**, ensure jj operations completed.

</issue>

<issue name="jj commands hanging">

**Symptoms**: Commands take very long or don't complete

**Possible causes:**

1. **Large repository, first operation:**
   - Initial analysis takes time, wait it out

2. **Network issues (fetch/push):**
   - Check connectivity
   - Try with verbose: `jj git fetch -v`

3. **Disk issues:**
   - Check `.jj/` directory permissions
   - Ensure disk isn't full

4. **Workspace corruption:**
   ```bash
   # Try rebuilding operation log
   jj op log  # See if this hangs

   # In colocated repo, try via Git
   git status
   ```

</issue>

</common_issues>

<recovery_techniques>

<technique name="Operation log recovery">

The operation log is your primary recovery tool:

```bash
# View all operations
jj op log

# Inspect state at any operation
jj log --at-op <op-id>
jj st --at-op <op-id>
jj diff --at-op <op-id>

# Restore completely to that state
jj op restore <op-id>

# Or just revert one operation's effects
jj op revert <op-id>
```

</technique>

<technique name="Finding lost commits">

```bash
# List all operations
jj op log

# For each suspicious operation, check what existed
jj log --at-op <op-id> -r 'all()'

# Search for specific content
jj log --at-op <op-id> -r 'description("keyword")'
jj log --at-op <op-id> -r 'diff_contains("code snippet")'
```

</technique>

<technique name="Nuclear option - start fresh">

If everything is confused in a colocated repo:

```bash
# Remove jj, keep Git
rm -rf .jj

# Reinitialize
jj git init --colocate

# Your Git history is preserved
# jj will rebuild its state from Git
```

**Only use as last resort.**

</technique>

</recovery_techniques>

<error_messages>

| Error | Meaning | Solution |
|-------|---------|----------|
| "No such revision" | Change ID not found | Check spelling, use `jj log` |
| "Revision is ambiguous" | Multiple matches | Use longer prefix |
| "Working copy is stale" | Concurrent operation | `jj workspace update-stale` |
| "Cannot rebase onto descendant" | Invalid rebase target | Choose different destination |
| "Bookmark is conflicted" | Local/remote diverged | `jj bookmark move` to resolve |
| "Remote bookmark not tracked" | Push safety check | `jj bookmark track` or `--allow-new` |

</error_messages>

<getting_help>

```bash
# Command help
jj help <command>
jj <command> --help

# All commands
jj help

# Online documentation
# https://docs.jj-vcs.dev/latest/
```

**Community resources:**
- GitHub issues: https://github.com/jj-vcs/jj/issues
- Discord: linked from GitHub

</getting_help>

<prevention_tips>

1. **Check state frequently**: `jj st` and `jj log` are cheap
2. **Note operation IDs before risky operations**
3. **Use descriptive commit messages**: Easier to find later
4. **Keep bookmarks current**: Move after adding commits
5. **Fetch before push**: Avoid conflicts
6. **Trust the operation log**: Your safety net

</prevention_tips>
