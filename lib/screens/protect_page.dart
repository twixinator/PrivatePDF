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
import '../services/pdf_service.dart';
import '../services/download_service.dart';
import '../services/analytics_service.dart';
import '../services/operation_queue_service.dart';
import '../services/network_verification_service.dart';
import '../core/di/service_locator.dart';

/// Protect page - Add password protection to a PDF
class ProtectPage extends StatelessWidget {
  const ProtectPage({super.key});

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
      child: const _ProtectPageContent(),
    );
  }
}

class _ProtectPageContent extends StatefulWidget {
  const _ProtectPageContent();

  @override
  State<_ProtectPageContent> createState() => _ProtectPageContentState();
}

class _ProtectPageContentState extends State<_ProtectPageContent> {
  PdfFileInfo? _selectedFile;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                            Strings.protectPageTitle,
                            style: isDesktop
                                ? theme.textTheme.displaySmall
                                : theme.textTheme.headlineLarge,
                          ),

                          SizedBox(height: Spacing.md),

                          // Instructions
                          Text(
                            Strings.protectInstructions,
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

                          // Password input (if file selected)
                          if (_selectedFile != null) ...[
                            SizedBox(height: Spacing.xxxl),
                            _buildPasswordInputs(theme),
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
                _passwordController.clear();
                _confirmPasswordController.clear();
                _passwordError = null;
                _confirmPasswordError = null;
              });
            },
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: Text(Strings.buttonChange),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInputs(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.passwordLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.sm),
        Text(
          Strings.passwordRequired,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        SizedBox(height: Spacing.md),

        // Password field
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: Strings.passwordHint,
            errorText: _passwordError,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          onChanged: (_) {
            setState(() {
              _passwordError = null;
            });
          },
        ),

        SizedBox(height: Spacing.lg),

        // Confirm password field
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            hintText: Strings.passwordConfirmHint,
            errorText: _confirmPasswordError,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          onChanged: (_) {
            setState(() {
              _confirmPasswordError = null;
            });
          },
        ),

        SizedBox(height: Spacing.md),

        // Security notice
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
                  Strings.passwordLocalNotice,
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
          onPressed: operation.state.isProcessing ? null : _handleProtect,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xxl,
              vertical: Spacing.md,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 18),
              SizedBox(width: Spacing.sm),
              Text(Strings.protectButton),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleProtect() async {
    if (_selectedFile == null) return;

    // Clear previous errors
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // Validate password
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      setState(() {
        _passwordError = Strings.passwordErrorEmpty;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _passwordError = Strings.passwordErrorTooShort;
      });
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = Strings.passwordErrorConfirmEmpty;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _confirmPasswordError = Strings.errorPasswordMismatch;
      });
      return;
    }

    // Protect PDF
    final operation = context.read<PdfOperationProvider>();
    await operation.protectPdf(_selectedFile!, password);

    // 🔒 SECURITY: Clear passwords from memory immediately after use
    _passwordController.clear();
    _confirmPasswordController.clear();
  }
}
