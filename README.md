# KeelMatrix.Redaction

Privacy-first .NET text redaction primitives for masking secrets, tokens, PII, and noisy identifiers in logs, SQL, diagnostics, CI artifacts, and snapshot data.

## Install

```bash
dotnet add package KeelMatrix.Redaction
```

## What It Includes

- built-in redactors for auth headers, API keys, JWTs, cookies, emails, GUIDs, IP addresses, phones, timestamps, URL tokens, and connection-string passwords
- whitespace normalization for stable diffs and snapshots
- a reusable `RegexReplaceRedactor` for custom masking rules
- hardened regex creation with timeouts and, where safe, .NET 8 non-backtracking mode
- zero external runtime dependencies

## Quick Start

```csharp
using KeelMatrix.Redaction;

ITextRedactor[] redactors = {
    new AuthorizationRedactor(),
    new ApiKeyRedactor(),
    new EmailRedactor(),
    new JwtTokenRedactor(),
    new WhitespaceNormalizerRedactor()
};

string sanitized = rawText;
foreach (ITextRedactor redactor in redactors) {
    sanitized = redactor.Redact(sanitized);
}
```

## Common Use Cases

- redact secrets before logging request, response, or SQL text
- sanitize diagnostics before attaching them to CI artifacts or support tickets
- remove rotating values so snapshot and approval tests stay stable
- share a common redaction pipeline across libraries, services, tools, and test infrastructure

## Design Notes

- redactors are expected to be pure and idempotent
- implementations are safe to compose in order
- the library targets `net8.0` and `netstandard2.0`

## Documentation

- [Repository](https://github.com/KeelMatrix/Redaction)
- [Package README](https://github.com/KeelMatrix/Redaction/tree/main/src/KeelMatrix.Redaction)
