# Contributing

Thanks for contributing to KeelMatrix.Redaction.

## Before You Begin

1. Search existing issues and pull requests to avoid duplicating work.
2. Read the [Code of Conduct](CODE_OF_CONDUCT.md).
3. For security issues, use the private reporting guidance in [SECURITY.md](SECURITY.md) instead of opening a public issue.

## Development

1. Fork the repository and create a feature branch from `main`.
2. Build the repo with `dotnet build KeelMatrix.Redaction.slnx`.
3. Run the test suite with `dotnet test tests/KeelMatrix.Redaction.Tests/KeelMatrix.Redaction.Tests.csproj`.
4. Validate packaging with `dotnet pack src/KeelMatrix.Redaction/KeelMatrix.Redaction.csproj -c Release`.
5. If you change the public API of a packable project, update `PublicAPI.Shipped.txt` and `PublicAPI.Unshipped.txt` in the affected project.
6. Keep README and package metadata changes aligned with user-facing behavior.

## Pull Requests

1. Open the pull request against `main`.
2. Describe the problem, the change, and any user-visible impact.
3. Reference related issues when relevant.
4. Keep the diff focused. Separate unrelated cleanup into a different pull request.

## Public API Surface

This repository uses **Roslyn Public API Analyzers** to lock down the surface area.
When you add or change a public member in a packable project:

1. Make your code changes.
2. Update `PublicAPI.Shipped.txt` and `PublicAPI.Unshipped.txt` in the affected project.
3. Review the diff and commit. When a release is cut, items from *Unshipped* can be moved to *Shipped*.

> Tips
> - We keep a single `PublicAPI.Shipped.txt`/`PublicAPI.Unshipped.txt` pair per project across TFMs.
> - If a member is TFM-specific, append a trailing comment to its line: `// TFM: net8.0` or `// TFM: netstandard2.0`.
