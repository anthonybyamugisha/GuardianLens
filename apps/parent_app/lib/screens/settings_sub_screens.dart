import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/toggle.dart';

class SettingsSubScreen extends StatelessWidget {
  SettingsSubScreen({
    super.key,
    required this.title,
    required this.onBack,
    required this.child,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _BackButton(onTap: onBack),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.03,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class SettingsDevicesScreen extends StatelessWidget {
  SettingsDevicesScreen({
    super.key,
    required this.paired,
    required this.onAddDevice,
    required this.onBack,
  });

  final bool paired;
  final VoidCallback onAddDevice;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SettingsSubScreen(
      title: 'Paired devices',
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.blueSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.smartphone, color: AppColors.primaryBlueLight, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alex\u2019s iPhone',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        paired ? 'Connected \u00b7 Synced just now' : 'Not connected',
                        style: TextStyle(
                          fontSize: 12,
                          color: paired ? AppColors.successGreen : context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, size: 18, color: AppColors.successGreen),
              ],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAddDevice,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: Icon(Icons.add, size: 17),
            label: Text('Add new device', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class SettingsToggleRow extends StatelessWidget {
  SettingsToggleRow({
    super.key,
    required this.title,
    required this.detail,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String detail;
  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        border: Border.all(color: context.colors.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  detail,
                  style: TextStyle(fontSize: 12, height: 1.6, color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Toggle(on: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  NotificationSettingsScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _push = true;
  bool _summary = true;

  @override
  Widget build(BuildContext context) {
    return SettingsSubScreen(
      title: 'Notifications',
      onBack: widget.onBack,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SettingsToggleRow(
              title: 'Push notifications',
              detail: 'Real-time alerts for concerning activity',
              value: _push,
              onChanged: () => setState(() => _push = !_push),
            ),
          ),
          SettingsToggleRow(
            title: 'Email summaries',
            detail: 'Weekly wrap-ups of digital wellbeing',
            value: _summary,
            onChanged: () => setState(() => _summary = !_summary),
          ),
        ],
      ),
    );
  }
}

class PrivacySettingsScreen extends StatefulWidget {
  PrivacySettingsScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _paused = false;
  bool _confirmDelete = false;

  @override
  Widget build(BuildContext context) {
    return SettingsSubScreen(
      title: 'Data & privacy',
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.cardBackground,
              border: Border.all(color: context.colors.borderSubtle),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pause monitoring',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  'Temporarily stop monitoring all paired devices.',
                  style: TextStyle(fontSize: 12, height: 1.6, color: context.colors.textSecondary),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _paused = !_paused),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _paused ? context.colors.softGreenSurface : context.colors.buttonGrey,
                    foregroundColor: _paused ? AppColors.successGreen : AppColors.primaryBlue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _paused ? 'Monitoring paused' : 'Pause monitoring',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.redCard,
              border: Border.all(color: context.colors.redCardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Delete account',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.dangerRedLight),
                ),
                SizedBox(height: 4),
                Text(
                  'Permanently remove your account, devices, and history.',
                  style: TextStyle(fontSize: 12, height: 1.6, color: context.colors.textSecondary),
                ),
                SizedBox(height: 16),
                if (_confirmDelete)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _confirmDelete = false),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: context.colors.cardBackground,
                            foregroundColor: context.colors.textSecondary,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(color: context.colors.borderInput),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.dangerRedLight,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: Text('Delete permanently', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: () => setState(() => _confirmDelete = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.redSurface,
                      foregroundColor: AppColors.dangerRedLight,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Delete account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
        ],
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
