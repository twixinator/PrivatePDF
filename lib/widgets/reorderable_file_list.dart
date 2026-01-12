import 'package:flutter/material.dart';
import '../models/pdf_file_info.dart';
import '../theme/app_theme.dart';

/// Reorderable list of PDF files with drag-and-drop support
class ReorderableFileList extends StatelessWidget {
  final List<PdfFileInfo> files;
  final Function(String fileId) onRemove;
  final Function(int oldIndex, int newIndex) onReorder;

  const ReorderableFileList({
    super.key,
    required this.files,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with file count and total size
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dateien: ${files.length}',
              style: theme.textTheme.labelLarge,
            ),
            Text(
              'Gesamt: ${_getTotalSize()}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),

        SizedBox(height: Spacing.md),

        // Reorderable list
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            onReorder(oldIndex, newIndex);
          },
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            return _FileListItem(
              key: ValueKey(file.id),
              file: file,
              index: index,
              onRemove: () => onRemove(file.id),
            );
          },
        ),
      ],
    );
  }

  String _getTotalSize() {
    final totalBytes = files.fold<int>(0, (sum, f) => sum + f.sizeBytes);
    if (totalBytes < 1024) {
      return '$totalBytes B';
    } else if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Individual file list item
class _FileListItem extends StatelessWidget {
  final PdfFileInfo file;
  final int index;
  final VoidCallback onRemove;

  const _FileListItem({
    super.key,
    required this.file,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          // Drag handle
          Icon(
            Icons.drag_indicator,
            size: 24,
            color: AppTheme.textMuted,
          ),

          SizedBox(width: Spacing.md),

          // PDF icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.3),
              ),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              size: 20,
              color: AppTheme.primary,
            ),
          ),

          SizedBox(width: Spacing.md),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  file.formattedSize,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 20),
            color: AppTheme.error,
            tooltip: 'Entfernen',
          ),
        ],
      ),
    );
  }
}
