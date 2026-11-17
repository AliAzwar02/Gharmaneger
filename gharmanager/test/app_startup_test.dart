import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gharmanager/core/router/app_router.dart';
import 'package:gharmanager/core/services/providers.dart';
import 'package:gharmanager/features/app/gharmanager_app.dart';

void main() {
  testWidgets('shows setup screen when Supabase credentials are absent', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(null),
          startupIssueProvider.overrideWithValue('missing_configuration'),
        ],
        child: const GharManagerApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.text('Connect your Supabase project'), findsOneWidget);
  });
}
