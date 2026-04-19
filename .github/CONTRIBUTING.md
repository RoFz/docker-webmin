# Contributing

By participating in this project, you agree to abide by the
[Code of Conduct](CODE_OF_CONDUCT.md).

## Reporting Security Vulnerabilities

Please **do not** open a public issue for security vulnerabilities.
See [SECURITY.md](SECURITY.md) for the responsible disclosure process.

## Getting Started

```sh
git clone https://github.com/RoFz/REPO_NAME.git
cd REPO_NAME
```

## Commit Messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/)
and [release-please](https://github.com/googleapis/release-please) to automate
versioning and changelog generation.

### Subject line

Format: `<type>[optional scope]: <description>`

| Prefix | Use for | Triggers a release? |
| --- | --- | --- |
| `feat:` | New application features or capabilities | Yes (minor) |
| `fix:` | Bug fixes in application code or dependencies | Yes (patch) |
| `feat!:` or `fix!:` | Breaking change | Yes (major) |
| `build:` | Build system or external dependency changes | No |
| `chore:` | Maintenance, formatting, config | No |
| `ci:` | CI/CD, workflows, tooling, and infrastructure | No |
| `docs:` | Documentation only | No |
| `perf:` | Performance improvements (no behaviour change) | No |
| `refactor:` | Code restructuring (no behaviour change) | No |
| `revert:` | Reverts a previous commit | No |
| `style:` | Code style changes (whitespace, formatting) | No |
| `test:` | Test changes | No |

### Body

Optional. If present, each line **must** start with a hyphen and space:

```text
feat: add export endpoint

- feat: implement GET /export handler
- fix: correct pagination logic
- test: add export integration test
```

## Submitting a Pull Request

1. For non-trivial changes, open an issue first to discuss the approach.
2. Fork the repository and create a branch from `main`.
3. Make your changes, including tests for new behaviour.
4. Write commit messages following the Conventional Commits format above.
5. Open a pull request against `main`. Keep each PR to a single logical change.
