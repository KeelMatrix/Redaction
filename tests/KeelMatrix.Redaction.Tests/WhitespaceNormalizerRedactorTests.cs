// Copyright (c) KeelMatrix

using FluentAssertions;
using KeelMatrix.Redaction;
using Xunit;

namespace KeelMatrix.Redaction.Tests {
    public class WhitespaceNormalizerRedactorTests {
        [Fact]
        public void Collapses_All_Whitespace_And_Trims() {
            WhitespaceNormalizerRedactor r = new();
            const string input = " \tSELECT \n *  \r\n  FROM   Users  ";
            _ = r.Redact(input).Should().Be("SELECT * FROM Users");
        }
    }
}
