<overview>
Translation table from Git commands to Jujutsu equivalents. Use this when migrating from Git or when you know the Git command but not the jj equivalent.
</overview>

<repository_setup>

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git init` | `jj git init` | Add `--colocate` for Git compatibility |
| `git clone <url>` | `jj git clone <url>` | Add `--colocate` for Git compatibility |
| `git remote add <n> <url>` | `jj git remote add <n> <url>` | Same pattern |
| `git remote -v` | `jj git remote list` | |
| `git fetch` | `jj git fetch` | |
| `git pull` | `jj git fetch` + `jj rebase -d main@origin` | No direct pull command |
| `git push` | `jj git push` | Requires bookmark |

</repository_setup>

<viewing_state>

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git status` | `jj st` | |
| `git diff` | `jj diff` | Shows working copy diff |
| `git diff --staged` | N/A | No staging area in jj |
| `git diff HEAD` | `jj diff` | Same effect |
| `git diff <commit>` | `jj diff -r <change-id>` | |
| `git log` | `jj log` | Graph view by default |
| `git log --oneline` | `jj log` | Already compact |
| `git log -p` | `jj log -p` | Shows diffs |
| `git show <commit>` | `jj show <change-id>` | |
| `git blame <file>` | `jj file annotate <file>` | Added in v0.24 |

</viewing_state>

<making_changes>

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git add <file>` | N/A | Auto-tracked, no staging |
| `git add -p` | `jj split` or `jj squash -i` | Different workflow |
| `git commit` | `jj commit` | Creates commit AND starts new one |
| `git commit -m "msg"` | `jj commit -m "msg"` | Or `jj describe -m "msg"` + `jj new` |
| `git commit --amend` | `jj squash` | Squash working copy into parent |
| `git commit --amend -m` | `jj describe -m "msg"` | Just change message |
| `touch <file>` | `touch <file>` | File auto-tracked |
| `git rm <file>` | `rm <file>` | File auto-untracked |
| `git mv <old> <new>` | `mv <old> <new>` | Auto-detected |

</making_changes>

<branching_and_bookmarks>

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git branch` | `jj bookmark list` | |
| `git branch <name>` | `jj bookmark create <name>` | |
| `git branch -d <name>` | `jj bookmark delete <name>` | |
| `git checkout <branch>` | `jj new <bookmark>` | Creates new commit on bookmark |
| `git checkout -b <name>` | `jj new` + `jj bookmark create <name>` | |
| `git switch <branch>` | `jj new <bookmark>` | |
| `git merge <branch>` | `jj new <head1> <head2>` | Creates merge commit |

</branching_and_bookmarks>

<history_manipulation>

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git rebase <onto>` | `jj rebase -d <onto>` | |
| `git rebase -i` | `jj squash`, `jj split`, `jj edit` | Different approach |
| `git cherry-pick <c>` | `jj duplicate <c>` | |
| `git revert <commit>` | `jj backout -r <change-id>` | Creates reverting commit |
| `git reset --hard` | `jj abandon` | Abandons current commit |
| `git reset --soft HEAD~1` | `jj squash` | Moves changes to parent |
| `git stash` | `jj new @-` | Start new commit on parent |
| `git stash pop` | `jj squash` | Squash back into parent |

</history_manipulation>

<undoing_changes>

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git checkout -- <file>` | `jj restore <file>` | |
| `git reset HEAD <file>` | N/A | No staging area |
| `git reflog` | `jj op log` | Operation log |
| `git reset --hard <ref>` | `jj op restore <op-id>` | Restore to operation |
| N/A | `jj undo` | Undo last operation |

</undoing_changes>

<file_operations>

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git ls-files` | `jj file list` | |
| `git rm --cached <f>` | `jj file untrack <f>` | |
| `.gitignore` | `.gitignore` | Same file, same format |

</file_operations>

<remote_operations>

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git fetch origin` | `jj git fetch --remote origin` | |
| `git push origin <b>` | `jj git push --bookmark <b>` | |
| `git push -u origin <b>` | `jj git push --bookmark <b> --allow-new` | |
| `git push --force` | `jj git push --bookmark <b>` | Auto force-with-lease |
| `git push --delete <b>` | `jj git push --delete <b>` | |
| `git branch -r` | `jj bookmark list --all-remotes` | |
| `git branch --track` | `jj bookmark track <b>@<remote>` | |

</remote_operations>

<no_direct_equivalent>

**jj commands without Git equivalent:**

| Jujutsu | Purpose |
|---------|---------|
| `jj edit <change-id>` | Make any commit the working copy |
| `jj describe` | Edit commit message without amend |
| `jj op log` | View all operations |
| `jj undo` | Undo any operation |
| `jj op restore` | Restore to specific operation |
| `jj diffedit` | Edit commit contents interactively |
| `jj split` | Split commit into multiple |
| `jj workspace` | Multiple working copies |

</no_direct_equivalent>

<workflow_translation>

**Git workflow → jj equivalent:**

**Feature branch workflow:**
```bash
# Git:
git checkout -b feature
git add . && git commit -m "Work"
git push -u origin feature

# jj:
jj new main -m "Work"
jj bookmark create feature
jj git push --bookmark feature --allow-new
```

**Amending last commit:**
```bash
# Git:
git add . && git commit --amend

# jj:
# Changes already in working copy commit
jj squash  # If you want to combine with parent
# Or just keep editing, it's already a commit
```

**Interactive rebase to edit old commit:**
```bash
# Git:
git rebase -i HEAD~3
# Mark commit as "edit"
# Make changes
git add . && git commit --amend
git rebase --continue

# jj:
jj edit <change-id>
# Make changes (auto-saved)
jj new  # Return to tip
# Descendants auto-rebased!
```

**Stashing work:**
```bash
# Git:
git stash
# Do other work
git stash pop

# jj:
jj new @-  # Start fresh commit on parent
# Do other work
jj edit <original-change-id>  # Go back to original
# Or: jj squash to combine if desired
```

</workflow_translation>

<mental_model_shift>

**Key mindset changes from Git:**

1. **No staging** - Files are always committed, use squash/split for partial commits
2. **No checkout** - Use `jj new` or `jj edit` to change working copy
3. **No detached HEAD fear** - Anonymous heads are normal and safe
4. **No rebase --continue** - Conflicts recorded, not blocking
5. **Change IDs, not SHAs** - Use the stable identifier
6. **Bookmarks are optional** - Only needed for sharing

</mental_model_shift>
