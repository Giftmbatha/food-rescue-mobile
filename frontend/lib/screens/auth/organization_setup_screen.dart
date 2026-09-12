import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/organization_setup_provider.dart';

class OrganizationSetupScreen
    extends ConsumerWidget {
  const OrganizationSetupScreen({
    super.key,
    required this.role,
  });

  final OrganizationRole role;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final provider =
        organizationSetupProvider(role);

    final state =
        ref.watch(provider);

    final notifier =
        ref.read(provider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          role == OrganizationRole.donor
              ? 'Donor Setup'
              : 'NGO Setup',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Step ${state.currentStep + 1} of 4',
            ),
            const SizedBox(height: 24),

            // UI intentionally minimal.
            // Build your final stepLine UI here.
            TextField(
              onChanged: notifier.updateOrgName,
              decoration:
                  const InputDecoration(
                labelText: 'Organization Name',
              ),
            ),

            if (role ==
                OrganizationRole.donor)
              TextField(
                onChanged:
                    notifier.updateOrgType,
                decoration:
                    const InputDecoration(
                  labelText: 'Organization Type',
                ),
              ),

            if (role ==
                OrganizationRole.ngo)
              TextField(
                onChanged: notifier
                    .updateRegistrationNumber,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Registration Number',
                ),
              ),

            TextField(
              onChanged:
                  notifier.updateContactPerson,
              decoration:
                  const InputDecoration(
                labelText: 'Contact Person',
              ),
            ),

            TextField(
              onChanged:
                  notifier.updateAddress,
              decoration:
                  const InputDecoration(
                labelText: 'Address',
              ),
            ),

            if (role ==
                OrganizationRole.ngo)
              TextField(
                onChanged:
                    notifier.updateServiceArea,
                decoration:
                    const InputDecoration(
                  labelText: 'Service Area',
                ),
              ),

            const SizedBox(height: 16),

            if (state.error != null)
              Text(
                state.error!,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .error,
                ),
              ),

            const Spacer(),

            Row(
              children: [
                if (state.canGoBack)
                  OutlinedButton(
                    onPressed:
                        notifier.previousStep,
                    child:
                        const Text('Back'),
                  ),

                const Spacer(),

                FilledButton(
                  onPressed: state.isSaving
                      ? null
                      : () async {
                          if (state.currentStep <
                              3) {
                            notifier.nextStep();
                            return;
                          }

                          final success =
                              await notifier
                                  .saveProfile(
                            ref,
                          );

                          if (!context.mounted ||
                              !success) {
                            return;
                          }

                          final userRole =
                              ref.read(
                            userRoleProvider,
                          );

                          context.go(
                            userRole ==
                                    'DONOR'
                                ? '/donor/home'
                                : '/ngo/discover',
                          );
                        },
                  child: Text(
                    state.isSaving
                        ? 'Saving...'
                        : state.currentStep < 3
                            ? 'Next'
                            : 'Complete',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
