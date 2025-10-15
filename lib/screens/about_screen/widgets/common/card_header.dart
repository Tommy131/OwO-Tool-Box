import 'package:flutter/material.dart';

class CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final double? iconSize;

  const CardHeader({
    super.key,
    required this.icon,
    required this.title,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: iconSize ?? 24,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}
