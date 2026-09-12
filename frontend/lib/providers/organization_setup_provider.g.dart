// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_setup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OrganizationSetup)
final organizationSetupProvider = OrganizationSetupFamily._();

final class OrganizationSetupProvider
    extends $NotifierProvider<OrganizationSetup, OrganizationSetupState> {
  OrganizationSetupProvider._(
      {required OrganizationSetupFamily super.from,
      required OrganizationRole super.argument})
      : super(
          retry: null,
          name: r'organizationSetupProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$organizationSetupHash();

  @override
  String toString() {
    return r'organizationSetupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OrganizationSetup create() => OrganizationSetup();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrganizationSetupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrganizationSetupState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrganizationSetupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$organizationSetupHash() => r'62c5e076e78bcd26f844b04d9ca4409aa8f95685';

final class OrganizationSetupFamily extends $Family
    with
        $ClassFamilyOverride<OrganizationSetup, OrganizationSetupState,
            OrganizationSetupState, OrganizationSetupState, OrganizationRole> {
  OrganizationSetupFamily._()
      : super(
          retry: null,
          name: r'organizationSetupProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  OrganizationSetupProvider call(
    OrganizationRole role,
  ) =>
      OrganizationSetupProvider._(argument: role, from: this);

  @override
  String toString() => r'organizationSetupProvider';
}

abstract class _$OrganizationSetup extends $Notifier<OrganizationSetupState> {
  late final _$args = ref.$arg as OrganizationRole;
  OrganizationRole get role => _$args;

  OrganizationSetupState build(
    OrganizationRole role,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<OrganizationSetupState, OrganizationSetupState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<OrganizationSetupState, OrganizationSetupState>,
        OrganizationSetupState,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
