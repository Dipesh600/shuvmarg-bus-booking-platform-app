import 'dart:core';

void main() {
  String tripDate = '2026-05-22T00:00:00.000Z';
  var parsed = DateTime.tryParse(tripDate);
  print('parsed: $parsed');
  if (parsed != null) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String formatted = '${parsed.day} ${months[parsed.month - 1]}, ${parsed.year}';
    print('formatted: $formatted');
  }
}
