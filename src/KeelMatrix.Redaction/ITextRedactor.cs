// Copyright (c) KeelMatrix

namespace KeelMatrix.Redaction {
    /// <summary>
    /// Contract for text redactors that mask secrets, PII, or noisy identifiers in arbitrary text.
    /// </summary>
    /// <remarks>
    /// Implementations must be <em>pure</em> and idempotent: invoking <see cref="Redact"/> multiple times
    /// with the same input produces the same output. They should be thread-safe and tolerate
    /// <c>null</c> or empty input by returning <see cref="string.Empty"/>. When multiple redactors are
    /// composed, they run in caller-defined order.
    /// </remarks>
    public interface ITextRedactor {
        /// <summary>Returns a redacted form of <paramref name="input"/>.</summary>
        /// <param name="input">
        /// Arbitrary text that may contain sensitive values. Implementations should treat unexpected
        /// <c>null</c> input defensively and return <see cref="string.Empty"/>.
        /// </param>
        /// <returns>
        /// The redacted text. If <paramref name="input"/> is <c>null</c> or empty, returns
        /// <see cref="string.Empty"/>.
        /// </returns>
        string Redact(string input);
    }
}
