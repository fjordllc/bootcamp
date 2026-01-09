# Repository Guidelines

## Project Structure & Module Organization
- `app/` Rails app code: `models/`, `controllers/`, `views/`, `jobs/`, `helpers/`, and frontend under `javascript/` (Shakapacker).
- `config/` environment, routes, and lints (see `.rubocop.yml`, `config/slim_lint.yml`).
- `db/` migrations and schema; `lib/` app-specific utilities; `public/` static assets.
- `test/` Minitest suite: `system/`, `models/`, `controllers/`, fixtures in `test/fixtures/`.
- `bin/` helper scripts; `Procfile.dev` runs Rails and asset dev server.

## Build, Test, and Development Commands
- Setup: `bin/setup` — install gems, prepare DB, npm, etc.
- Run (dev): `foreman start -f Procfile.dev` — Rails on `:3000` + Shakapacker.
- Tests (headless): `rails test:all`.
- Tests (browser): `HEADFUL=1 rails test:all`.
- Tests (no parallel): `PARALLEL_WORKERS=1 rails test:all`.
- Lint: `./bin/lint` — RuboCop (auto-correct), Slim-Lint, ESLint/Prettier.
- Profiler: `PROFILE=1 rails server` to enable rack-mini-profiler.

## Coding Style & Naming Conventions
- Ruby: 2-space indent, snake_case methods, CamelCase classes; enforced by RuboCop (`.rubocop.yml`).
- Views: Slim templates, linted by `config/slim_lint.yml`.
- JS/TS: Code in `app/javascript/`; ESLint + Prettier via `npm run lint` scripts; React 18 and Shakapacker/Webpack 5.
- Files follow Rails conventions (e.g., `app/models/user.rb`, test `test/models/user_test.rb`).

## Testing Guidelines
- Frameworks: Minitest + Capybara for system tests.
- Structure: place unit/integration tests under matching `test/*` directories; name files `*_test.rb`.
- Run a single test or line: `rails test test/models/user_test.rb:42`.
- Keep tests deterministic; use fixtures in `test/fixtures/`.

## Commit & Pull Request Guidelines
- Commits: imperative mood and focused scope; reference issues (e.g., "Fix profile validation #123").
- PRs: clear description, linked issues, screenshots for UI changes, migration notes, and rollback plan if relevant.
- Quality gates: all linters pass (`bin/lint`) and CI (CircleCI) green; add/adjust tests when changing behavior.

## Security & Configuration Tips
- Never commit secrets; use `.env.local`. Respect `.ruby-version`, `.tool-versions`, and Node versions in `.node-version`/`.nvmrc`.
- Use `bin/setup` for local DB and dependencies; avoid manual tweaks in `config/` without discussion.

## Agent-Specific Instructions
- Follow these guidelines for any edits. Keep changes minimal, scoped to the task, and update docs/tests when adding commands or changing behavior.

