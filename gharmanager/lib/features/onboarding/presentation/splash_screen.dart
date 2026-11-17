import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/providers.dart';
import '../../../l10n/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 2400), _continue);
  }

  void _continue() {
    if (!mounted) return;
    final hasStartupIssue = ref.read(startupIssueProvider) != null;
    final client = ref.read(supabaseClientProvider);
    final destination = hasStartupIssue || client == null
        ? '/setup'
        : client.auth.currentSession == null
        ? '/sign-in'
        : '/home';
    context.go(destination);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF0FBF5),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0FBF5),
        body: Stack(
          children: [
            const Positioned.fill(child: _SplashBackdrop()),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Eyebrow(text: l10n.splashEyebrow),
                        const SizedBox(height: 28),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: const Color(0xFF087A57),
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF087A57)
                                        .withValues(alpha: .18),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.home_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            Positioned(
                              right: -5,
                              bottom: -5,
                              child: Container(
                                width: 19,
                                height: 19,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6B938),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFF0FBF5),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.currency_rupee,
                                  size: 11,
                                  color: Color(0xFF55420A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -.8,
                                ),
                            children: const [
                              TextSpan(
                                text: 'Ghar',
                                style: TextStyle(color: Color(0xFF087A57)),
                              ),
                              TextSpan(
                                text: ' Manager',
                                style: TextStyle(color: Color(0xFF162820)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 3,
                          margin: const EdgeInsets.only(top: 3, bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF087A57),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .58),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFDCEFE5)),
                          ),
                          child: Text(
                            l10n.splashTagline,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: const Color(0xFF60766B),
                                  letterSpacing: .1,
                                ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .58),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                size: 16,
                                color: Color(0xFF087A57),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.splashTrustMessage,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: const Color(0xFF4F6358),
                                        height: 1.35,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: const LinearProgressIndicator(
                            minHeight: 4,
                            value: 1,
                            backgroundColor: Color(0xFFD7EADF),
                            valueColor: AlwaysStoppedAnimation(
                              Color(0xFF087A57),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF087A57),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.splashReady,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: const Color(0xFF597064),
                                    fontSize: 10,
                                  ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE4F4EA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                l10n.splashCurrency,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: const Color(0xFF087A57),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.public,
                              size: 15,
                              color: colors.secondary,
                            ),
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                l10n.splashCountryTrust,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: const Color(0xFF42594D),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFE3F4EB),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: const Color(0xFF34705A),
        fontWeight: FontWeight.w700,
        letterSpacing: .55,
        fontSize: 9,
      ),
    ),
  );
}

class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop();

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFAFFFC), Color(0xFFF0FBF5), Color(0xFFECF9F2)],
          ),
        ),
      ),
      CustomPaint(painter: _SplashBackdropPainter()),
    ],
  );
}

class _SplashBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .31);
    final ringPaint = Paint()
      ..color = const Color(0xFF70B893).withValues(alpha: .09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final radius in [58.0, 82.0, 108.0]) {
      canvas.drawCircle(center, radius, ringPaint);
    }
    final diamondPath = Path()
      ..moveTo(center.dx, center.dy - 122)
      ..lineTo(center.dx + 104, center.dy)
      ..lineTo(center.dx, center.dy + 122)
      ..lineTo(center.dx - 104, center.dy)
      ..close();
    canvas.drawPath(diamondPath, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
