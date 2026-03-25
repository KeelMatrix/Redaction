// Copyright (c) KeelMatrix

using System.Text.RegularExpressions;
using KeelMatrix.Redaction.Internal;

namespace KeelMatrix.Redaction {
    /// <summary>
    /// Masks international-looking phone numbers.
    /// - Requires ≥ 7 digits overall (so short codes like "123-45" are not masked).
    /// - Replaces the entire phone (including leading '+' or '(' and country/area prefixes) with "***".
    /// - Idempotent: reapplying does not change the output.
    /// </summary>
    public sealed class PhoneRedactor : ITextRedactor {
        // Capture the surrounding non-word boundaries so replacement can preserve them
        // without relying on look-around, then validate the digit count in the evaluator.
        private static readonly Regex Phone = RedactionRegex.Create(
            @"(?<prefix>^|[^\w])(?<phone>(?:\+\d{1,4}[\s\-.]*)?(?:\(\d{1,4}\)|\d{1,4})(?:[\s\-.]+(?:\(\d{1,4}\)|\d{1,4})){2,})(?<suffix>$|[^\w])",
            RegexOptions.None);

        /// <inheritdoc/>
        public string Redact(string input) {
            if (string.IsNullOrEmpty(input)) return input;

            // Fast path: skip regex if fewer than 7 digits in total.
            int digits = 0;
            for (int i = 0; i < input.Length && digits < 7; i++) {
                char ch = input[i];
                if (ch is >= '0' and <= '9') digits++;
            }
            return digits < 7
                ? input
                : Phone.Replace(input, static match => HasMinimumDigits(match.Groups["phone"].Value)
                    ? match.Groups["prefix"].Value + "***" + match.Groups["suffix"].Value
                    : match.Value);
        }

        private static bool HasMinimumDigits(string value) {
            int digits = 0;
            for (int i = 0; i < value.Length && digits < 7; i++) {
                char ch = value[i];
                if (ch is >= '0' and <= '9') digits++;
            }

            return digits >= 7;
        }
    }
}
