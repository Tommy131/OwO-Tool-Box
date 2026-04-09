import 'package:flutter/material.dart';

/// A CNF file editor with line numbers, scrollbar and monospace styling.
class CnfEditor extends StatelessWidget {
  const CnfEditor({
    super.key,
    required this.controller,
    required this.scrollController,
  });

  final TextEditingController controller;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PrimaryScrollController.none(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Line numbers gutter
            Container(
              width: 56,
              padding: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.15,
                ),
                border: Border(
                  right: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: scrollController,
                  builder: (context, child) {
                    final offset = scrollController.hasClients
                        ? scrollController.offset
                        : 0.0;
                    return Transform.translate(
                      offset: Offset(0, -offset),
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.5),
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, _, __) {
                        final lines = controller.text.split('\n').length;
                        return OverflowBox(
                          alignment: Alignment.topRight,
                          minHeight: 0,
                          maxHeight: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (int i = 1; i <= lines; i++)
                                Text(
                                  '$i',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.45),
                                    height: 1.4,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Editor area
            Expanded(
              child: Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                child: TextField(
                  controller: controller,
                  scrollController: scrollController,
                  scrollPhysics: const ClampingScrollPhysics(),
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.4,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A styled toolbar button that can be elevated, outlined or tonal.
Widget buildToolbarButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
  required ThemeData theme,
  bool outlined = false,
  bool tonal = false,
}) {
  if (tonal) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: FilledButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
  if (outlined) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 16),
    label: Text(label, style: const TextStyle(fontSize: 12)),
    style: ElevatedButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
  );
}
