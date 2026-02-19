# General

1. If a request seems non-idiomatic or non-standard, please ask me about it before proceeding. You may suggest alternatives, but do not implement them without my approval.
2. I often come back to a session after having made changes to the codebase. This can even include abandoning commits that I've decided are no longer the correct direction. If there are unexpected changes, DO NOT undo them without asking, even if they are contrary to a previous request.
3. My local time is usually mountain time. Be sure to do timezone conversions when appropriate, for instance when querying logs. If you see a timestamp and it does not include timezone information, please ask what timezone it is in before using it.
4. Try to follow test-driven development: before fixing a problem or adding a feature, write a test that demonstrates the problem or exercises the feature. This test should compile, but fail at runtime. Once a test is written, ask me to review it before making any further changes.
5. In general, expressing confusion is good! Try to be clear about how confident you are in your answers. For difficult problems, also try considering multiple possible answers.

# Running CLI commands

1. Working directories for most projects are in the form of `~/workspace/<project-name>`. Check here 
2. Whenever you pipe the output of a command to a command such as `tail` or `grep` that eliminates lines from the output, use `|tee` to save the original output to a file in `~/tmp/` so that you can refer to it later rather than re-running the command.

## Rust repositories

1. Before running a `Cargo` command, check if there is a `Makefile.toml` in the repository root. If so, use `cargo make --list-all-steps` to see whether there is a `cargo make` recipe that should be run instead.
2. When running tests without `cargo make`, always use `cargo nextest run` rather than `cargo test`.
3. Several repositories use a private `cargo` registry. If you see a `cargo` error about SSO having expired, ask me to re-authenticate.
4. After making any changes in a Rust project, run `cargo fmt`.

## Terraform

1. Use `terraform init -upgrade -backend=false` to upgrade lockfiles in a Terraform project.

## Source control

1. I use `jj` for most of my repositories. This puts git in "headless mode". In some repos, there is no visible `.git` directory at all. Consequently:
   a. If you use `cargo fix` or `cargo clippy --fix`, you will need the `--allow-dirty` or `--allow-no-vcs` flag.
   b. To interact with source control, if you know the `jj` command for the operation, use that instead of the `git` command. `git` commands will still work in most repositories.
   c. To get the "current" branch, use `jj b l -r @- -T 'name'
   d. To get a diff, use `jj diff --git --no-pager` so that the diff is formatted the way `git` would format it.
2. The forges we use are GitLab and GitHub. Use `jj git remote list` to see which forge is being used.
   a. For GitHub, the `gh` CLI is available.
   b. For GitLab, the `glab` CLI is available.
   c. When working on GitLab CI, use `glab ci config compile` and related commands to debug locally. Use `glab api "projects/:id/jobs/${job_id}/trace"`, where `${job_id}` is the ID of the job, to see the logs from a job.
   d. If either `gh` or `glab` returns an authentication error, ask me to re-authenticate.

# Service observability

1. Use the Honeycomb MCP to query traces. If there is an authentication failure, ask me to permit access.
2. Use the CLI command `logcli --addr=https://loki.infra.rigetti.com` to query logs.
