class SslCommandResult {
  final bool success;
  final int exitCode;
  final String stdout;
  final String stderr;
  final String summary;

  const SslCommandResult({
    required this.success,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.summary,
  });

  factory SslCommandResult.error(String summary, {String stderr = ''}) {
    return SslCommandResult(
      success: false,
      exitCode: -1,
      stdout: '',
      stderr: stderr,
      summary: summary,
    );
  }

  String get mergedOutput {
    if (stderr.trim().isEmpty) {
      return stdout.trim();
    }
    if (stdout.trim().isEmpty) {
      return stderr.trim();
    }
    return '${stdout.trim()}\n${stderr.trim()}';
  }
}
