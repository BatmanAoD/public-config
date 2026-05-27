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

## Conditional

<important if="you are reading, querying, or interpreting timestamps or log output">
- My local time is mountain time (MT). Convert timestamps when querying logs.
- If a timestamp has no timezone info, ask before using it.
</important>

<important if="you are running CLI commands or shell commands">
- When piping to `tail` or any line-trimming command, use `| tee ~/tmp/<name>` to preserve full output.
- Prefer `rg`, `fd`, `jq` over `grep`, `find`, ad-hoc parsing.
</important>

<important if="you are writing, running, or modifying tests or fixing bugs">
- Follow TDD: write a failing test first (must compile, fail at runtime), then ask me to review before changing anything else.
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

<important if="you are using source control, making commits, diffing, or working with branches">
- I use `jj` (Jujutsu) — git is in headless mode. No visible `.git` in some repos.
- Use `jj` commands when known; `git` still works as fallback.
- Current branch: `jj b l -r @- -T 'name'`
- Diff: `jj diff --git --no-pager`
- For `cargo fix` / `cargo clippy --fix`: add `--allow-dirty` or `--allow-no-vcs`.
- Forge: check with `jj git remote list`. GitHub → `gh` CLI. GitLab → `glab` CLI.
- Auth error on `gh` or `glab`: ask me to re-authenticate.
</important>

<important if="you are working with GitLab CI, pipelines, or CI job logs">
- Debug locally: `glab ci config compile`
- View job logs: `glab ci trace ${job_id}`
</important>

<important if="you are writing a shell script intended for CI">
- Default image: `~kstrand/workspace/qcs-infrastructure/docker/cli-tools-base-image/Dockerfile`. Check it and `scripts/cli-tools-base-image/` for available commands.
- Rust CI image: `~kstrand/workspace/qcs-infrastructure/docker/rust-ci-image/Dockerfile` (superset of cli-tools-base-image).
</important>

<important if="you are investigating service behavior, traces, errors, or logs">
- Query traces via Honeycomb MCP. Auth failure → ask me to permit access.
- Query logs: `logcli --addr=https://loki.infra.rigetti.com`
</important>
