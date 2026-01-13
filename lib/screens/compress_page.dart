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
import '../models/compression_quality.dart';
import '../services/pdf_service.dart';
import '../services/download_service.dart';
import '../services/analytics_service.dart';
import '../services/operation_queue_service.dart';
import '../services/network_verification_service.dart';
import '../core/di/service_locator.dart';

/// Compress page - Reduce PDF file size through image compression
class CompressPage extends StatelessWidget {
  const CompressPage({super.key});

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
      child: const _CompressPageContent(),
    );
  }
}

class _CompressPageContent extends StatefulWidget {
  const _CompressPageContent();

  @override
  State<_CompressPageContent> createState() => _CompressPageContentState();
}

class _CompressPageContentState extends State<_CompressPageContent> {
  PdfFileInfo? _selectedFile;
  CompressionQuality _selectedQuality = CompressionQuality.medium;

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
                            Strings.compressPageTitle,
                            style: isDesktop
                                ? theme.textTheme.displaySmall
                                : theme.textTheme.headlineLarge,
                          ),

                          SizedBox(height: Spacing.md),

                          // Instructions
                          Text(
                            Strings.compressInstructions,
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
                              buttonText: Strings.compressSelectFile,
                            )
                          else
                            _buildSelectedFile(theme),

                          // Quality selector (if file selected)
                          if (_selectedFile != null) ...[
                            SizedBox(height: Spacing.xxxl),
                            _buildQualitySelector(theme),
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
                Row(
                  children: [
                    Text(
                      Strings.compressOriginalSize,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                    SizedBox(width: Spacing.xs),
                    Text(
                      _selectedFile!.formattedSize,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Change button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedFile = null;
              });
            },
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: Text(Strings.buttonChange),
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.compressQualityLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.md),

        // Quality options
        ...CompressionQuality.values.map((quality) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedQuality = quality;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: _selectedQuality == quality
                      ? AppTheme.primary.withOpacity(0.1)
                      : AppTheme.surface,
                  border: Border.all(
                    color: _selectedQuality == quality
                        ? AppTheme.primary
                        : AppTheme.border,
                    width: _selectedQuality == quality ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Radio button
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedQuality == quality
                              ? AppTheme.primary
                              : AppTheme.border,
                          width: 2,
                        ),
                        color: _selectedQuality == quality
                            ? AppTheme.primary
                            : Colors.transparent,
                      ),
                      child: _selectedQuality == quality
                          ? Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                    ),

                    SizedBox(width: Spacing.md),

                    // Label and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quality.displayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: _selectedQuality == quality
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: _selectedQuality == quality
                                  ? AppTheme.primary
                                  : AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: Spacing.xs),
                          Text(
                            quality.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        SizedBox(height: Spacing.md),

        // Info notice
        Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: AppTheme.info.withOpacity(0.1),
            border: Border.all(color: AppTheme.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.info, size: 20),
              SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  'Die Kompression erfolgt ausschließlich auf deinem Gerät. Keine Daten werden hochgeladen.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.info,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(PdfOperationProvider operation) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: operation.state.isProcessing ? null : _handleCompress,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xxl,
              vertical: Spacing.md,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.compress, size: 18),
              SizedBox(width: Spacing.sm),
              Text(Strings.compressButton),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleCompress() async {
    if (_selectedFile == null) return;

    // Compress PDF
    final operation = context.read<PdfOperationProvider>();
    await operation.compressPdf(_selectedFile!, _selectedQuality);
  }
}
