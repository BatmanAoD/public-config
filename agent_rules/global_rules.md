# CLAUDE.md

## Communication style

Terse like caveman. Technical substance exact. Only fluff die.
Drop: articles, filler (just/really/basically), pleasantries, hedging.
Fragments OK. Short synonyms. Code unchanged.
Pattern: [thing] [action] [reason]. [next step].
ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
Code/commits/PRs: normal. Off: "stop caveman" / "normal mode".

## Always applies

- If request seems non-idiomatic or non-standard, ask before proceeding. Suggest alternatives but don't implement without approval.
- Unexpected workspace changes: DO NOT undo without asking — even if contrary to a previous request.
- Projects live at `~/workspace/<project-name>`. If I name a crate/project, check there first.
- Express confusion when uncertain. State confidence level. For hard problems, consider multiple answers.
- TDD: write a failing test first (must compile, fail at runtime), then ask me to review before changing anything else.
- Private/work-specific rules (same authority as this file): @~/private-config/agents/rigetti.md

### Source control

- I use `jj` (Jujutsu) — git is in headless mode. No visible `.git` in some repos.
- Use `jj` commands when known; `git` still works as fallback.
- Do not make new commits unless I request that.
- Current branch: `jj b l -r @- -T 'name'`
- Diff: `jj diff --git --no-pager`
- For `cargo fix` / `cargo clippy --fix`: add `--allow-dirty` or `--allow-no-vcs`.
- Forge: check with `jj git remote list`. GitHub → `gh` CLI. GitLab → `glab` CLI.
- Auth error on `gh` or `glab`: ask me to re-authenticate.
- Prefer higher-level `gh`/`glab` subcommands (e.g. `glab mr diff 1234` to view MR 1234 of the active project) over `gh api`/`glab api` where possible.

<important if="you are creating a commit with jj">
- Scope it: `jj commit <paths>`. An unscoped commit takes the whole working copy,
  including edits I made while you were working. Run `jj st` first and check the
  file list is only what you changed.
- `jj new` and `jj commit` auto-advance the bookmark here; no separate move step.
</important>

## Tool selection

Before writing a one-off script or using a generic tool, check these overrides:
- **Any `gitlab.com` URL** → use `glab`, not URL-fetching tools. Job logs: `glab ci trace ${job_id}`. Debug CI locally: `glab ci config compile`.
- **Text/file search in shell** → `rg` not `grep`; `fd` not `find`; `jq` for JSON parsing.
- **Text search-and-replace in shell** → `fastmod --accept-all <regex> <subst> [paths]`
- **Service traces** → Honeycomb MCP (auth failure → ask me to permit access).
- **Logs / metrics / profiles** → Grafana Cloud via `gcx`. Details in `~/private-config/agents/rigetti.md`.

<important if="you are reading or modifying a file">
- Use the text editor tool (Read / Edit / Write) for all file reads and edits, not shell equivalents.
  - No `cat`/`head`/`sed -n` to read. No `sed -i`/`awk`/heredoc/`>` redirect to write.
  - Read before Edit. Edit for partial change, Write only for new file or full replace.
- Exceptions: bulk regex replace across many files (`fastmod`), search (`rg`/`fd`), inspecting non-text/huge output.
- Overrides any session instruction preferring Bash for file access.
</important>

## Conditional

<important if="you are reading, querying, or interpreting timestamps or log output">
- My local time is mountain time (MT). Convert timestamps when querying logs.
- If a timestamp has no timezone info, ask before using it.
</important>

<important if="you are running CLI commands or shell commands">
- When piping to `tail` or any line-trimming command, use `| tee ~/tmp/<name>` to preserve full output.
</important>

<important if="you are working in a Rust project or running Cargo commands">
- Check for `Makefile.toml` in repo root first. If present, run `cargo make --list-all-steps` to find the right recipe.
- Use `cargo nextest run` instead of `cargo test`.
- If Cargo SSO error, ask me to re-authenticate.
- After any changes, run `cargo fmt`.
</important>

<important if="you are working with Terraform or updating provider/module lockfiles">
- Use `terraform init -upgrade -backend=false` to upgrade lockfiles.
</important>

<important if="you are modifying CI configuration">
- Validate changes with `glab ci lint`.
</important>

<important if="you are writing a shell script intended for CI">
- Default image: `~kstrand/workspace/qcs-infrastructure/docker/cli-tools-base-image/Dockerfile`. Check it and `scripts/cli-tools-base-image/` for available commands.
- Rust CI image: `~kstrand/workspace/qcs-infrastructure/docker/rust-ci-image/Dockerfile` (superset of cli-tools-base-image).
</important>


