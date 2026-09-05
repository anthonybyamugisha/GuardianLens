import 'package:flutter/material.dart';

import '../theme.dart';

class Toggle extends StatelessWidget {
  Toggle({super.key, required this.on, required this.onChanged});

  final bool on;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 44,
        height: 24,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: on ? AppColors.successGreen : context.colors.toggleOff,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 200),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
