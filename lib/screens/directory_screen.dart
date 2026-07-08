import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/directory_entry.dart';
import '../services/app_refresh_service.dart';
import '../services/directory_service.dart';
import '../widgets/app_toast.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final _search = TextEditingController();
  final _directory = DirectoryService.instance;
  String _department = DirectoryService.allDepartments;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<DirectoryEntry> get _filtered =>
      _directory.search(_search.text, department: _department);

  @override
  Widget build(BuildContext context) {
    final entries = _filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GlassPageHeader(title: 'Directory'),
            Expanded(
              child: GlassRefreshIndicator(
                onRefresh: () => AppRefreshService.refresh(
                  AppRefreshScope.directory,
                ),
                child: SingleChildScrollView(
                  physics: kGlassRefreshPhysics,
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      radius: 14,
                      blur: 20,
                      child: Row(
                        children: [
                          Icon(LucideIcons.search, size: 16, color: kTextFaint),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _search,
                              onChanged: (_) => setState(() {}),
                              style: bodyStyle(size: 14),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Search by name, department or ext.',
                                hintStyle: bodyStyle(size: 14, color: kTextFaint),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final dept in _directory.departments) ...[
                            FilterChipButton(
                              label: dept == DirectoryService.allDepartments
                                  ? dept
                                  : _shortDepartment(dept),
                              selected: _department == dept,
                              onTap: () => setState(() => _department = dept),
                            ),
                            if (dept != _directory.departments.last)
                              const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GlassSectionHeader(
                      'Internal extensions',
                      trailing: Text(
                        '${entries.length} listed',
                        style: bodyStyle(size: 12, color: kTextMuted),
                      ),
                    ),
                    if (entries.isEmpty)
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No contacts match your search.',
                          style: bodyStyle(size: 14, color: kTextMuted),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      for (final entry in entries) ...[
                        _DirectoryRow(entry: entry),
                        const SizedBox(height: 10),
                      ],
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.phone, size: 12, color: kTextFaint),
                        const SizedBox(width: 6),
                        Text(
                          'Tap an extension to copy · Dial 0 + ext. from desk phone',
                          style: bodyStyle(size: 11, color: kTextFaint),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortDepartment(String dept) {
    return switch (dept) {
      'Human Resources' => 'HR',
      'Information Technology' => 'IT',
      'Learning & Development' => 'L&D',
      'Executive Office' => 'Executive',
      _ => dept,
    };
  }
}

class _DirectoryRow extends StatefulWidget {
  const _DirectoryRow({required this.entry});

  final DirectoryEntry entry;

  @override
  State<_DirectoryRow> createState() => _DirectoryRowState();
}

class _DirectoryRowState extends State<_DirectoryRow> {
  bool _pressed = false;

  void _copyExtension() {
    Clipboard.setData(ClipboardData(text: widget.entry.extension));
    AppToast.success(context, 'Extension ${widget.entry.extension} copied.');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _copyExtension();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          radius: 16,
          blur: 24,
          child: Row(
            children: [
              RedTintIconTile(icon: LucideIcons.phone, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.entry.name,
                      style: bodyStyle(size: 13, weight: 500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.entry.department,
                      style: bodyStyle(size: 11, color: kTextFaint),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kGlassInnerFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kGlassInnerBorder),
                ),
                child: Text(
                  widget.entry.extension,
                  style: monoStyle(size: 14, weight: 600, color: kRedLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
