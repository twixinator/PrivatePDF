import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../widgets/pdf_drop_zone.dart';
import '../widgets/reorderable_file_list.dart';
import '../widgets/merge_action_bar.dart';
import '../widgets/operation_overlay.dart';
import '../providers/file_list_provider.dart';
import '../providers/pdf_operation_provider.dart';
import '../services/pdf_service.dart';
import '../services/download_service.dart';
import '../services/analytics_service.dart';
import '../services/operation_queue_service.dart';
import '../services/network_verification_service.dart';
import '../core/di/service_locator.dart';

/// Merge page with clean architecture implementation
class MergePage extends StatelessWidget {
  const MergePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FileListProvider()),
        ChangeNotifierProvider(
          create: (_) => PdfOperationProvider(
            pdfService: getIt<PdfService>(),
            downloadService: getIt<DownloadService>(),
            analytics: getIt<AnalyticsProvider>(),
            queueService: getIt<OperationQueueService>(),
            networkVerification: getIt<NetworkVerificationService>(),
          ),
        ),
      ],
      child: const _MergePageContent(),
    );
  }
}

class _MergePageContent extends StatelessWidget {
  const _MergePageContent();

  @override
  Widget build(BuildContext context) {
    final fileList = context.watch<FileListProvider>();
    final operation = context.watch<PdfOperationProvider>();
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;
    final isTablet = screenWidth >= Breakpoints.tablet;

    return Scaffold(
      appBar: const AppHeader(),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 80 - 400,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop
                        ? Spacing.massive
                        : (isTablet ? Spacing.xxxl : Spacing.lg),
                    vertical: isDesktop ? Spacing.xxxl : Spacing.xl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          TextButton.icon(
                            onPressed: () => context.go('/'),
                            icon: const Icon(Icons.arrow_back, size: 20),
                            label: const Text(Strings.buttonBack),
                          ),

                          SizedBox(height: Spacing.xl),

                          // Page title
                          Text(
                            Strings.mergePageTitle,
                            style: isDesktop
                                ? theme.textTheme.displaySmall
                                : theme.textTheme.headlineLarge,
                          ),

                          SizedBox(height: Spacing.md),

                          // Instructions
                          Text(
                            Strings.mergeInstructions,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),

                          SizedBox(height: Spacing.xxxl),

                          // Drop zone
                          PdfDropZone(
                            onFilesSelected: (files) {
                              fileList.addFiles(files);
                            },
                            allowMultiple: true,
                            title: Strings.mergeDragDrop,
                            subtitle: Strings.mergeMultipleAllowed,
                            buttonText: Strings.mergeSelectFiles,
                          ),

                          // File list (if files selected)
                          if (fileList.hasFiles) ...[
                            SizedBox(height: Spacing.xxxl),
                            ReorderableFileList(
                              files: fileList.files,
                              onRemove: (fileId) => fileList.removeFile(fileId),
                              onReorder: (oldIndex, newIndex) =>
                                  fileList.reorderFiles(oldIndex, newIndex),
                            ),
                          ],

                          // Action bar (if can merge)
                          if (fileList.canMerge) ...[
                            SizedBox(height: Spacing.xl),
                            MergeActionBar(
                              onMerge: () {
                                operation.mergePdfs(fileList.files);
                              },
                              onClear: () => fileList.clear(),
                              canMerge: !operation.state.isProcessing,
                            ),
                          ],

                          // Helper text for file count
                          if (fileList.hasFiles && !fileList.canMerge) ...[
                            SizedBox(height: Spacing.lg),
                            Container(
                              padding: const EdgeInsets.all(Spacing.md),
                              decoration: BoxDecoration(
                                color: AppTheme.warning.withOpacity(0.1),
                                border: Border.all(
                                  color: AppTheme.warning.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppTheme.warning,
                                    size: 20,
                                  ),
                                  SizedBox(width: Spacing.sm),
                                  Expanded(
                                    child: Text(
                                      fileList.fileCount < 2
                                          ? Strings.mergeMinimumRequired
                                          : Strings.mergeMaximumAllowed,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppTheme.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                const AppFooter(),
              ],
            ),
          ),

          // Operation overlay
          if (!operation.state.isIdle)
            OperationOverlay(
              state: operation.state,
              provider: operation,
            ),
        ],
      ),
    );
  }
}
