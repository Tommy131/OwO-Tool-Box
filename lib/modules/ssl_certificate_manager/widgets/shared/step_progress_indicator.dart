import 'package:flutter/material.dart';

/// A horizontal step progress indicator with icons and titles.
class SslStepProgressIndicator extends StatelessWidget {
  const SslStepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.titles,
    required this.icons,
  });

  final int currentStep;
  final int totalSteps;
  final List<String> titles;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < totalSteps; i++) ...[
            if (i > 0)
              Container(
                width: 24,
                height: 2,
                margin: const EdgeInsets.only(bottom: 16),
                color: i <= currentStep
                    ? primary
                    : theme.dividerColor.withValues(alpha: 0.25),
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: i < currentStep
                          ? primary
                          : (i == currentStep
                              ? primary
                              : Colors.transparent),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i <= currentStep
                            ? primary
                            : theme.dividerColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: i < currentStep
                          ? Icon(Icons.check,
                              size: 15, color: theme.colorScheme.onPrimary)
                          : Icon(
                              icons[i],
                              size: 13,
                              color: i == currentStep
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.35),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    titles[i],
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: i <= currentStep
                          ? primary
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                      fontWeight: i == currentStep
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
