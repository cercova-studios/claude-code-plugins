# Workflow: Getting Started with Jujutsu

<required_reading>
**Read these reference files NOW:**
1. references/core-concepts.md
2. references/git-command-mapping.md
</required_reading>

<process>

## Step 1: Verify Installation

```bash
# Check if jj is installed
jj --version

# If not installed:
# macOS: brew install jj
# Linux: cargo install --locked jj-cli
# Or download from: https://github.com/jj-vcs/jj/releases
```

## Step 2: Configure Identity

```bash
# Set your name and email (used for commits)
jj config set --user user.name "Your Name"
jj config set --user user.email "your.email@example.com"
```

## Step 3: Initialize or Clone

**Option A: Clone a Git repository**
```bash
# Standard clone (jj-native storage)
jj git clone https://github.com/user/repo.git

# Colocated clone (keeps .git for Git compatibility)
jj git clone --colocate https://github.com/user/repo.git
```

**Option B: Initialize in existing Git repo**
```bash
cd /path/to/git-repo

# Colocated mode (recommended for Git compatibility)
jj git init --colocate

# Non-colocated (jj-only)
jj git init
```

**Option C: Start fresh**
```bash
mkdir my-project && cd my-project
jj git init
```

## Step 4: Understand the Initial State

After init/clone, you have an empty working-copy commit:

```bash
# View status
jj st

# View log (shows commit graph)
jj log
```

The working copy (`@`) is always a commit. It starts empty, sitting on top of the default bookmark (usually `main`).

## Step 5: Configure Shell Completions (Optional)

```bash
# Bash
source <(jj util completion bash)

# Zsh (add to .zshrc)
source <(jj util completion zsh)

# Fish
jj util completion fish | source
```

## Step 6: Set Up Git Compatibility (If Colocated)

For colocated repos, ensure `.gitignore` includes jj's directory:

```bash
echo ".jj/" >> .gitignore
```

</process>

<colocated_vs_native>

**Colocated Mode** (`--colocate`):
- Maintains `.git` directory alongside `.jj`
- Git commands continue to work
- Best for gradual migration or team environments
- Use `jj git import` if you make changes with Git

**Native Mode** (no `--colocate`):
- Only `.jj` directory exists
- Smaller storage footprint
- Still pushes/pulls to Git remotes
- Full jj experience

**Recommendation**: Start with colocated mode for safety.

</colocated_vs_native>

<anti_patterns>

Avoid:
- Forgetting to set user.name/user.email (commits will have empty author)
- Mixing Git and jj commands without `jj git import` in colocated mode
- Editing `.jj/` directory contents manually

</anti_patterns>

<success_criteria>

Setup is complete when:
- [ ] `jj --version` shows installed version
- [ ] `jj config list` shows user.name and user.email
- [ ] `jj st` runs without errors
- [ ] `jj log` shows the commit graph
- [ ] Shell completions work (optional but recommended)

</success_criteria>
