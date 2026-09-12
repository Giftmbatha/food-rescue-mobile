import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/organization_setup_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends ConsumerState<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  String role = 'DONOR';

  Future<void> register() async {
    final success =
        await ref.read(authProvider.notifier).register(
              fullName: name.text.trim(),
              email: email.text.trim(),
              password: password.text,
              role: role,
            );

    if (!mounted) return;

    if (!success) {
      final error =
          ref.read(authProvider).value?.error;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'Registration failed',
          ),
        ),
      );

      return;
    }

    context.go(
      '/organization-setup',
      extra: role == 'DONOR'
          ? OrganizationRole.donor
          : OrganizationRole.ngo,
    );
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading =
        ref.watch(authProvider).isLoading;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration:
                    const InputDecoration(
                  labelText: 'Full Name',
                ),
              ),
              TextField(
                controller: email,
                decoration:
                    const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: password,
                obscureText: true,
                decoration:
                    const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'DONOR',
                    label: Text('Donor'),
                  ),
                  ButtonSegment(
                    value: 'NGO',
                    label: Text('NGO'),
                  ),
                ],
                selected: {role},
                onSelectionChanged: (value) {
                  setState(() {
                    role = value.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed:
                    loading ? null : register,
                child: Text(
                  loading
                      ? 'Creating...'
                      : 'Create Account',
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.pop(),
                child:
                    const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
