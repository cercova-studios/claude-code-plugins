<overview>
Revsets are jj's query language for selecting commits. Most commands accept revset expressions via the `-r` flag. Master revsets for powerful commit selection.
</overview>

<basic_symbols>

**Special references:**

| Symbol | Meaning |
|--------|---------|
| `@` | Current working copy commit |
| `root()` | Virtual root commit (ancestor of all) |

**Commit identifiers:**

| Type | Example | Notes |
|------|---------|-------|
| Change ID | `kmstxplo` | Unique prefix sufficient |
| Commit ID | `abc123def` | SHA prefix |
| Bookmark | `main` | Name resolves to commit |
| Remote bookmark | `main@origin` | Remote tracking ref |
| Tag | `v1.0.0` | Tag name |

</basic_symbols>

<navigation_operators>

**Parent/child navigation:**

| Operator | Meaning | Example |
|----------|---------|---------|
| `x-` | Parents of x | `@-` (parent of working copy) |
| `x+` | Children of x | `main+` (children of main) |
| `x-n` | n-th ancestor | `@-3` (great-grandparent) |

**Multiple parents:** `x--` returns all parents (for merge commits).

</navigation_operators>

<ancestry_operators>

**Ancestors and descendants:**

| Operator | Meaning |
|----------|---------|
| `::x` | x and all ancestors |
| `x::` | x and all descendants |
| `x::y` | Commits between x and y (inclusive) |
| `x..y` | Same as `x::y` |

**Examples:**
```bash
# All history up to main
::main

# All commits descending from feature
feature::

# Commits between main and current
main::@
```

</ancestry_operators>

<set_operators>

**Combining sets:**

| Operator | Meaning |
|----------|---------|
| `x \| y` | Union (x or y) |
| `x & y` | Intersection (x and y) |
| `x ~ y` | Difference (x but not y) |
| `~x` | Complement (everything except x) |

**Precedence** (highest to lowest):
1. `~` (prefix negation)
2. `&` (intersection)
3. `|` (union)
4. `~` (difference)

Use parentheses for clarity: `(x | y) & z`

</set_operators>

<common_functions>

**Commit navigation:**

| Function | Purpose |
|----------|---------|
| `parents(x)` | Direct parents |
| `children(x)` | Direct children |
| `ancestors(x)` | Same as `::x` |
| `ancestors(x, n)` | Ancestors up to depth n |
| `descendants(x)` | Same as `x::` |
| `heads(x)` | Commits with no descendants in x |
| `roots(x)` | Commits with no ancestors in x |

**Bookmark/ref functions:**

| Function | Purpose |
|----------|---------|
| `bookmarks()` | All local bookmarks |
| `bookmarks(pattern)` | Bookmarks matching pattern |
| `remote_bookmarks()` | All remote bookmarks |
| `remote_bookmarks(pattern)` | Remote bookmarks matching pattern |
| `tags()` | All tags |
| `trunk()` | Main branch (main/master/trunk) |

**Search functions:**

| Function | Purpose |
|----------|---------|
| `author(pattern)` | Commits by author |
| `committer(pattern)` | Commits by committer |
| `description(pattern)` | Commits with matching description |
| `file(path)` | Commits touching path |
| `diff_contains(pattern)` | Commits with matching diff content |

**State functions:**

| Function | Purpose |
|----------|---------|
| `empty()` | Empty commits |
| `conflict()` | Commits with conflicts |
| `hidden()` | Hidden/obsolete commits |
| `mine()` | Your commits |
| `present(x)` | x if it exists, empty otherwise |

</common_functions>

<pattern_matching>

**String patterns for search functions:**

| Syntax | Meaning |
|--------|---------|
| `"string"` | Substring match |
| `exact:"string"` | Exact match |
| `glob:"pattern"` | Shell glob (*, ?) |
| `regex:"pattern"` | Regular expression |

**Case insensitive:** Add `-i` suffix: `regex-i:"pattern"`

**Examples:**
```bash
# Author containing "alice"
author("alice")

# Description starting with "fix"
description(glob:"fix*")

# File path matching pattern
file(glob:"src/**/*.rs")

# Regex in description
description(regex:"(bug|fix).*#[0-9]+")
```

</pattern_matching>

<practical_examples>

**Daily workflows:**

```bash
# Your recent commits
ancestors(@, 10) & mine()

# Commits not yet pushed
main@origin..@

# Feature branch commits
(trunk()..@) | @

# Commits touching specific file
file("src/main.rs")

# Merge commits
merges()

# Non-empty commits
~empty()
```

**Branch analysis:**

```bash
# Commits only on feature, not main
feature ~ ::main

# Common ancestor of two branches
roots(::feature & ::other)

# Commits on both branches
::feature & ::other

# Tips of all bookmarks
heads(bookmarks())
```

**Finding commits:**

```bash
# By author and date
author("alice") & committer_date(after:"2024-01-01")

# With specific text in message
description("refactor") & ~empty()

# Touching multiple files
file("src/lib.rs") & file("tests/")

# Containing string in diff
diff_contains("TODO")
```

**History cleanup:**

```bash
# Empty commits to consider abandoning
empty() & mine() & ~merges()

# Conflicted commits needing resolution
conflict() & descendants(@)

# Commits without descriptions
description(exact:"") & ~root()
```

</practical_examples>

<revset_aliases>

**Define aliases in config:**

```toml
# ~/.config/jj/config.toml
[revset-aliases]
"mine()" = "author(your.email@example.com)"
"wip()" = "description(glob:\"wip*\") | description(exact:\"\")"
"stale()" = "ancestors(@, 20) & empty() & mine()"
"feature()" = "trunk()..@"
```

Use like built-in functions:
```bash
jj log -r 'mine() & ~empty()'
```

</revset_aliases>

<default_revsets>

**Configure default log revset:**

```toml
# ~/.config/jj/config.toml
[revsets]
log = "@ | ancestors(immutable_heads().., 2) | trunk()"
```

This shows your working copy, recent mutable commits, and trunk.

</default_revsets>

<tips>

1. **Start simple**: Use `@`, `@-`, bookmark names first
2. **Build incrementally**: Test parts before combining
3. **Use `jj log -r`** to verify selections before operations
4. **Parenthesize** when combining operators
5. **Create aliases** for frequently used patterns

</tips>

<anti_patterns>

Avoid:
- Very complex single-line revsets (break into aliases)
- Forgetting quotes around patterns with spaces
- Using commit IDs when change IDs work (less stable)
- Ignoring `present()` when commit might not exist

</anti_patterns>
