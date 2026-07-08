import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/joy_point_transaction.dart';
import '../services/app_refresh_service.dart';
import '../services/joy_service.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class JoyPointHistoryScreen extends StatefulWidget {
  const JoyPointHistoryScreen({super.key});

  @override
  State<JoyPointHistoryScreen> createState() => _JoyPointHistoryScreenState();
}

class _JoyPointHistoryScreenState extends State<JoyPointHistoryScreen> {
  final _joy = JoyService.instance;
  late int _year;
  int? _month;
  int _tab = 0;

  static const _monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlassBackground.position.value = GlowPosition.top;
    });
    _joy.ensureLoaded();
  }

  JoyPointTransactionType get _type =>
      _tab == 0 ? JoyPointTransactionType.earn : JoyPointTransactionType.burn;

  List<JoyPointTransaction> get _items => _joy.pointTransactions(
        year: _year,
        month: _month,
        type: _type,
      );

  void _selectAllYear() => setState(() => _month = null);

  void _selectMonth(int month) {
    setState(() => _month = month);
  }

  void _shiftYear(int delta) {
    setState(() => _year += delta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GlassPageHeader(title: 'Point history'),
            Expanded(
              child: ListenableBuilder(
                listenable: _joy,
                builder: (context, _) {
                  final member = _joy.member;
                  final items = _items;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
                        child: GlassCard(
                          radius: 22,
                          blur: 26,
                          shadows: kHeroCardShadows,
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RedTintIconTile(
                                icon: LucideIcons.gem,
                                size: 38,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Point balance',
                                      style: bodyStyle(
                                        size: 11,
                                        color: kTextFaint,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          member == null
                                              ? '—'
                                              : '${member.pointBalance}',
                                          style: displayStyle(
                                            size: 28,
                                            weight: 600,
                                          ),
                                        ),
                                        if (member != null) ...[
                                          const SizedBox(width: 6),
                                          Text(
                                            'Points',
                                            style: bodyStyle(
                                              size: 14,
                                              color: kTextMuted,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: _PeriodFilterCard(
                          year: _year,
                          month: _month,
                          monthLabels: _monthLabels,
                          onAllYear: _selectAllYear,
                          onMonthSelected: _selectMonth,
                          onYearShift: _shiftYear,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Row(
                          children: [
                            Expanded(
                              child: FilterChipButton(
                                label: 'Point earn',
                                selected: _tab == 0,
                                onTap: () => setState(() => _tab = 0),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilterChipButton(
                                label: 'Point burn',
                                selected: _tab == 1,
                                onTap: () => setState(() => _tab = 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: GlassRefreshIndicator(
                          onRefresh: () => AppRefreshService.refresh(
                            AppRefreshScope.joy,
                          ),
                          child: items.isEmpty
                              ? LayoutBuilder(
                                  builder: (context, constraints) {
                                    return ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: [
                                        SizedBox(
                                          height: constraints.maxHeight,
                                          child: Center(
                                            child: Text(
                                              _emptyMessage,
                                              style: bodyStyle(
                                                size: 14,
                                                color: kTextMuted,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    22,
                                    0,
                                    22,
                                    32,
                                  ),
                                  itemCount: items.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    return _PointTransactionRow(
                                      item: items[index],
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _emptyMessage {
    final action = _tab == 0 ? 'earned' : 'burned';
    if (_month == null) return 'No points $action in $_year.';
    return 'No points $action in ${_monthLabels[_month! - 1]} $_year.';
  }
}

class _PeriodFilterCard extends StatelessWidget {
  const _PeriodFilterCard({
    required this.year,
    required this.month,
    required this.monthLabels,
    required this.onAllYear,
    required this.onMonthSelected,
    required this.onYearShift,
  });

  final int year;
  final int? month;
  final List<String> monthLabels;
  final VoidCallback onAllYear;
  final ValueChanged<int> onMonthSelected;
  final ValueChanged<int> onYearShift;

  bool get _isAllYear => month == null;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 16,
      blur: 22,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'View',
            style: bodyStyle(size: 11, color: kTextFaint),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilterChipButton(
                  label: 'Entire year',
                  selected: _isAllYear,
                  onTap: onAllYear,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilterChipButton(
                  label: 'By month',
                  selected: !_isAllYear,
                  onTap: () => onMonthSelected(
                    month ?? DateTime.now().month,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Year',
            style: bodyStyle(size: 11, color: kTextFaint),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: kGlassInnerFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kGlassInnerBorder),
            ),
            child: Row(
              children: [
                GlassIconButton(
                  icon: LucideIcons.chevronLeft,
                  size: 32,
                  iconSize: 14,
                  onPressed: () => onYearShift(-1),
                ),
                Expanded(
                  child: Text(
                    '$year',
                    style: displayStyle(size: 17, weight: 600),
                    textAlign: TextAlign.center,
                  ),
                ),
                GlassIconButton(
                  icon: LucideIcons.chevronRight,
                  size: 32,
                  iconSize: 14,
                  onPressed: () => onYearShift(1),
                ),
              ],
            ),
          ),
          if (!_isAllYear) ...[
            const SizedBox(height: 14),
            Text(
              'Month',
              style: bodyStyle(size: 11, color: kTextFaint),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.1,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final value = index + 1;
                final selected = month == value;
                return _MonthChip(
                  label: monthLabels[index],
                  selected: selected,
                  onTap: () => onMonthSelected(value),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? kActiveFill : kGlassInnerFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? kActiveBorder : kGlassInnerBorder,
          ),
        ),
        child: Text(
          label,
          style: bodyStyle(
            size: 12,
            weight: selected ? 600 : 500,
            color: selected ? kRedLight : kTextMuted,
          ),
        ),
      ),
    );
  }
}

class _PointTransactionRow extends StatelessWidget {
  const _PointTransactionRow({required this.item});

  final JoyPointTransaction item;

  @override
  Widget build(BuildContext context) {
    final isEarn = item.type == JoyPointTransactionType.earn;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 16,
      blur: 24,
      child: Row(
        children: [
          RedTintIconTile(
            icon: isEarn ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: bodyStyle(size: 14, weight: 500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  formatJoyDate(item.date),
                  style: bodyStyle(size: 12, color: kTextMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.signedPoints,
            style: displayStyle(
              size: 16,
              weight: 600,
              color: isEarn ? kRedLight : kText,
            ),
          ),
        ],
      ),
    );
  }
}
