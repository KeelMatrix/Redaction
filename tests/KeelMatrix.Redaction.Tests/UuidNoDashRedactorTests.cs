// Copyright (c) KeelMatrix

using FluentAssertions;
using KeelMatrix.Redaction;
using Xunit;

namespace KeelMatrix.Redaction.Tests {
    public class UuidNoDashRedactorTests {
        [Fact]
        public void Masks_32_Hex_With_Letters() {
            UuidNoDashRedactor r = new();
            const string id = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"; // 32 chars with letters
            _ = r.Redact(id).Should().Be("***");
        }

        [Fact]
        public void Does_Not_Mask_32_Digits_Only() {
            UuidNoDashRedactor r = new();
            const string digits = "12345678901234567890123456789012";
            _ = r.Redact(digits).Should().Be(digits);
        }
    }
}
