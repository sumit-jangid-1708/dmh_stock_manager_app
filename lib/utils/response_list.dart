List<dynamic> responseList(dynamic response) {
  if (response is List) {
    return response;
  }

  if (response is Map) {
    final results = response['results'];
    if (results is List) return results;

    final data = response['data'];
    if (data is List) return data;

    final items = response['items'];
    if (items is List) return items;
  }

  return <dynamic>[];
}
