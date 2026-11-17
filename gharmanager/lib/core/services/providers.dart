import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/authentication/data/authentication_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient?>((ref) => null);

final authenticationRepositoryProvider = Provider<AuthenticationRepository?>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : AuthenticationRepository(client);
});
