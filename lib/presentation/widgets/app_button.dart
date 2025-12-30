import 'package:flutter/material.dart';

enum BtnVariant { primary, destructive, outline, secondary, ghost }

enum BtnSize { sm, md, lg, icon }

class AppButton extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final BtnVariant variant;
  final BtnSize size;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.variant = BtnVariant.primary,
    this.size = BtnSize.md,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg, fg;
    Color? border;

    switch (variant) {
      case BtnVariant.primary:
        bg = cs.primary;
        fg = cs.onPrimary;
        break;
      case BtnVariant.destructive:
        bg = cs.error;
        fg = Colors.white;
        break;
      case BtnVariant.outline:
        bg = Colors.transparent;
        fg = cs.onSurface;
        border = cs.outline;
        break;
      case BtnVariant.secondary:
        bg = cs.secondary;
        fg = cs.onSecondary;
        break;
      case BtnVariant.ghost:
        bg = Colors.transparent;
        fg = cs.onSurface;
        break;
    }

    double h;
    EdgeInsets pad;

    switch (size) {
      case BtnSize.sm:
        h = 36;
        pad = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        break;
      case BtnSize.md:
        h = 40;
        pad = const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
        break;
      case BtnSize.lg:
        h = 48;
        pad = const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
        break;
      case BtnSize.icon:
        h = 40;
        pad = EdgeInsets.zero;
        break;
    }

    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) icon!,
              if (icon != null && text != null) const SizedBox(width: 8),
              if (text != null)
                Text(text!, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : (size == BtnSize.icon ? 40 : null),
      height: h,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          padding: pad,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: border != null ? BorderSide(color: border) : BorderSide.none,
          ),
        ),
        child: child,
      ),
    );
  }
}

