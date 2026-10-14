import 'package:flutter/material.dart';

import 'package:universal_ble_example/peripheral_details/widgets/result_header_bar.dart';

class ResultWidget extends StatelessWidget {
  final List<String> results;
  final bool scrollable;
  final ScrollController scrollController;
  final void Function(int? index) onClearTap;
  final void Function()? onCopyTap;
  final bool autoScrollLogs;
  final ValueChanged<bool>? onAutoScrollLogsChanged;

  /// When set, shows an input row that appends user-typed log entries.
  final ValueChanged<String>? onSubmitCustomLog;
  final String customLogHint;
  const ResultWidget({
    required this.results,
    required this.onClearTap,
    this.onCopyTap,
    this.scrollable = false,
    required this.scrollController,
    this.autoScrollLogs = true,
    this.onAutoScrollLogsChanged,
    this.onSubmitCustomLog,
    this.customLogHint = 'Add custom log…',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: scrollable ? MainAxisSize.max : MainAxisSize.min,
          children: [
            _buildHeader(colorScheme),
            if (results.isEmpty)
              _buildEmptyState(colorScheme)
            else
              _buildLogsList(colorScheme),
            if (onSubmitCustomLog != null)
              _CustomLogInput(
                onSubmit: onSubmitCustomLog!,
                hint: customLogHint,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: ResultHeaderBar(
        icon: Icons.history,
        title: 'Logs',
        count: results.length,
        onCopy: onCopyTap,
        copyTooltip: 'Copy all logs',
        onClear: () => onClearTap(null),
        clearTooltip: 'Clear all logs',
        trailing: onAutoScrollLogsChanged == null
            ? null
            : IconButton(
                icon: Icon(
                  Icons.vertical_align_top,
                  color: autoScrollLogs
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
                onPressed: () => onAutoScrollLogsChanged!(!autoScrollLogs),
                tooltip:
                    'Auto-scroll to top: ${autoScrollLogs ? "on" : "off"}',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    final emptyStateContent = Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 48,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No logs yet',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );

    return scrollable ? Expanded(child: emptyStateContent) : emptyStateContent;
  }

  Widget _buildLogsList(ColorScheme colorScheme) {
    final listView = ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: scrollController,
      itemCount: results.length,
      itemBuilder: (context, index) => _buildLogItem(colorScheme, index),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: colorScheme.outline.withValues(alpha: 0.2),
      ),
    );

    if (scrollable) {
      return Expanded(child: listView);
    } else {
      return Container(
        constraints: const BoxConstraints(maxHeight: 300),
        child: listView,
      );
    }
  }

  Widget _buildLogItem(ColorScheme colorScheme, int index) {
    var reversedIndex = results.length - index - 1;
    final log = results[reversedIndex];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText(
              log,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            onPressed: () => onClearTap(reversedIndex),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }
}

/// Input row that lets the user append a custom log entry.
///
/// Owns its [TextEditingController] so [ResultWidget] can stay stateless.
class _CustomLogInput extends StatefulWidget {
  const _CustomLogInput({
    required this.onSubmit,
    required this.hint,
  });

  final ValueChanged<String> onSubmit;
  final String hint;

  @override
  State<_CustomLogInput> createState() => _CustomLogInputState();
}

class _CustomLogInputState extends State<_CustomLogInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, size: 20),
            onPressed: _hasText ? _submit : null,
            tooltip: 'Add log entry',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }
}
