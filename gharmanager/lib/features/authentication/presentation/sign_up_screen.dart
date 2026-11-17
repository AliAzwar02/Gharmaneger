import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/user_role.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.landlord;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final repository = ref.read(authenticationRepositoryProvider);
    if (repository == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await repository.signUp(
        fullName: _name.text,
        email: _email.text,
        password: _password.text,
        role: _role,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).checkEmail)),
      );
      context.go('/sign-in');
    } on AuthException catch (error) {
      setState(() => _error = error.message);
    } on Object {
      setState(() => _error = AppLocalizations.of(context).genericAuthError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccount)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(labelText: l10n.fullName),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? l10n.requiredField
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(labelText: l10n.email),
                          validator: (value) =>
                              value == null ||
                                  !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                      .hasMatch(value.trim())
                              ? l10n.validEmailRequired
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: InputDecoration(labelText: l10n.password),
                          validator: (value) =>
                              value == null || value.length < 8
                              ? l10n.passwordMinLength
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.accountType,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        SegmentedButton<UserRole>(
                          segments: [
                            ButtonSegment(
                              value: UserRole.landlord,
                              label: Text(l10n.landlord),
                              icon: const Icon(Icons.apartment_outlined),
                            ),
                            ButtonSegment(
                              value: UserRole.tenant,
                              label: Text(l10n.tenant),
                              icon: const Icon(Icons.person_outline),
                            ),
                          ],
                          selected: {_role},
                          onSelectionChanged: (roles) =>
                              setState(() => _role = roles.first),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.invitationAccessNote,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.createAccount),
                        ),
                        TextButton(
                          onPressed: () => context.go('/sign-in'),
                          child: Text(l10n.backToSignIn),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
