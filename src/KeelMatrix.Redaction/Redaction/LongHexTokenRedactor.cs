// Copyright (c) KeelMatrix

using System.Text.RegularExpressions;
using KeelMatrix.Redaction.Internal;

namespace KeelMatrix.Redaction {
    /// <summary>
    /// Redacts long hexadecimal tokens (32+ hex chars) → ***.
    /// </summary>
    public sealed class LongHexTokenRedactor : ITextRedactor {
        private static readonly Regex Hex = RedactionRegex.Create(
            @"\b[0-9a-fA-F]{32,}\b",
            RegexOptions.Compiled | RegexOptions.CultureInvariant);

        /// <inheritdoc />
        public string Redact(string input) => string.IsNullOrEmpty(input) ? string.Empty : Hex.Replace(input, "***");
    }
}

