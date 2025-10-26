import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? color;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return Card(
      color: color,
      margin: margin,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
