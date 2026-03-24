class ApiPayload {
  const ApiPayload._();

  static List<dynamic> asList(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is List<dynamic>) {
        return nested;
      }
    }
    throw const FormatException('API response is not a list payload.');
  }

  static Map<String, dynamic> asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      return data;
    }
    throw const FormatException('API response is not a map payload.');
  }
}
