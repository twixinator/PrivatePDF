import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../constants/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../widgets/pdf_drop_zone.dart';
import '../models/pdf_file_info.dart';
import '../models/ocr_language.dart';
import '../models/ocr_result.dart';
import '../services/ocr_service.dart';
import '../services/analytics_service.dart';
import '../core/di/service_locator.dart';

/// OCR page - Extract text from scanned PDFs using Optical Character Recognition
class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  PdfFileInfo? _selectedFile;
  OcrLanguage _selectedLanguage = OcrLanguage.german;
  OcrResult? _ocrResult;
  bool _isProcessing = false;
  double _progressPercent = 0.0;
  int _currentPage = 0;
  int _totalPages = 0;
  String _progressStatus = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late final OcrService _ocrService;
  late final AnalyticsProvider _analytics;

  @override
  void initState() {
    super.initState();
    _ocrService = OcrService();
    _analytics = getIt<AnalyticsProvider>();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<void> _startOcr() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
      _ocrResult = null;
      _progressPercent = 0.0;
      _currentPage = 0;
      _totalPages = 0;
      _progressStatus = '';
    });

    try {
      // TODO: Add OCR-specific analytics events
      // _analytics.logEvent(AnalyticsEvent(...));

      final result = await _ocrService.extractTextFromPdf(
        file: _selectedFile!,
        language: _selectedLanguage,
        onProgress: (current, total, status, progress) {
          setState(() {
            _currentPage = current;
            _totalPages = total;
            _progressStatus = status;
            _progressPercent = progress;
          });
        },
      );

      setState(() {
        _ocrResult = result;
        _isProcessing = false;
      });

      // TODO: Add OCR-specific analytics events

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Strings.ocrSuccess),
            backgroundColor: Colors.green[700],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      // TODO: Add OCR-specific analytics events

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler bei der Texterkennung: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  void _copyToClipboard() {
    if (_ocrResult == null) return;

    Clipboard.setData(ClipboardData(text: _ocrResult!.fullText));
    // TODO: Add OCR-specific analytics events

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(Strings.ocrCopiedToClipboard),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _downloadAsText() {
    if (_ocrResult == null) return;

    // Create text file and trigger download
    final textContent = _ocrResult!.fullText;
    final fileName = _selectedFile?.name.replaceAll('.pdf', '_ocr.txt') ?? 'ocr_text.txt';

    // Use download service (would need to implement text download)
    // For now, log the event
    // TODO: Add OCR-specific analytics events

    // In a real implementation, you'd use the DownloadService
    // to trigger a browser download of the text file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download-Funktion wird implementiert...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetOcr() {
    setState(() {
      _selectedFile = null;
      _ocrResult = null;
      _isProcessing = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      constraints: const BoxConstraints(maxWidth: 1000),
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
                            Strings.ocrPageTitle,
                            style: isDesktop
                                ? theme.textTheme.displaySmall
                                : theme.textTheme.headlineLarge,
                          ),

                          SizedBox(height: Spacing.md),

                          // Instructions
                          Text(
                            Strings.ocrInstructions,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),

                          SizedBox(height: Spacing.md),

                          // Warning about processing time
                          Container(
                            padding: const EdgeInsets.all(Spacing.md),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              border: Border.all(color: Colors.amber[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.amber[800]),
                                SizedBox(width: Spacing.sm),
                                Expanded(
                                  child: Text(
                                    Strings.ocrWarningTime,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.amber[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: Spacing.xxxl),

                          // Main content area
                          if (_ocrResult == null) ...[
                            // File selection and language selector
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
                                buttonText: Strings.ocrSelectFile,
                              )
                            else
                              _buildSelectedFile(theme),

                            // Language selector (if file selected)
                            if (_selectedFile != null) ...[
                              SizedBox(height: Spacing.xxxl),
                              _buildLanguageSelector(theme),
                              SizedBox(height: Spacing.xl),
                              _buildActionButtons(),
                            ],
                          ] else ...[
                            // OCR Results display
                            _buildOcrResults(theme, isDesktop),
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

          // Processing overlay
          if (_isProcessing) _buildProcessingOverlay(theme),
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
            child: const Icon(
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
              });
            },
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: const Text(Strings.buttonChange),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.ocrLanguageLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.xs),
        Text(
          Strings.ocrLanguageHelper,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        SizedBox(height: Spacing.md),

        // Language radio buttons
        ...OcrLanguage.values.map((language) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedLanguage = language;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: _selectedLanguage == language
                      ? AppTheme.primary.withOpacity(0.05)
                      : AppTheme.surface,
                  border: Border.all(
                    color: _selectedLanguage == language
                        ? AppTheme.primary
                        : AppTheme.border,
                    width: _selectedLanguage == language ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Radio<OcrLanguage>(
                      value: language,
                      groupValue: _selectedLanguage,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedLanguage = value;
                          });
                        }
                      },
                    ),
                    SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        language.displayName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: _selectedLanguage == language
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        SizedBox(height: Spacing.md),

        // Quality tip
        Container(
          padding: const EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            border: Border.all(color: AppTheme.success.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppTheme.success, size: 18),
              SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  Strings.ocrQualityTip,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _startOcr,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
        ),
        child: const Text(
          Strings.ocrButton,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay(ThemeData theme) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(Spacing.xl),
          padding: const EdgeInsets.all(Spacing.xxl),
          decoration: BoxDecoration(
            color: AppTheme.background,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
              SizedBox(height: Spacing.xl),
              Text(
                Strings.ocrButton,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Spacing.md),
              if (_totalPages > 0)
                Text(
                  Strings.ocrProcessing
                      .replaceAll('{current}', _currentPage.toString())
                      .replaceAll('{total}', _totalPages.toString()),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              if (_progressStatus.isNotEmpty) ...[
                SizedBox(height: Spacing.sm),
                Text(
                  Strings.ocrProcessingStatus
                      .replaceAll('{status}', _progressStatus),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: Spacing.lg),
              LinearProgressIndicator(
                value: _progressPercent / 100,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                backgroundColor: AppTheme.border,
              ),
              SizedBox(height: Spacing.xs),
              Text(
                '${_progressPercent.toStringAsFixed(0)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOcrResults(ThemeData theme, bool isDesktop) {
    final result = _ocrResult!;
    final displayText = _searchQuery.isEmpty
        ? result.fullText
        : _highlightSearchResults(result.fullText, _searchQuery);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Result summary
        Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            border: Border.all(color: AppTheme.success.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.success),
                  SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      Strings.ocrSuccess,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Spacing.md),
              Text(
                result.summary,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        SizedBox(height: Spacing.xl),

        // Action buttons row
        Wrap(
          spacing: Spacing.md,
          runSpacing: Spacing.md,
          children: [
            ElevatedButton.icon(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy, size: 18),
              label: const Text(Strings.ocrCopyButton),
            ),
            ElevatedButton.icon(
              onPressed: _downloadAsText,
              icon: const Icon(Icons.download, size: 18),
              label: const Text(Strings.ocrDownloadButton),
            ),
            OutlinedButton.icon(
              onPressed: _resetOcr,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(Strings.ocrNewScan),
            ),
          ],
        ),

        SizedBox(height: Spacing.xl),

        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: Strings.ocrSearchLabel,
            hintText: Strings.ocrSearchPlaceholder,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
        ),

        SizedBox(height: Spacing.lg),

        // Results title
        Text(
          Strings.ocrResultTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: Spacing.md),

        // Text display area
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 300, maxHeight: 600),
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border.all(color: AppTheme.border),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              displayText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _highlightSearchResults(String text, String query) {
    // Simple search highlighting (in a real app, you'd use a proper highlighting widget)
    return text;
  }
}
