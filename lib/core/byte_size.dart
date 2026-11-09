import 'package:intl/intl.dart';

const _units = ['B', 'KB', 'MB', 'GB', 'TB'];

/// Formats [bytes] the way Android's Settings does (1 KB = 1000 B), e.g. `1.2 GB`.
///
/// Total: negative input is shown as `0 B`.
String formatBytes(int bytes, {String? locale}) {
  if (bytes <= 0) return '0 B';
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1000 && unit < _units.length - 1) {
    value /= 1000;
    unit++;
  }
  final pattern = unit == 0 || value >= 100 ? '#,##0' : '#,##0.#';
  return '${NumberFormat(pattern, locale).format(value)} ${_units[unit]}';
}
