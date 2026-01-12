import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../widgets/pdf_drop_zone.dart';
import '../widgets/operation_overlay.dart';
import '../providers/pdf_operation_provider.dart';
import '../models/pdf_file_info.dart';
import '../models/page_range.dart';
import '../services/pdf_service.dart';
import '../services/download_service.dart';
import '../services/analytics_service.dart';
import '../services/operation_queue_service.dart';
import '../services/network_verification_service.dart';
import '../core/di/service_locator.dart';

/// Split page - Extract specific pages from a PDF
class SplitPage extends StatelessWidget {
  const SplitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PdfOperationProvider(
        pdfService: getIt<PdfService>(),
        downloadService: getIt<DownloadService>(),
        analytics: getIt<AnalyticsProvider>(),
        queueService: getIt<OperationQueueService>(),
        networkVerification: getIt<NetworkVerificationService>(),
      ),
      child: const _SplitPageContent(),
    );
  }
}

class _SplitPageContent extends StatefulWidget {
  const _SplitPageContent();

  @override
  State<_SplitPageContent> createState() => _SplitPageContentState();
}

class _SplitPageContentState extends State<_SplitPageContent> {
  PdfFileInfo? _selectedFile;
  final _pageRangeController = TextEditingController();
  String? _pageRangeError;

  @override
  void dispose() {
    _pageRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            Strings.splitPageTitle,
                            style: isDesktop
                                ? theme.textTheme.displaySmall
                                : theme.textTheme.headlineLarge,
                          ),

                          SizedBox(height: Spacing.md),

                          // Instructions
                          Text(
                            Strings.splitInstructions,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),

                          SizedBox(height: Spacing.xxxl),

                          // Drop zone or selected file
                          if (_selectedFile == null)
                            PdfDropZone(
                              onFilesSelected: (files) {
                                if (files.isNotEmpty) {
                                  setState(() {
                                    _selectedFile = files.first;
                                  });
                                }
                              },
                              allowMultiple: false,
                              title: Strings.dropZoneTitle,
                              subtitle: Strings.dropZoneSubtitle,
                              buttonText: Strings.dropZoneButton,
                            )
                          else
                            _buildSelectedFile(theme),

                          // Page range input (if file selected)
                          if (_selectedFile != null) ...[
                            SizedBox(height: Spacing.xxxl),
                            _buildPageRangeInput(theme),
                            SizedBox(height: Spacing.xl),
                            _buildActionButtons(operation),
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

  Widget _buildSelectedFile(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          // PDF icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              size: 30,
              color: AppTheme.primary,
            ),
          ),

          SizedBox(width: Spacing.lg),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFile!.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Spacing.xs),
                Text(
                  _selectedFile!.formattedSize,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Change button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedFile = null;
                _pageRangeController.clear();
                _pageRangeError = null;
              });
            },
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: Text(Strings.buttonChange),
          ),
        ],
      ),
    );
  }

  Widget _buildPageRangeInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.pageRangeLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.sm),
        Text(
          Strings.pageRangeHelper,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        SizedBox(height: Spacing.md),
        TextField(
          controller: _pageRangeController,
          decoration: InputDecoration(
            hintText: Strings.pageRangeExample,
            errorText: _pageRangeError,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.format_list_numbered),
          ),
          onChanged: (_) {
            setState(() {
              _pageRangeError = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(PdfOperationProvider operation) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: operation.state.isProcessing ? null : _handleSplit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xxl,
              vertical: Spacing.md,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(Strings.splitButton),
              SizedBox(width: Spacing.sm),
              Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSplit() async {
    if (_selectedFile == null) return;

    final rangeText = _pageRangeController.text.trim();
    if (rangeText.isEmpty) {
      setState(() {
        _pageRangeError = Strings.pageRangeRequired;
      });
      return;
    }

    try {
      // Parse page range (assume max 1000 pages for validation)
      final range = PageRange.parse(rangeText, 1000);

      // Split PDF
      final operation = context.read<PdfOperationProvider>();
      await operation.splitPdf(_selectedFile!, range);
    } on FormatException catch (e) {
      setState(() {
        _pageRangeError = e.message;
      });
    }
  }
}
