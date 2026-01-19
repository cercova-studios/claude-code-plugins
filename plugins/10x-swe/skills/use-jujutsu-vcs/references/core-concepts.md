<overview>
Core concepts that differentiate Jujutsu from Git and other VCS. Understanding these is essential for effective jj usage.
</overview>

<working_copy_is_a_commit>

**The working copy is always a commit in jj.**

In Git:
- Working directory is separate from commits
- Changes must be staged, then committed
- Working state can be "dirty" or "clean"

In jj:
- Working copy = the current commit (called `@`)
- Every file change automatically updates this commit
- Most jj commands snapshot working copy changes first

```bash
# When you run any jj command, it:
# 1. Snapshots current file changes into @ commit
# 2. Executes the command
# 3. Updates working copy to reflect new state
```

**Implication**: No staging area. No "git add". Your files are always in a commit.

</working_copy_is_a_commit>

<change_ids_vs_commit_ids>

Every commit has two identifiers:

**Change ID** (stable):
- Stays constant across rewrites
- Format: short alphabetic string (e.g., `kmstxplo`)
- Use this in daily workflow
- Survives rebases, amends, squashes

**Commit ID** (content-based):
- SHA-256 hash of commit contents
- Changes when commit is rewritten
- Similar to Git's commit SHA

```bash
# In jj log:
# ○  kmstxplo user@host 2024-01-15 10:00
# │  (empty) Description here
# │  commit_id: abc123def456...
```

**Why this matters**: You can refer to "the feature I'm working on" by change ID even after rebasing it multiple times.

</change_ids_vs_commit_ids>

<automatic_rebasing>

**When you edit any commit, all descendants automatically rebase.**

```
Before editing B:          After editing B:
A ← B ← C ← D             A ← B' ← C' ← D'
        ↑                         ↑
      (edit)                  (auto-rebased)
```

What happens:
- Change IDs remain the same (C's change ID unchanged)
- Commit IDs change (new hashes)
- Conflicts are recorded, not blocking
- Bookmarks follow their commits

**Implication**: Editing history is seamless. No need for interactive rebase to change old commits.

</automatic_rebasing>

<conflicts_are_first_class>

**Conflicts don't block operations—they're stored in commits.**

In Git:
- Merge conflict = operation halted
- Must resolve before continuing
- "Rebase in progress" state

In jj:
- Conflict recorded in commit data
- Operation completes successfully
- Resolve whenever convenient
- Descendant commits can rebase on conflicted commit

```bash
# After a conflicting rebase:
jj st
# Shows: C file.rs (conflict)

# The rebase succeeded. Resolve at your leisure.
jj resolve
```

**Implication**: No more "rebase in progress" limbo. Fix conflicts when ready.

</conflicts_are_first_class>

<operation_log>

**Every action is recorded in the operation log.**

```bash
jj op log

# Shows chronological list of operations:
# - Commits created
# - Rebases performed
# - Undos executed
# - Fetches and pushes
```

Features:
- Complete audit trail
- Any state recoverable
- Atomic operations
- Concurrent operation detection

**Implication**: Mistakes are always reversible. `jj undo` or `jj op restore` can fix anything.

</operation_log>

<bookmarks_vs_branches>

**Bookmarks are named pointers, similar to Git branches—but different.**

Key differences:
1. Bookmarks don't auto-advance when you create commits
2. No concept of "checked out" bookmark
3. Commits track their own identity (change ID), not bookmark position

```bash
# Create bookmark
jj bookmark create feature

# Make new commits
jj new -m "More work"

# Bookmark stays at original commit!
# Must manually move it:
jj bookmark move feature --to @-
```

**Implication**: Bookmarks are for sharing/collaboration. Day-to-day work uses change IDs.

</bookmarks_vs_branches>

<anonymous_heads>

**You can have multiple heads without named bookmarks.**

In Git:
- Detached HEAD is an unusual state
- Commits without branches can be "lost"

In jj:
- Anonymous heads are normal
- All visible commits are tracked
- Nothing gets garbage-collected unexpectedly

```bash
# Create divergent work without naming it:
jj new main -m "Experiment A"
# ... work ...
jj new main -m "Experiment B"
# ... work ...

# Both experiments are visible in log, no bookmarks needed
jj log
```

**Implication**: Don't need to name every branch. Great for experimentation.

</anonymous_heads>

<the_root_commit>

**Every jj repo has a virtual root commit.**

- Parent of all commits with no other parents
- Referenced as `root()` in revsets
- Eliminates "orphan branch" / "unborn branch" edge cases
- Common ancestor always exists

```bash
jj log -r 'root()'
# Shows the virtual root commit
```

</the_root_commit>

<revsets>

**Revsets are a query language for selecting commits.**

Basic patterns:
- `@` - Current working copy commit
- `@-` - Parent of working copy
- `@+` - Children of working copy
- `main` - Commit at bookmark "main"
- `main@origin` - Remote bookmark

Operators:
- `::x` - Ancestors of x (inclusive)
- `x::` - Descendants of x (inclusive)
- `x & y` - Intersection
- `x | y` - Union
- `~x` - Not x

Common patterns:
```bash
# Commits on current branch
main..@

# All unpushed commits
main@origin..

# Commits touching a file
file(path/to/file)
```

See `references/revsets.md` for complete guide.

</revsets>

<colocated_repositories>

**Colocated repos maintain both .jj and .git directories.**

```bash
# Initialize colocated
jj git init --colocate
# or
jj git clone --colocate <url>
```

Benefits:
- Git commands still work
- Gradual migration path
- Tooling compatibility (IDEs, CI)
- Easy to abandon jj if needed

Sync points:
- `jj git import` - Import Git changes into jj
- `jj git export` - Export jj changes to Git

Most jj operations auto-sync in colocated repos.

</colocated_repositories>

<decision_guidance>

**When to use which concept:**

| Scenario | Use |
|----------|-----|
| Referring to your work | Change ID |
| Sharing with others | Bookmark + push |
| Quick experiment | Anonymous head |
| History editing | `jj edit` + auto-rebase |
| Mistake recovery | `jj op log` + `jj undo` |
| Selecting commits | Revset expressions |

</decision_guidance>
