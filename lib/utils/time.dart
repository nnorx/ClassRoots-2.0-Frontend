String readTimestamp(DateTime created) {
  final diff = DateTime.now().difference(created);

  if (diff.inSeconds <= 60) {
    return 'just now';
  }

  if (diff.inMinutes <= 60) {
    return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'Min' : 'Mins'}';
  }

  if (diff.inHours <= 24) {
    return '${diff.inHours} ${diff.inHours == 1 ? 'Hour' : 'Hours'}';
  }

  if (diff.inDays <= 365) {
    return '${diff.inDays} ${diff.inDays == 1 ? 'Day' : 'Days'}';
  }

  return '${diff.inDays / 365} ${(diff.inDays / 365) == 1 ? 'Year' : 'Years'}';
}
