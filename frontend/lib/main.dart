import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: FoodRescueApp(),
    ),
  );
}

class FoodRescueApp extends ConsumerWidget {
  const FoodRescueApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Food Rescue',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
