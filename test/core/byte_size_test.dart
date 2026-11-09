import 'package:appmanager/core/byte_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats like Android Settings (1000-based)', () {
    expect(formatBytes(0), '0 B');
    expect(formatBytes(-5), '0 B');
    expect(formatBytes(999), '999 B');
    expect(formatBytes(1000), '1 KB');
    expect(formatBytes(1250000), '1.3 MB');
    expect(formatBytes(123456789), '123 MB');
    expect(formatBytes(2500000000), '2.5 GB');
  });
}
