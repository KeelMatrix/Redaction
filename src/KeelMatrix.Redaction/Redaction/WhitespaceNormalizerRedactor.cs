// Copyright (c) KeelMatrix

using System.Text.RegularExpressions;
using KeelMatrix.Redaction.Internal;

namespace KeelMatrix.Redaction {
    /// <summary>
    /// Normalizes whitespace to a single ASCII space and trims the ends.
    /// This makes pattern matching more stable across providers/platforms.
    /// </summary>
    public sealed class WhitespaceNormalizerRedactor : ITextRedactor {
        private static readonly Regex Ws = RedactionRegex.Create(@"\s+", RegexOptions.Compiled | RegexOptions.CultureInvariant);

        /// <inheritdoc />
        public string Redact(string input) {
            if (string.IsNullOrEmpty(input)) return string.Empty;
            string normalized = Ws.Replace(input, " ");
            return normalized.Trim();
        }
    }
}
