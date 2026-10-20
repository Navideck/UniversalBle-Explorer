import 'package:flutter/material.dart';

/// Shared header for result-style cards (e.g. Logs, Received advertisements).
/// Layout: [icon] [title] [trailing?] on the first line; a second line with
/// [Copy all] at the start and [count?] [clear?] at the end.
/// Copy, count badge, and clear button are shown only when [count] > 0.
class ResultHeaderBar extends StatelessWidget {
  const ResultHeaderBar({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    this.onCopy,
    this.copyTooltip = 'Copy',
    this.onClear,
    this.clearTooltip = 'Clear all',
    this.trailing,
    this.titleFontSize = 16,
  });

  final IconData icon;
  final String title;
  final int count;
  final VoidCallback? onCopy;
  final String copyTooltip;
  final VoidCallback? onClear;
  final String clearTooltip;
  final Widget? trailing;
  final double titleFontSize;

  bool get _hasItems => count > 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                  height: 1.2,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing!,
            ],
          ],
        ),
        if (_hasItems) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              if (onCopy != null) ...[
                Tooltip(
                  message: copyTooltip,
                  child: TextButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy all'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  onPressed: onClear,
                  tooltip: clearTooltip,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
