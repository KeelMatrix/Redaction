# Benchmarks

This folder contains performance benchmarks for `KeelMatrix.Redaction`.

We use [BenchmarkDotNet](https://benchmarkdotnet.org/) to watch for regressions in the built-in redactors and in common multi-redactor pipelines.

## How to Run

Run the PowerShell script from the repo root:

```powershell
pwsh -NoProfile -File bench/Run-Benchmarks.ps1
```

This will:

- discover all `*.Benchmarks.csproj` under `bench/`
- build and run them in `Release` for `.NET 8`
- export CSV / JSON / Markdown results into `artifacts/benchmarks/<timestamp>/`

## Common Use Cases

- run all redaction benchmarks:

  ```powershell
  pwsh -NoProfile -File bench/Run-Benchmarks.ps1
  ```

- run only the built-in redactor bench class:

  ```powershell
  pwsh -NoProfile -File bench/Run-Benchmarks.ps1 -Filter "*BuiltInRedactorBench.*" -CoolDownSec 0
  ```

- run only phone-related benchmarks:

  ```powershell
  pwsh -NoProfile -File bench/Run-Benchmarks.ps1 -Filter *Phone*
  ```

- use a shorter job for local iteration:

  ```powershell
  pwsh -NoProfile -File bench/Run-Benchmarks.ps1 -Job Short
  ```

## Notes

- BenchmarkDotNet also writes local scratch artifacts under `BenchmarkDotNet.Artifacts/`.
- For reproducible results, prefer the timestamped exports under `artifacts/benchmarks/`.
