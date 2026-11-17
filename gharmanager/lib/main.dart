import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/router/app_router.dart';
import 'core/services/providers.dart';
import 'features/app/gharmanager_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const config = SupabaseConfig.fromEnvironment;
  SupabaseClient? client;
  String? startupIssue;

  if (!config.isValid) {
    startupIssue = 'missing_configuration';
  } else {
    try {
      await Supabase.initialize(
        url: config.url,
        publishableKey: config.publishableKey,
      );
      client = Supabase.instance.client;
    } on Object {
      startupIssue = 'initialization_failed';
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        supabaseClientProvider.overrideWithValue(client),
        startupIssueProvider.overrideWithValue(startupIssue),
      ],
      child: const GharManagerApp(),
    ),
  );
}
