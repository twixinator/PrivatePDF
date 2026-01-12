import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:provider/provider.dart';
import '../models/pdf_file_info.dart';
import '../services/file_picker_service.dart';
import '../core/di/service_locator.dart';
import '../theme/app_theme.dart';

/// Drop zone widget for selecting PDF files
/// Supports both drag-and-drop and file picker
class PdfDropZone extends StatefulWidget {
  final Function(List<PdfFileInfo>) onFilesSelected;
  final bool allowMultiple;
  final String title;
  final String subtitle;
  final String buttonText;

  const PdfDropZone({
    super.key,
    required this.onFilesSelected,
    this.allowMultiple = true,
    this.title = 'Dateien hierher ziehen',
    this.subtitle = 'oder klicken zum Auswählen',
    this.buttonText = 'PDF auswählen',
  });

  @override
  State<PdfDropZone> createState() => _PdfDropZoneState();
}

class _PdfDropZoneState extends State<PdfDropZone> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragOver = true),
      onDragExited: (_) => setState(() => _isDragOver = false),
      onDragDone: (details) async {
        setState(() => _isDragOver = false);
        await _handleDroppedFiles(details);
      },
      child: GestureDetector(
        onTap: _pickFiles,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isDesktop ? 280 : 220,
          decoration: BoxDecoration(
            color: _isDragOver
                ? AppTheme.primary.withOpacity(0.05)
                : AppTheme.surface,
            border: Border.all(
              color: _isDragOver ? AppTheme.primary : AppTheme.border,
              width: _isDragOver ? 2 : 1,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Upload icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.upload_file_outlined,
                    size: 40,
                    color: AppTheme.primary,
                  ),
                ),

                SizedBox(height: Spacing.lg),

                // Select button
                ElevatedButton(
                  onPressed: _pickFiles,
                  child: Text(widget.buttonText),
                ),

                SizedBox(height: Spacing.md),

                // Instructions
                Text(
                  widget.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: Spacing.xs),

                Text(
                  widget.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),

                SizedBox(height: Spacing.md),

                // Free tier notice
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.1),
                    border: Border.all(
                      color: AppTheme.secondary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Kostenlos: Max. 10 Dateien à 5 MB',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle file picker selection
  Future<void> _pickFiles() async {
    final filePicker = getIt<FilePickerService>();

    final files = widget.allowMultiple
        ? await filePicker.pickMultiplePdfs()
        : [(await filePicker.pickSinglePdf())]
            .whereType<PdfFileInfo>()
            .toList();

    if (files.isNotEmpty) {
      widget.onFilesSelected(files);
    }
  }

  /// Handle drag and drop files
  Future<void> _handleDroppedFiles(DropDoneDetails details) async {
    final files = <PdfFileInfo>[];

    for (final file in details.files) {
      try {
        // Read file bytes
        final bytes = await file.readAsBytes();
        final fileName = file.name;

        // Only accept PDF files
        if (!fileName.toLowerCase().endsWith('.pdf')) {
          continue;
        }

        // Create PdfFileInfo
        final pdfFile = PdfFileInfo(
          id: '${DateTime.now().millisecondsSinceEpoch}_$fileName',
          name: fileName,
          sizeBytes: bytes.length,
          bytes: bytes,
        );

        files.add(pdfFile);
      } catch (e) {
        print('[PdfDropZone] Error reading file: $e');
      }
    }

    if (files.isNotEmpty) {
      widget.onFilesSelected(files);
    }
  }
}
