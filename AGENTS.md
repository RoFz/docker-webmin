## Commit Messages

- Use Conventional Commits for every commit subject.
- Format the subject as `type(scope): summary` when a scope is appropriate.
- Before creating a commit, inspect recent commit history in the current repo
  to understand local conventions.
- Follow the rules in this `AGENTS.md` even if recent history differs.
- If the repo's recent commit pattern conflicts with this `AGENTS.md`, call
  out the mismatch before committing and prefer the `AGENTS.md` rules.
- Separate the subject from the body with a blank line.
- Reserve `feat` and `fix` for changes to the repository's primary product or
  deliverable, such as application code or the main artifact the repository
  exists to build.
- For CI-only, release tooling, developer tooling, documentation, or other
  non-product changes, use types such as `ci`, `chore`, `docs`, `build`, or
  `refactor` instead of `feat` or `fix`.
- Include a commit body when additional context is useful.
- Write normal explanatory prose in the body when you are only providing
  context.
- If you want Release Please to parse multiple changelog entries from one
  commit, place additional Conventional Commit entries at the end of the body
  with no bullet prefix, for example:
  `feat(module): add support for per-repo configuration`
  `fix(ci): correct workflow trigger conditions`
  `chore(pre-commit): update hook pins`
- Write `BREAKING CHANGE:` and `Release-As:` footers with no bullet prefix.
- Keep commit message body lines within the repository lint limits.
