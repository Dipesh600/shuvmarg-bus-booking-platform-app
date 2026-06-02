/// Minimal model representing a stop returned by the autocomplete API.
/// Kept lean intentionally — the UI only needs name, code, and type for display.
class StopSuggestion {
  final String id;
  final String name;
  final String code;
  final String type; // "CITY" | "JUNCTION" | "TOWN" | "BORDER"
  final String? state;

  const StopSuggestion({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    this.state,
  });

  factory StopSuggestion.fromJson(Map<String, dynamic> json) {
    return StopSuggestion(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      type: json['type'] as String,
      state: json['state'] as String?,
    );
  }

  /// Human-readable subtitle shown under the stop name in the dropdown.
  String get subtitle {
    final parts = <String>[];
    if (state != null && state!.isNotEmpty) parts.add(state!);
    parts.add(type[0] + type.substring(1).toLowerCase()); // "City", "Junction"…
    return parts.join(' · ');
  }
}
