import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool glass;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.glass = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: glass ? theme.cardColor.withValues(alpha: 0.5) : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: glass
              ? Colors.white.withValues(alpha: 0.2)
              : theme.dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    return onTap != null ? GestureDetector(onTap: onTap, child: card) : card;
  }
}
