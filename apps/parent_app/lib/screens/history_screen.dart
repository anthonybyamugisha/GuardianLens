import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen({
    super.key,
    required this.history,
    required this.onSelectAlert,
    required this.onBack,
  });

  final List<HistoryEntry> history;
  final ValueChanged<String> onSelectAlert;
  final VoidCallback onBack;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All';

  static const _filters = ['All', 'Alert', 'Activity'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HistoryEntry> get _filtered {
    final q = _searchController.text.toLowerCase();
    return widget.history.where((item) {
      final matchesSearch = q.isEmpty ||
          item.app.toLowerCase().contains(q) ||
          item.event.toLowerCase().contains(q) ||
          item.detail.toLowerCase().contains(q);
      final category = item.category.name;
      final matchesFilter = _filter == 'All' ||
          (_filter == 'Alert' && category == HistoryCategory.alert.name) ||
          (_filter == 'Activity' && category == HistoryCategory.activity.name);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Map<String, List<HistoryEntry>> get _grouped {
    final map = <String, List<HistoryEntry>>{};
    for (final item in _filtered) {
      map.putIfAbsent(item.date, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _BackButton(onTap: widget.onBack),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GuardianLens',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.colors.textFaint),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'History',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.04,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: context.colors.cardBackground,
                border: Border.all(color: context.colors.borderInput),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 16, color: context.colors.textFaint),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        hintText: 'Search events...',
                        hintStyle: TextStyle(color: context.colors.textPlaceholder, fontSize: 14),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _filters[index];
                final selected = _filter == cat;
                return GestureDetector(
                  onTap: () => setState(() => _filter = cat),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryBlue : context.colors.surfaceFill,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : context.colors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: _grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: context.colors.textFaint,
                      ),
                    ),
                    SizedBox(height: 8),
                    ...entry.value.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: _HistoryItem(item: item, onTap: () {
                          final alertId = item.alertId;
                          if (alertId != null) widget.onSelectAlert(alertId);
                        }),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  _HistoryItem({required this.item, required this.onTap});

  final HistoryEntry item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          border: Border.all(color: context.colors.borderSubtle),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.surfaceFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 18, color: item.accentColor),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.app,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                        ),
                      ),
                      Text(
                        item.time,
                        style: TextStyle(fontSize: 10, color: context.colors.textFaint),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.event,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                  ),
                  SizedBox(height: 8),
                  _CategoryBadge(category: item.category),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  _CategoryBadge({required this.category});

  final HistoryCategory category;

  @override
  Widget build(BuildContext context) {
    final isAlert = category == HistoryCategory.alert;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAlert ? context.colors.paleRedSurface : context.colors.paleGreenSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isAlert ? 'Alert' : 'Activity',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isAlert ? AppColors.dangerRed : AppColors.successGreen,
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(Icons.arrow_back, size: 20, color: context.colors.textSecondary),
      ),
    );
  }
}
