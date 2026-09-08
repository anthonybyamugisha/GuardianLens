import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/toggle.dart';

class MonitoringScreen extends StatefulWidget {
  MonitoringScreen({
    super.key,
    required this.apps,
    required this.onAppsChange,
    required this.onSelectApp,
    required this.onBack,
  });

  final List<MonitoredApp> apps;
  final ValueChanged<List<MonitoredApp>> onAppsChange;
  final ValueChanged<String> onSelectApp;
  final VoidCallback onBack;

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final _searchController = TextEditingController();
  bool _showAdd = false;
  final _newAppNameController = TextEditingController();
  final _newAppDescController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _newAppNameController.dispose();
    _newAppDescController.dispose();
    super.dispose();
  }

  void _toggleApp(String name) {
    widget.onAppsChange(
      widget.apps.map((app) => app.name == name ? app.copyWith(enabled: !app.enabled) : app).toList(),
    );
  }

  void _addApp() {
    final name = _newAppNameController.text.trim();
    if (name.isEmpty) return;
    widget.onAppsChange([
      ...widget.apps,
      MonitoredApp(
        name: name,
        description: _newAppDescController.text.trim().isEmpty
            ? 'Custom app'
            : _newAppDescController.text.trim(),
        enabled: true,
        sensitivity: Sensitivity.balanced,
        accentColor: context.colors.textPrimary,
        icon: Icons.apps,
      ),
    ]);
    _newAppNameController.clear();
    _newAppDescController.clear();
    setState(() => _showAdd = false);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filtered = widget.apps
        .where((app) => app.name.toLowerCase().contains(query))
        .toList();
    final activeCount = widget.apps.where((app) => app.enabled).length;

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
                      'Monitoring',
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
                        hintText: 'Search apps...',
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
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Monitored apps',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                ),
                Spacer(),
                Text(
                  '$activeCount of ${widget.apps.length} active',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.colors.textFaint),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => SizedBox(height: 10),
              itemBuilder: (context, index) {
                final app = filtered[index];
                return Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.colors.cardBackground,
                    border: Border.all(color: context.colors.borderSubtle),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => widget.onSelectApp(app.name),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.colors.surfaceFill,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(app.icon, size: 18, color: app.accentColor),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => widget.onSelectApp(app.name),
                          borderRadius: BorderRadius.circular(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.name,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                app.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: context.colors.textFaint),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Toggle(on: app.enabled, onChanged: () => _toggleApp(app.name)),
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right, size: 16, color: context.colors.textPlaceholder),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_showAdd)
            Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  border: Border.all(color: context.colors.borderInput),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _InlineInput(controller: _newAppNameController, hint: 'App name'),
                    SizedBox(height: 10),
                    _InlineInput(controller: _newAppDescController, hint: 'Description (optional)'),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _showAdd = false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.colors.textSecondary,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _addApp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            child: Text('Add app', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _showAdd = !_showAdd),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: Icon(Icons.add, size: 18),
              label: Text('Add app', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineInput extends StatelessWidget {
  _InlineInput({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.colors.inputBackground,
        border: Border.all(color: context.colors.borderInput),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: hint,
          hintStyle: TextStyle(color: context.colors.textPlaceholder, fontSize: 13),
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 13, color: context.colors.textPrimary),
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
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: Icon(Icons.arrow_back, size: 20, color: context.colors.textSecondary),
      ),
    );
  }
}
