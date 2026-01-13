import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'screens/landing_page.dart';
import 'screens/merge_page.dart';
import 'screens/split_page.dart';
import 'screens/protect_page.dart';
import 'screens/compress_page.dart';
import 'screens/ocr_page.dart';
import 'screens/pricing_page.dart';
import 'screens/impressum_page.dart';
import 'screens/datenschutz_page.dart';
import 'screens/agb_page.dart';
import 'screens/kontakt_page.dart';
import 'core/di/service_locator.dart';
import 'animations/page_transitions.dart';
import 'services/network_verification_service.dart';

void main() {
  // Initialize dependency injection
  setupServiceLocator();

  // 🔒 SECURITY: Setup network monitoring interceptor
  NetworkInterceptor.setupInterceptor(getIt<NetworkVerificationService>());

  runApp(const PrivatPdfApp());
}

class PrivatPdfApp extends StatelessWidget {
  const PrivatPdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PrivatPDF - PDF bearbeiten, 100% privat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}

/// App routing configuration with page transitions
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Landing page - Simple fade
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => PageTransitions.fade(
        child: const LandingPage(),
        state: state,
      ),
    ),

    // Tool pages - Scale + fade transition
    GoRoute(
      path: '/merge',
      pageBuilder: (context, state) => PageTransitions.scaleFade(
        child: const MergePage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/split',
      pageBuilder: (context, state) => PageTransitions.scaleFade(
        child: const SplitPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/protect',
      pageBuilder: (context, state) => PageTransitions.scaleFade(
        child: const ProtectPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/compress',
      pageBuilder: (context, state) => PageTransitions.scaleFade(
        child: const CompressPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/ocr',
      pageBuilder: (context, state) => PageTransitions.scaleFade(
        child: const OcrPage(),
        state: state,
      ),
    ),

    // Pricing page - Slide up (modal-like)
    GoRoute(
      path: '/pricing',
      pageBuilder: (context, state) => PageTransitions.fadeSlideUp(
        child: const PricingPage(),
        state: state,
      ),
    ),

    // Legal/Informational pages - Simple fade transition
    GoRoute(
      path: '/impressum',
      pageBuilder: (context, state) => PageTransitions.fade(
        child: const ImpressumPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/datenschutz',
      pageBuilder: (context, state) => PageTransitions.fade(
        child: const DatenschutzPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/agb',
      pageBuilder: (context, state) => PageTransitions.fade(
        child: const AgbPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/kontakt',
      pageBuilder: (context, state) => PageTransitions.fade(
        child: const KontaktPage(),
        state: state,
      ),
    ),
  ],
  errorPageBuilder: (context, state) => PageTransitions.fade(
    child: const NotFoundPage(),
    state: state,
  ),
);

/// Placeholder page for routes under development
class PlaceholderPage extends StatelessWidget {
  final String title;
  final String description;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 64,
              color: AppTheme.textMuted,
            ),
            SizedBox(height: Spacing.lg),
            Text(
              description,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: Spacing.xl),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Zurück zur Startseite'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 404 Not Found page
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '404',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
            SizedBox(height: Spacing.md),
            Text(
              'Seite nicht gefunden',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: Spacing.xl),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Zurück zur Startseite'),
            ),
          ],
        ),
      ),
    );
  }
}
