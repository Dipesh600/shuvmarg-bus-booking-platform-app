void main() {
  String dateString = "2026-05-22T00:00:00.000Z";
  var parsed = DateTime.tryParse(dateString);
  print('Parsed: $parsed');
}
