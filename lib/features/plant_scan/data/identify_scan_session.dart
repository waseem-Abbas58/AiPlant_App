/// Unique id per identify attempt so cancel/retry never overwrites another scan.
class IdentifyScanSession {
  IdentifyScanSession._();

  static String newId() =>
      'scan-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond % 1000}';
}
