## Navigation

* Bug: start in `tests/KeelMatrix.Redaction.Tests/` for failing case; then open matching file in `src/KeelMatrix.Redaction/Redaction/`; then `src/KeelMatrix.Redaction/Internal/RedactionRegex.cs`; then `src/KeelMatrix.Redaction/PublicAPI.*.txt` if public surface changed. 
* Feature: start in `src/KeelMatrix.Redaction/Redaction/`; check `src/KeelMatrix.Redaction/ITextRedactor.cs`; add/update matching tests in `tests/KeelMatrix.Redaction.Tests/`; update `src/KeelMatrix.Redaction/PublicAPI.*.txt` only for public API changes.
* Search order: target test file -> matching redactor file -> `RedactionRegex.cs` -> `ITextRedactor.cs` -> project file if build/package issue.
* Entry points: `src/KeelMatrix.Redaction/ITextRedactor.cs`; `src/KeelMatrix.Redaction/Redaction/*.cs`; `src/KeelMatrix.Redaction/Internal/RedactionRegex.cs`; `tests/KeelMatrix.Redaction.Tests/*.cs`.
* Ignore: `bench/`; `artifacts/`; `BenchmarkDotNet.Artifacts/`; root docs/policy files unless task is docs/release/package metadata.
* Ignore for code tasks: `CHANGELOG.md`; `CODE_OF_CONDUCT.md`; `CONTRIBUTING.md`; `LICENSE`; `PRIVACY.md`; `SECURITY.md`.

## Commands

* Build lib: `dotnet build src/KeelMatrix.Redaction/KeelMatrix.Redaction.csproj`
* Build repo: `dotnet build KeelMatrix.Redaction.slnx`
* Test all: `dotnet test tests/KeelMatrix.Redaction.Tests/KeelMatrix.Redaction.Tests.csproj`
* Test one file area: `dotnet test tests/KeelMatrix.Redaction.Tests/KeelMatrix.Redaction.Tests.csproj --filter FullyQualifiedName~PhoneRedactorTests`
* Test one method: `dotnet test tests/KeelMatrix.Redaction.Tests/KeelMatrix.Redaction.Tests.csproj --filter FullyQualifiedName~PhoneRedactorTests.Masks_Common_Phone_Formats`
* Pack only when packaging/public API/metadata changed: `dotnet pack src/KeelMatrix.Redaction/KeelMatrix.Redaction.csproj -c Release`
* Fastest validation: run narrowest relevant test first; then affected test class; then full test project only if needed.
* Do not run benchmarks unless explicitly requested: `pwsh -NoProfile -File bench/Run-Benchmarks.ps1`

## Constraints

* Modify only files tied to the failing test or requested feature.
* Keep edits inside one redactor and its tests when possible.
* Do not touch unrelated redactors.
* Do not change `ITextRedactor.cs` unless contract change is required.
* Do not edit `PublicAPI.Shipped.txt` or `PublicAPI.Unshipped.txt` unless public API changed.
* Do not alter build props/targets/package versions unless task is build/package related.
* Do not update docs/readmes unless behavior or package surface changed and task requires it.
* Avoid refactors across multiple redactors unless explicitly requested.

## Efficiency Rules

* Do not scan entire repo.
* Read only: target test, target source file, shared regex helper if relevant, API baseline if relevant.
* Use filename/task-name matching to jump directly to files.
* Prefer targeted grep/read over directory walks.
* Stop exploring once the relevant source-test pair is found.
* Do not reread unchanged files.
* Do not spawn subagents.
* Do not rerun the same command after a deterministic failure without a code change.
* Prefer one narrow test command per iteration.
* Escalate to broader build/test only after narrow validation passes.

## Output

* Return minimal diffs only.
* No explanations unless requested.
* Do not summarize unchanged files.
* List only touched files and exact commands run when asked.
