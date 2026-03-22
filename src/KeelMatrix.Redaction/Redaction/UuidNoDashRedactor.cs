// Copyright (c) KeelMatrix

using System.Text.RegularExpressions;
using KeelMatrix.Redaction.Internal;

namespace KeelMatrix.Redaction {
    /// <summary>
    /// Masks UUIDs without dashes (32 hex chars). Requires at least one letter to avoid masking long integers.
    /// </summary>
    public sealed class UuidNoDashRedactor : ITextRedactor {
        private static readonly Regex Uuid = RedactionRegex.Create(
            @"\b(?=[0-9A-Fa-f]{32}\b)(?=.*[A-Fa-f])[0-9A-Fa-f]{32}\b",
            RegexOptions.Compiled | RegexOptions.CultureInvariant);

        /// <inheritdoc />
        public string Redact(string input) => string.IsNullOrEmpty(input) ? string.Empty : Uuid.Replace(input, "***");
    }
}

