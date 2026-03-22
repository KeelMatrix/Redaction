// Copyright (c) KeelMatrix

using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Running;
using KeelMatrix.Redaction;

namespace KeelMatrix.Redaction.Benchmarks {
    public static class Program {
        public static void Main(string[] args) =>
            BenchmarkSwitcher.FromAssembly(typeof(Program).Assembly).Run(args, new CiAwareConfig());
    }

    [MemoryDiagnoser]
    public class BuiltInRedactorBench {
        [ParamsSource(nameof(SampleCases))]
        public string Sample { get; set; } = string.Empty;

        private readonly EmailRedactor _email = new();
        private readonly PhoneRedactor _phone = new();
        private readonly JwtTokenRedactor _jwt = new();
        private readonly ITextRedactor[] _pipeline = [
            new WhitespaceNormalizerRedactor(),
            new EmailRedactor(),
            new JwtTokenRedactor(),
            new UrlQueryTokenRedactor(),
            new PhoneRedactor()
        ];

        [Benchmark]
        public string Email() => _email.Redact(Sample);

        [Benchmark]
        public string Phone() => _phone.Redact(Sample);

        [Benchmark]
        public string Jwt() => _jwt.Redact(Sample);

        [Benchmark]
        public string CommonPipeline() {
            string text = Sample;
            foreach (ITextRedactor redactor in _pipeline) {
                text = redactor.Redact(text);
            }

            return text;
        }

        public static IEnumerable<string> SampleCases() {
            yield return "simple user@example.com";
            yield return "very.long.email.address_" + new string('x', 128) + "@domain.co.uk";
            yield return "+1-415-555-2671 is my number";
            yield return "call me at +44 20 7946 0958";
            yield return "jwt eyJhbGciOi" + new string('z', 2048);
            yield return " Authorization: Bearer aaaBBBBBBBBB.cccDDDDDDDDD.eeeEEEEEEEEE token=TTT user@example.com +1 (555) 012-3456 ";
            yield return "noise-no-pii-" + new string('x', 1024);
        }
    }
}
