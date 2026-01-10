import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final bool enabled;
  final TextAlign textAlign;
  final TextStyle? style;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const AppInput({
    super.key,
    this.placeholder,
    this.controller,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.style,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      readOnly: readOnly,
      enabled: enabled,
      textAlign: textAlign,
      style: style,
      focusNode: focusNode,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: prefixIcon,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
