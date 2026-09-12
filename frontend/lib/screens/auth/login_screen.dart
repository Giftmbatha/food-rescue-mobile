import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends ConsumerState<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  Future<void> login() async {
    final success =
        await ref.read(authProvider.notifier).login(
              email.text.trim(),
              password.text,
            );

    if (!mounted || success) return;

    final error =
        ref.read(authProvider).value?.error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'Login failed',
        ),
      ),
    );
  }

  @override
  void dispose() {
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
              const SizedBox(height: 16),
              FilledButton(
                onPressed:
                    loading ? null : login,
                child: Text(
                  loading
                      ? 'Signing in...'
                      : 'Sign In',
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.push('/register'),
                child: const Text(
                  'Create an account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
