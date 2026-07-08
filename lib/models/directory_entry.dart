class DirectoryEntry {
  const DirectoryEntry({
    required this.id,
    required this.name,
    required this.department,
    required this.extension,
  });

  final String id;
  final String name;
  final String department;

  /// Internal extension, e.g. 123, 546.
  final String extension;
}
