import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/utils/responsive_utils.dart';

class Header extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final bool compact;
  
  const Header({
    super.key, 
    this.onMenuPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isMobile = context.isMobile;
    final showMenuButton = onMenuPressed != null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : (isMobile ? 12 : 24)),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          // Menu button for mobile/landscape
          if (showMenuButton) ...[
            IconButton(
              icon: Icon(LucideIcons.menu, size: compact ? 18 : 22),
              onPressed: onMenuPressed,
              padding: compact ? const EdgeInsets.all(4) : null,
              constraints: compact ? const BoxConstraints() : null,
            ),
            SizedBox(width: compact ? 4 : 8),
          ],
          
          const Spacer(),
          
          // Shift Info - hide on mobile or compact height
          if (!isMobile && !compact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔔 '),
                  Text(
                    'Shift: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    'Pagi',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // User Info
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMobile && !compact)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Admin User',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              SizedBox(width: (isMobile || compact) ? 0 : 12),
              Container(
                width: compact ? 32 : 40,
                height: compact ? 32 : 40,
                decoration: BoxDecoration(
                  color: cs.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.user, size: compact ? 16 : 20, color: cs.onSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
