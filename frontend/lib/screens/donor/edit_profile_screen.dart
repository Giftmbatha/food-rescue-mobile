import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/donor_model.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen
    extends ConsumerStatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  ConsumerState<EditProfileScreen>
  createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends ConsumerState<
        EditProfileScreen> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _orgNameController;

  late final TextEditingController
  _addressController;

  late final TextEditingController
  _contactController;

  late final TextEditingController
  _phoneController;

  String _orgType = 'OTHER';

  double? _latitude;
  double? _longitude;

  bool _loading = true;
  bool _saving = false;

  DonorModel? _profile;

  final List<String> _orgTypes = [
    'SUPERMARKET',
    'RESTAURANT',
    'BAKERY',
    'HOTEL',
    'CATERING',
    'FARM',
    'SUPPLIER',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();

    _orgNameController =
        TextEditingController();

    _addressController =
        TextEditingController();

    _contactController =
        TextEditingController();

    _phoneController =
        TextEditingController();

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile =
      await ref.read(
        donorProfileProvider.future,
      );

      if (!mounted) {
        return;
      }

      if (profile == null) {
        setState(() {
          _loading = false;
        });

        return;
      }

      _profile = profile;

      _orgNameController.text =
          profile.orgName;

      _addressController.text =
          profile.address;

      _contactController.text =
          profile.contactPerson;

      _phoneController.text =
          profile.phone ?? '';

      _orgType =
      _orgTypes.contains(
        profile.orgType,
      )
          ? profile.orgType
          : 'OTHER';

      _latitude =
          profile.latitude;

      _longitude =
          profile.longitude;

      setState(() {
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_profile?.id == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await ref
          .read(
        profileRepositoryProvider,
      )
          .updateDonorProfile(
        id: _profile!.id!,
        orgName:
        _orgNameController.text.trim(),
        orgType: _orgType,
        address:
        _addressController.text.trim(),
        contactPerson:
        _contactController.text.trim(),
        phone:
        _phoneController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
      );

      ref.invalidate(
        donorProfileProvider,
      );

      ref.invalidate(
        donorStatsProvider,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
          ),
        ),
        body: const Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
          const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller:
              _orgNameController,
              textInputAction:
              TextInputAction.next,
              decoration:
              const InputDecoration(
                labelText:
                'Organisation name',
                prefixIcon: Icon(
                  Icons.business_outlined,
                ),
                border:
                OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().length < 2) {
                  return 'Enter an organisation name.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<
                String>(
              initialValue: _orgType,
              decoration:
              const InputDecoration(
                labelText:
                'Organisation type',
                prefixIcon: Icon(
                  Icons.category_outlined,
                ),
                border:
                OutlineInputBorder(),
              ),
              items: _orgTypes
                  .map(
                    (type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      _formatOrgType(
                        type,
                      ),
                    ),
                  );
                },
              )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _orgType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
              _contactController,
              textInputAction:
              TextInputAction.next,
              decoration:
              const InputDecoration(
                labelText:
                'Contact person',
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
                border:
                OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().length < 2) {
                  return 'Enter the contact person.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
              _phoneController,
              keyboardType:
              TextInputType.phone,
              textInputAction:
              TextInputAction.next,
              decoration:
              const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(
                  Icons.phone_outlined,
                ),
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
              _addressController,
              maxLines: 3,
              decoration:
              const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                ),
                border:
                OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().length < 5) {
                  return 'Enter a valid address.';
                }

                return null;
              },
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed:
                _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Save Changes',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatOrgType(
      String value,
      ) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) {
        if (word.isEmpty) {
          return word;
        }

        return word[0].toUpperCase() +
            word.substring(1).toLowerCase();
      },
    )
        .join(' ');
  }
}