import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// When true, shows a progress spinner in place of the icon and ignores
  /// taps, so duplicate submissions are prevented while a task is pending.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = FilledButton.styleFrom(
      minimumSize: const Size(220, 50),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );

    final Widget labelWidget = Text(label);

    final Widget buttonChild = busy
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              labelWidget,
            ],
          )
        : icon == null
        ? labelWidget
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              labelWidget,
            ],
          );

    return Opacity(
      opacity: busy ? 0.75 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppConstants.brandGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppConstants.brandGradient.first.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: busy ? null : onPressed,
          style: style,
          child: buttonChild,
        ),
      ),
    );
  }
}
