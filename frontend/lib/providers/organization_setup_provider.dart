import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/auth_provider.dart';

part 'organization_setup_provider.g.dart';

enum OrganizationRole {
  donor,
  ngo,
}

class OrganizationSetupState {
  final OrganizationRole role;
  final int currentStep;

  final String orgName;
  final String orgType;
  final String registrationNumber;
  final String contactPerson;
  final String address;
  final String serviceArea;

  final double? latitude;
  final double? longitude;

  final bool isSaving;
  final String? error;

  const OrganizationSetupState({
    required this.role,
    this.currentStep = 0,
    this.orgName = '',
    this.orgType = '',
    this.registrationNumber = '',
    this.contactPerson = '',
    this.address = '',
    this.serviceArea = '',
    this.latitude,
    this.longitude,
    this.isSaving = false,
    this.error,
  });

  bool get isDonor =>
      role == OrganizationRole.donor;

  bool get isNgo =>
      role == OrganizationRole.ngo;

  bool get canGoBack =>
      currentStep > 0;

  bool get canGoNext =>
      validateStep(currentStep);

  bool validateStep(int step) {
    switch (step) {
      case 0:
        if (orgName.trim().length < 2) {
          return false;
        }

        return isDonor
            ? orgType.trim().isNotEmpty
            : registrationNumber
                .trim()
                .isNotEmpty;

      case 1:
        return contactPerson
                .trim()
                .length >=
            2;

      case 2:
        if (address.trim().length < 5) {
          return false;
        }

        if (isNgo &&
            serviceArea.trim().length < 2) {
          return false;
        }

        return true;

      case 3:
        return true;

      default:
        return false;
    }
  }

  bool get isComplete =>
      validateStep(0) &&
      validateStep(1) &&
      validateStep(2);

  OrganizationSetupState copyWith({
    int? currentStep,
    String? orgName,
    String? orgType,
    String? registrationNumber,
    String? contactPerson,
    String? address,
    String? serviceArea,
    double? latitude,
    double? longitude,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return OrganizationSetupState(
      role: role,
      currentStep:
          currentStep ?? this.currentStep,
      orgName: orgName ?? this.orgName,
      orgType: orgType ?? this.orgType,
      registrationNumber:
          registrationNumber ??
              this.registrationNumber,
      contactPerson:
          contactPerson ??
              this.contactPerson,
      address:
          address ?? this.address,
      serviceArea:
          serviceArea ??
              this.serviceArea,
      latitude:
          latitude ?? this.latitude,
      longitude:
          longitude ?? this.longitude,
      isSaving:
          isSaving ?? this.isSaving,
      error: clearError
          ? null
          : (error ?? this.error),
    );
  }
}

@riverpod
class OrganizationSetup
    extends _$OrganizationSetup {
  @override
  OrganizationSetupState build(
    OrganizationRole role,
  ) {
    return OrganizationSetupState(
      role: role,
    );
  }

  void updateOrgName(String value) {
    state = state.copyWith(
      orgName: value,
      clearError: true,
    );
  }

  void updateOrgType(String value) {
    state = state.copyWith(
      orgType: value,
      clearError: true,
    );
  }

  void updateRegistrationNumber(
    String value,
  ) {
    state = state.copyWith(
      registrationNumber: value,
      clearError: true,
    );
  }

  void updateContactPerson(
    String value,
  ) {
    state = state.copyWith(
      contactPerson: value,
      clearError: true,
    );
  }

  void updateAddress(String value) {
    state = state.copyWith(
      address: value,
      clearError: true,
    );
  }

  void updateServiceArea(String value) {
    state = state.copyWith(
      serviceArea: value,
      clearError: true,
    );
  }

  void setLocation({
    required double latitude,
    required double longitude,
  }) {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      clearError: true,
    );
  }

  Future<bool> useCurrentLocation() async {
    try {
      final enabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!enabled) {
        _error(
          'Location services are disabled.',
        );
        return false;
      }

      var permission =
          await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator
                .requestPermission();
      }

      if (permission ==
          LocationPermission.denied) {
        _error(
          'Location permission was denied.',
        );
        return false;
      }

      if (permission ==
          LocationPermission.deniedForever) {
        _error(
          'Location permission is permanently denied.',
        );
        return false;
      }

      final position =
          await Geolocator
              .getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return true;
    } catch (e) {
      _error(
        'Unable to determine your location.',
      );
      return false;
    }
  }

  void nextStep() {
    if (!state.canGoNext) {
      _error(
        'Please complete the required fields.',
      );
      return;
    }

    if (state.currentStep < 3) {
      state = state.copyWith(
        currentStep:
            state.currentStep + 1,
        clearError: true,
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep:
            state.currentStep - 1,
        clearError: true,
      );
    }
  }

  Future<bool> saveProfile(
    WidgetRef ref,
  ) async {
    if (!state.isComplete) {
      _error(
        'Please complete all required fields.',
      );
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      clearError: true,
    );

    try {
      final payload = <String, dynamic>{
        'orgName': state.orgName.trim(),
        'orgType': state.orgType.trim(),
        'registrationNumber':
            state.registrationNumber.trim(),
        'contactPerson':
            state.contactPerson.trim(),
        'address': state.address.trim(),
        'serviceArea':
            state.serviceArea.trim(),
        'latitude': state.latitude,
        'longitude': state.longitude,
      };

      final success = await ref
          .read(authProvider.notifier)
          .completeOrganizationProfile(
            payload: payload,
          );

      if (!success) {
        throw Exception(
          'Organization profile could not be created.',
        );
      }

      state = state.copyWith(
        isSaving: false,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );

      return false;
    }
  }

  void _error(String message) {
    state = state.copyWith(
      error: message,
    );
  }
}
