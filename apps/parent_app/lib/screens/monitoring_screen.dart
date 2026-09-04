import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/toggle.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({
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
        accentColor: AppColors.textPrimary,
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _BackButton(onTap: widget.onBack),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GuardianLens',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textFaint),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Monitoring',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.04,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.borderInput),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16, color: AppColors.textFaint),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        hintText: 'Search apps...',
                        hintStyle: TextStyle(color: AppColors.textPlaceholder, fontSize: 14),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Monitored apps',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const Spacer(),
                Text(
                  '$activeCount of ${widget.apps.length} active',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textFaint),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final app = filtered[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.borderSubtle),
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
                            color: AppColors.surfaceFill,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(app.icon, size: 18, color: app.accentColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => widget.onSelectApp(app.name),
                          borderRadius: BorderRadius.circular(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                app.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: AppColors.textFaint),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Toggle(on: app.enabled, onChanged: () => _toggleApp(app.name)),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, size: 16, color: AppColors.textPlaceholder),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_showAdd)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.borderInput),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _InlineInput(controller: _newAppNameController, hint: 'App name'),
                    const SizedBox(height: 10),
                    _InlineInput(controller: _newAppDescController, hint: 'Description (optional)'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _showAdd = false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _addApp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            child: const Text('Add app', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _showAdd = !_showAdd),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add app', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineInput extends StatelessWidget {
  const _InlineInput({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        border: Border.all(color: AppColors.borderInput),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontSize: 13),
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textSecondary),
      ),
    );
  }
}
