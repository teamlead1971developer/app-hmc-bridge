import '../models/directory_entry.dart';

/// In-memory internal directory for the session.
// TODO: replace mock data with a corporate directory API.
class DirectoryService {
  DirectoryService._();

  static final instance = DirectoryService._();

  static const allDepartments = 'All';

  static final _entries = <DirectoryEntry>[
    const DirectoryEntry(
      id: '1',
      name: 'Chirachart Hongsamart',
      department: 'Operations',
      extension: '123',
    ),
    const DirectoryEntry(
      id: '2',
      name: 'Natcha Wongsa',
      department: 'Operations',
      extension: '124',
    ),
    const DirectoryEntry(
      id: '3',
      name: 'Pimchanok Srisai',
      department: 'Human Resources',
      extension: '201',
    ),
    const DirectoryEntry(
      id: '4',
      name: 'Thanawat Meesuk',
      department: 'Human Resources',
      extension: '202',
    ),
    const DirectoryEntry(
      id: '5',
      name: 'Kittisak Boonma',
      department: 'Information Technology',
      extension: '301',
    ),
    const DirectoryEntry(
      id: '6',
      name: 'Supaporn Lertchai',
      department: 'Information Technology',
      extension: '302',
    ),
    const DirectoryEntry(
      id: '7',
      name: 'Reception — BRIDGE HQ',
      department: 'Facilities',
      extension: '100',
    ),
    const DirectoryEntry(
      id: '8',
      name: 'Security desk',
      department: 'Facilities',
      extension: '101',
    ),
    const DirectoryEntry(
      id: '9',
      name: 'Conference Room A',
      department: 'Facilities',
      extension: '410',
    ),
    const DirectoryEntry(
      id: '10',
      name: 'Finance helpdesk',
      department: 'Finance',
      extension: '501',
    ),
    const DirectoryEntry(
      id: '11',
      name: 'Procurement desk',
      department: 'Finance',
      extension: '546',
    ),
    const DirectoryEntry(
      id: '12',
      name: 'Executive assistant',
      department: 'Executive Office',
      extension: '001',
    ),
    const DirectoryEntry(
      id: '13',
      name: 'Legal counsel',
      department: 'Legal',
      extension: '601',
    ),
    const DirectoryEntry(
      id: '14',
      name: 'Training coordinator',
      department: 'Learning & Development',
      extension: '720',
    ),
  ];

  List<String> get departments {
    final names = _entries.map((e) => e.department).toSet().toList()..sort();
    return [allDepartments, ...names];
  }

  List<DirectoryEntry> search(String query, {String? department}) {
    final q = query.trim().toLowerCase();
    final dept = department ?? allDepartments;

    return _entries.where((entry) {
      if (dept != allDepartments && entry.department != dept) return false;
      if (q.isEmpty) return true;
      return entry.name.toLowerCase().contains(q) ||
          entry.department.toLowerCase().contains(q) ||
          entry.extension.contains(q);
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}

String formatExtension(String extension) => extension;
