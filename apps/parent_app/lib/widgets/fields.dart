import 'package:flutter/material.dart';

import '../theme.dart';

class GLField extends StatelessWidget {
  GLField({
    super.key,
    this.label,
    required this.icon,
    this.type = TextInputType.text,
    this.obscure = false,
    required this.placeholder,
    this.controller,
    this.onChanged,
  });

  final String? label;
  final IconData icon;
  final TextInputType type;
  final bool obscure;
  final String placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: context.colors.textLightBlue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
        ],
        Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: context.colors.inputBackground,
            border: Border.all(color: context.colors.borderInput),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: context.colors.textFaint),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: type,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: placeholder,
                    hintStyle: TextStyle(
                      color: context.colors.textPlaceholder,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.expanded = true,
    this.disabled = false,
    this.loading = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool expanded;
  final bool disabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: (disabled || loading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          disabledBackgroundColor: context.colors.blueDisabled,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          shadowColor: AppColors.primaryBlue,
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 17),
                  ],
                ],
              ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.redSurface,
        border: Border.all(color: context.colors.redCardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 16, color: AppColors.dangerRedLight),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.dangerRedLight,
                fontWeight: FontWeight.w500,
              ),
            ),
),
        ],
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.color = AppColors.primaryBlue,
    this.textColor = AppColors.primaryBlueLight,
    this.borderColor,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: borderColor ?? Color(0x00000000)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            if (icon != null) ...[
              SizedBox(width: 8),
              Icon(icon, size: 17),
            ],
          ],
        ),
      ),
    );
  }
}
