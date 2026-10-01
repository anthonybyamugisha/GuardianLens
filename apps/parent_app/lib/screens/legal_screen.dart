import 'package:flutter/material.dart';

import '../theme.dart';

class LegalSection {
  const LegalSection(this.title, this.body);

  final String title;
  final List<String> body;
}

class LegalScreen extends StatelessWidget {
  const LegalScreen({
    super.key,
    required this.title,
    required this.updated,
    required this.sections,
    required this.onBack,
  });

  final String title;
  final String updated;
  final List<LegalSection> sections;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.colors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.arrow_back, size: 20, color: context.colors.textPrimary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.02,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.borderInput),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlueLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Last updated: $updated',
                        style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  for (final section in sections) ...[
                    Text(
                      section.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.01,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final paragraph in section.body) ...[
                      Text(
                        paragraph,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.7,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const privacyPolicySections = <LegalSection>[
  LegalSection('Introduction', [
    'GuardianLens helps parents stay aware of their child\u2019s digital activity. This Privacy Policy explains what information we collect, why we collect it, and how you can control it.',
  ]),
  LegalSection('Information we collect', [
    'Account information: your name, email address, and password (stored securely and hashed).',
    'Device information: the pairing code and connection between your account and your child\u2019s device.',
    'Usage data: timestamps of paired sessions so the app can show activity summaries. We do not read message contents.',
  ]),
  LegalSection('How we use your information', [
    'We use your information to operate the service, to pair and display devices, to keep the app secure, and to improve the experience. We never sell your personal data.',
  ]),
  LegalSection('How we protect it', [
    'All communication between the app and our servers is encrypted. Access to your account requires your password, and you can sign out or remove paired devices at any time.',
  ]),
  LegalSection('Your rights', [
    'You can request a copy of your data, ask us to delete your account, or contact support at any time. When you delete your account, paired devices are unlinked within a reasonable period.',
  ]),
  LegalSection('Contact', [
    'Questions about this policy? Email support@guardianlens.com and we will respond as soon as possible.',
  ]),
];

const termsOfServiceSections = <LegalSection>[
  LegalSection('Acceptance of terms', [
    'By creating a GuardianLens account you agree to these terms. You confirm you are a parent or legal guardian of the person whose device you plan to pair.',
  ]),
  LegalSection('Use of the service', [
    'GuardianLens is intended for lawful monitoring of devices you own or have legal authority to monitor. You agree not to use the app to violate anyone\u2019s privacy where prohibited by law.',
  ]),
  LegalSection('Account responsibilities', [
    'You must keep your password confidential and tell us if you suspect unauthorised use. You are responsible for activity under your account.',
  ]),
  LegalSection('Available features', [
    'The app provides activity summaries, screen-time insights, and scheduling tools. Features may change over time as we improve the product.',
  ]),
  LegalSection('Limitation of liability', [
    'The service is provided as-is. To the fullest extent permitted by law, GuardianLens is not liable for indirect or incidental damages arising from use of the app.',
  ]),
  LegalSection('Changes to these terms', [
    'We may update these terms. Significant changes will be flagged in the app before they take effect. Continued use means you accept the updated terms.',
  ]),
  LegalSection('Contact', [
    'Questions about these terms? Email support@guardianlens.com.',
  ]),
];