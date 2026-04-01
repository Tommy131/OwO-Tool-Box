import 'package:flutter/material.dart';

abstract class SidebarMiniCard {
  final String id;
  final int priority;

  SidebarMiniCard({required this.id, this.priority = 100});

  bool canDisplay(BuildContext context);

  Widget build(
    BuildContext context, {
    required ThemeData theme,
    required bool isCollapsed,
  });
}
