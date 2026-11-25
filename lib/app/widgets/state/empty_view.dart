import 'package:flutter/material.dart';

import 'state_message.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.accent,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return StateMessage(
      icon: icon,
      title: title,
      message: message,
      action: action,
      accent: accent,
    );
  }
}
