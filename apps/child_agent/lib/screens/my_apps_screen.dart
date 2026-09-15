import 'package:flutter/material.dart';
import '../models/child_app.dart';
import '../theme.dart';

class MyAppsScreen extends StatelessWidget {
  const MyAppsScreen({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              title: 'My Apps',
              subtitle: 'Apps protected by GuardianLens',
              onBack: onBack,
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: childApps.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final app = childApps[index];

                  return Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colors.borderSubtle,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: app.accentColor.withOpacity(.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            app.icon,
                            color: app.accentColor,
                            size: 27,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.name,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                app.description,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: app.monitored
                                ? colors.paleGreenBadge
                                : colors.chipGrey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            app.monitored ? 'Protected' : 'Off',
                            style: TextStyle(
                              color: app.monitored
                                  ? AppColors.successGreen
                                  : colors.chipTextGrey,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}