# GitHub Collaboration Setup

Repository: `miaoda-bianjieapp/bianjie`

This project remains a monorepo:

```text
apps/app       Flutter client
apps/api-java  Spring Boot API
```

Keeping both applications in one repository is intentional. Tool work frequently changes the backend DTO/API, Flutter model/repository, database migration, mocks, and tests together. One pull request can therefore deliver and verify one complete contract. CI remains separated into backend and Flutter workflows and uses path filters to avoid unnecessary jobs.

## Included automation

| Workflow | Required check name | Trigger | Purpose |
|---|---|---|---|
| `.github/workflows/backend-ci.yml` | `Backend CI result` | Every PR; heavy job only for backend changes | Maven tests and packaging with H2 and mock AI |
| `.github/workflows/flutter-ci.yml` | `Flutter CI result` | Every PR; heavy job only for Flutter changes | Dependency resolution, formatting, analysis, and widget/unit tests |
| `.github/workflows/repository-rules.yml` | `Secrets, generated files, and Flyway rules` | Every PR | Secret patterns, generated/local files, Flyway naming and locked migrations |

The optional Android debug build is available through **Actions > Flutter CI > Run workflow**. Enable `build_android_debug` only for changes to plugins, Android permissions, Manifest, Gradle, assets, or release-critical wiring.

CI does not require PostgreSQL credentials or AI provider keys. Backend tests use H2 and mock providers.

## One-time GitHub repository settings

An organization owner or repository administrator must configure these settings in the GitHub web UI after the workflow files are pushed.

### 1. Protect `main`

Open:

```text
Repository > Settings > Rules > Rulesets > New ruleset > New branch ruleset
```

Recommended settings:

- Ruleset name: `protect-main`
- Enforcement status: `Active`
- Target branches: include default branch (`main`)
- Restrict deletions
- Block force pushes
- Require a pull request before merging
- Required approvals: `1` initially; increase to `2` for shared protocol, database, or release changes
- Dismiss stale pull request approvals when new commits are pushed
- Require conversation resolution before merging
- Require status checks to pass
- Require branches to be up to date before merging
- Require linear history if the team uses Squash Merge only

After the first PR runs Actions, select these required checks:

```text
Backend CI result
Flutter CI result
Secrets, generated files, and Flyway rules
```

All three result checks appear on every PR. Backend and Flutter detect changed paths internally and skip only their expensive job when that application is unaffected, so required checks do not remain indefinitely pending.

### 2. Merge strategy

Open:

```text
Repository > Settings > General > Pull Requests
```

Recommended:

- Enable **Allow squash merging**
- Disable merge commits unless the team explicitly needs them
- Optionally disable rebase merging for a simpler beginner workflow
- Enable **Automatically delete head branches**

Deleting a merged feature branch does not remove its commits from `main` or its PR history.

### 3. Actions permissions

Open:

```text
Repository > Settings > Actions > General
```

Recommended:

- Allow actions from GitHub and verified creators required by this repository
- Workflow permissions: **Read repository contents**
- Do not add production secrets until a deployment workflow actually needs them

### 4. Labels

Create these labels if they do not exist:

```text
tool-request
architecture-review
database-migration
changes-requested
ready-to-merge
blocked
```

The Issue template references `tool-request`. If the label does not exist, GitHub may create the Issue without applying the label.

### 5. Optional CODEOWNERS

When module owners are assigned, add `.github/CODEOWNERS`, for example:

```text
/apps/api-java/ @backend-owner
/apps/app/ @flutter-owner
/apps/api-java/src/main/resources/db/migration/ @database-owner
/.github/ @repository-admin
/AGENTS.md @repository-admin
/TOOL_DEVELOPMENT_BOARD.md @repository-admin
```

Do not add placeholder usernames. Add CODEOWNERS only after real GitHub accounts and responsibilities are agreed.

## Daily workflow

1. Developer opens a **Tool Development Request** Issue and attaches sanitized reference screenshots.
2. Administrator confirms scope, tool IDs, executor/operations, shared files, and migration need.
3. Administrator adds one row to `TOOL_DEVELOPMENT_BOARD.md` and replies to the Issue with the assigned task ID and branch name.
4. Developer creates a personal branch from the latest `main`, implements no more than three approved tools, and self-tests.
5. Developer opens a PR using the template and links the Issue with `Closes #<issue-number>`.
6. Actions run automatically. The developer fixes failures on the same personal branch.
7. Administrator reviews architecture and code, samples the device workflow, and requests synchronization with the latest `main` when another PR merged first.
8. After final CI passes, administrator squash-merges the PR and updates the board.
9. GitHub automatically deletes the merged remote feature branch when the setting is enabled.
10. Developers start new tasks from the updated `main`.

## Board ownership

`TOOL_DEVELOPMENT_BOARD.md` is already the shared task register stored in Git. Do not create another spreadsheet unless the team later needs reporting or portfolio planning beyond engineering coordination.

To avoid Markdown merge conflicts:

- Developers submit/update information in GitHub Issues and PRs.
- The administrator, or a specifically assigned coordinator, edits the board.
- Board-only edits may be committed in a small administration PR.
- The task's feature PR should not rewrite unrelated board rows.

## First test PR

Before onboarding the team:

1. Push the initial repository content and workflows.
2. Create a temporary branch that changes one documentation line.
3. Open a PR and verify Repository Rules runs.
4. Add a harmless Flutter test change and verify Flutter CI runs.
5. Add a harmless backend test change and verify Backend CI runs.
6. Confirm `main` cannot be merged while a required check fails.
7. Close or merge the test PR and remove the temporary branch.
