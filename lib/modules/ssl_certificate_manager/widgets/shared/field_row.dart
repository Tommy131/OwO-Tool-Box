import 'package:flutter/material.dart';

/// A responsive row of fields that adapts to available width.
/// Each field gets equal share of the row, with a minimum width constraint.
class SslFieldRow extends StatelessWidget {
  const SslFieldRow({super.key, required this.fields});

  final List<Widget> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minFieldWidth = 200.0;
        const spacing = 12.0;
        final availableWidth = constraints.maxWidth;
        // Calculate how many fields fit per row
        int perRow = fields.length;
        while (perRow > 1 &&
            (availableWidth - (perRow - 1) * spacing) / perRow <
                minFieldWidth) {
          perRow--;
        }
        if (perRow >= fields.length) {
          // All fit in one row
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < fields.length; i++) ...[
                if (i > 0) const SizedBox(width: spacing),
                Expanded(child: fields[i]),
              ],
            ],
          );
        }
        // Split into multiple rows
        final rows = <Widget>[];
        for (int i = 0; i < fields.length; i += perRow) {
          final rowFields = fields.sublist(
            i,
            (i + perRow).clamp(0, fields.length),
          );
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int j = 0; j < rowFields.length; j++) ...[
                  if (j > 0) const SizedBox(width: spacing),
                  Expanded(child: rowFields[j]),
                ],
                // Fill remaining space if last row is incomplete
                for (int j = rowFields.length; j < perRow; j++) ...[
                  const SizedBox(width: spacing),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ],
            ),
          );
        }
        return Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              if (i > 0) const SizedBox(height: 4),
              rows[i],
            ],
          ],
        );
      },
    );
  }
}
