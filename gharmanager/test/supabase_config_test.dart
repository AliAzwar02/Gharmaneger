import 'package:flutter_test/flutter_test.dart';
import 'package:gharmanager/core/config/supabase_config.dart';

void main() {
  group('SupabaseConfig', () {
    test('accepts an HTTPS project URL and a client key', () {
      const config = SupabaseConfig(
        url: 'https://project-ref.supabase.co',
        publishableKey: 'sb_publishable_client_key',
      );

      expect(config.isValid, isTrue);
    });

    test('accepts local HTTP endpoints for local development', () {
      const config = SupabaseConfig(
        url: 'http://127.0.0.1:54321',
        publishableKey: 'local-client-key',
      );

      expect(config.isValid, isTrue);
    });

    test('rejects missing credentials and non-HTTP schemes', () {
      const missingKey = SupabaseConfig(
        url: 'https://project-ref.supabase.co',
        publishableKey: '',
      );
      const invalidUrl = SupabaseConfig(
        url: 'file:///tmp/project',
        publishableKey: 'client-key',
      );
      const insecureRemoteUrl = SupabaseConfig(
        url: 'http://project.example',
        publishableKey: 'client-key',
      );

      expect(missingKey.isValid, isFalse);
      expect(invalidUrl.isValid, isFalse);
      expect(insecureRemoteUrl.isValid, isFalse);
    });
  });
}
