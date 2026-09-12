import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/listing_provider.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState
    extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  final _pickupWindowController = TextEditingController();
  final _notesController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  int _currentStep = 0;

  String? _selectedCategory;
  DateTime? _expiryDate;

  bool _allowPartialClaims = false;
  bool _isSubmitting = false;

  final List<XFile> _selectedImages = [];

  /*
   * IMPORTANT:
   * These values must match FoodCategory.java exactly.
   */
  final List<String> _categories = [
    'FRUITS',
    'VEGETABLES',
    'BAKERY',
    'DAIRY',
    'MEAT',
    'PREPARED_FOOD',
    'BEVERAGES',
    'OTHER',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _addressController.dispose();
    _pickupWindowController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // STEP VALIDATION
  // ------------------------------------------------------------

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_titleController.text.trim().isEmpty) {
          _showError('Please enter a donation title.');
          return false;
        }

        if (_titleController.text.trim().length > 100) {
          _showError(
            'Donation title cannot exceed 100 characters.',
          );
          return false;
        }

        if (_selectedCategory == null) {
          _showError('Please select a food category.');
          return false;
        }

        final quantity = double.tryParse(
          _quantityController.text.trim(),
        );

        if (quantity == null || quantity <= 0) {
          _showError(
            'Please enter a valid quantity.',
          );
          return false;
        }

        if (quantity > 10000) {
          _showError(
            'Quantity cannot exceed 10,000 kg.',
          );
          return false;
        }

        return true;

      case 1:
        if (_expiryDate == null) {
          _showError(
            'Please select an expiry date.',
          );
          return false;
        }

        if (_descriptionController.text.length > 500) {
          _showError(
            'Description cannot exceed 500 characters.',
          );
          return false;
        }

        return true;

      case 2:
        if (_addressController.text.trim().isEmpty) {
          _showError(
            'Please enter the pickup address.',
          );
          return false;
        }

        if (_pickupWindowController.text.trim().isEmpty) {
          _showError(
            'Please enter the pickup window.',
          );
          return false;
        }

        if (_notesController.text.length > 300) {
          _showError(
            'Pickup notes cannot exceed 300 characters.',
          );
          return false;
        }

        return true;

      case 3:
        return true;

      default:
        return false;
    }
  }

  void _nextStep() {
    if (!_validateCurrentStep()) {
      return;
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      _createListing();
    }
  }

  void _previousStep() {
    if (_currentStep == 0) {
      context.pop();
      return;
    }

    setState(() {
      _currentStep--;
    });
  }

  // ------------------------------------------------------------
  // EXPIRY DATE
  // ------------------------------------------------------------

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: now.add(
        const Duration(days: 1),
      ),
      firstDate: now.add(
        const Duration(days: 1),
      ),
      lastDate: now.add(
        const Duration(days: 365),
      ),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _expiryDate = DateTime(
        selected.year,
        selected.month,
        selected.day,
        23,
        59,
      );
    });
  }

  // ------------------------------------------------------------
  // CAMERA / GALLERY
  // ------------------------------------------------------------

  Future<void> _showImageSourcePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                ),
                title: const Text(
                  'Take a photo',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                ),
                title: const Text(
                  'Choose from gallery',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _takePhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image == null) {
        return;
      }

      setState(() {
        _selectedImages.add(image);
      });
    } catch (e) {
      _showError(
        'Unable to open the camera.',
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final images =
      await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isEmpty) {
        return;
      }

      setState(() {
        _selectedImages.addAll(images);
      });
    } catch (e) {
      _showError(
        'Unable to open the gallery.',
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // ------------------------------------------------------------
  // CREATE LISTING
  // ------------------------------------------------------------

  Future<void> _createListing() async {
    if (!_validateCurrentStep()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository =
      ref.read(listingRepositoryProvider);

      final imageObjectKeys = <String>[];

      // Upload selected photos first.
      for (final image in _selectedImages) {
        final objectKey =
        await repository.uploadImage(image);

        if (objectKey != null &&
            objectKey.trim().isNotEmpty) {
          imageObjectKeys.add(objectKey);
        }
      }

      final quantity = double.parse(
        _quantityController.text.trim(),
      );

      final listing =
      await repository.createListing(
        title: _titleController.text.trim(),
        description:
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory!,
        quantityKg: quantity,
        expiryDate: _expiryDate!,
        pickupAddress:
        _addressController.text.trim(),
        pickupWindow:
        _pickupWindowController.text.trim(),
        pickupNotes:
        _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        allowPartialClaims:
        _allowPartialClaims,
        imageObjectKeys: imageObjectKeys,
      );

      ref.invalidate(listingsProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Donation published successfully.',
          ),
        ),
      );

      context.pop(listing);
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // UI HELPERS
  // ------------------------------------------------------------

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  InputDecoration _inputDecoration(
      String label, {
        String? hint,
      }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
    );
  }

  String _stepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Food details';
      case 1:
        return 'Expiry & description';
      case 2:
        return 'Pickup details';
      case 3:
        return 'Photos & review';
      default:
        return 'Create donation';
    }
  }

  String _stepDescription() {
    switch (_currentStep) {
      case 0:
        return 'Tell NGOs what food you are donating.';
      case 1:
        return 'Let NGOs know when the food expires.';
      case 2:
        return 'Tell NGOs where and when to collect it.';
      case 3:
        return 'Add photos and review your donation.';
      default:
        return '';
    }
  }

  // ------------------------------------------------------------
  // STEP 1
  // ------------------------------------------------------------

  Widget _buildFoodStep() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: _inputDecoration(
            'Donation title',
            hint: 'e.g. Fresh vegetables',
          ),
          maxLength: 100,
        ),

        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: _inputDecoration(
            'Food category',
          ),
          items: _categories.map(
                (category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category.replaceAll('_', ' '),
                ),
              );
            },
          ).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),

        const SizedBox(height: 20),

        TextFormField(
          controller: _quantityController,
          keyboardType:
          const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: _inputDecoration(
            'Quantity in kilograms',
            hint: 'e.g. 25',
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(12),
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You can provide more information in the next step.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // STEP 2
  // ------------------------------------------------------------

  Widget _buildExpiryStep() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'When does this food expire?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _selectExpiryDate,
            icon: const Icon(
              Icons.calendar_today,
            ),
            label: Text(
              _expiryDate == null
                  ? 'Select expiry date'
                  : '${_expiryDate!.day}/'
                  '${_expiryDate!.month}/'
                  '${_expiryDate!.year}',
            ),
          ),
        ),

        const SizedBox(height: 24),

        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          maxLength: 500,
          decoration: _inputDecoration(
            'Description',
            hint:
            'Describe the food, condition, packaging, etc.',
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Example: Fresh vegetables packed today and ready for collection.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // STEP 3
  // ------------------------------------------------------------

  Widget _buildPickupStep() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: _inputDecoration(
            'Pickup address',
            hint:
            'Enter the address where the food can be collected',
          ),
        ),

        const SizedBox(height: 20),

        TextFormField(
          controller:
          _pickupWindowController,
          decoration: _inputDecoration(
            'Pickup window',
            hint: 'e.g. 09:00 - 12:00',
          ),
        ),

        const SizedBox(height: 20),

        TextFormField(
          controller: _notesController,
          maxLines: 4,
          maxLength: 300,
          decoration: _inputDecoration(
            'Pickup notes',
            hint:
            'Any instructions for the NGO?',
          ),
        ),

        const SizedBox(height: 12),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Allow partial claims',
          ),
          subtitle: const Text(
            'NGOs can claim only part of the donation.',
          ),
          value: _allowPartialClaims,
          onChanged: (value) {
            setState(() {
              _allowPartialClaims = value;
            });
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // STEP 4
  // ------------------------------------------------------------

  Widget _buildPhotosStep() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed:
            _showImageSourcePicker,
            icon: const Icon(
              Icons.camera_alt,
            ),
            label: const Text(
              'Take a photo or choose from gallery',
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (_selectedImages.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
              ),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  size: 50,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  'No photos added yet',
                ),
                SizedBox(height: 4),
                Text(
                  'Photos help NGOs understand the donation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              final image =
              _selectedImages[index];

              return Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(8),
                      child: Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Positioned(
                    right: 4,
                    top: 4,
                    child: GestureDetector(
                      onTap: () =>
                          _removeImage(index),
                      child: Container(
                        decoration:
                        const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding:
                        const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

        const SizedBox(height: 28),

        const Text(
          'Donation summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        _summaryRow(
          'Food',
          _titleController.text,
        ),

        _summaryRow(
          'Category',
          _selectedCategory
              ?.replaceAll('_', ' ') ??
              '-',
        ),

        _summaryRow(
          'Quantity',
          '${_quantityController.text} kg',
        ),

        _summaryRow(
          'Expiry',
          _expiryDate == null
              ? '-'
              : '${_expiryDate!.day}/'
              '${_expiryDate!.month}/'
              '${_expiryDate!.year}',
        ),

        _summaryRow(
          'Pickup',
          _addressController.text,
        ),
      ],
    );
  }

  Widget _summaryRow(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildFoodStep();

      case 1:
        return _buildExpiryStep();

      case 2:
        return _buildPickupStep();

      case 3:
        return _buildPhotosStep();

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting
              ? null
              : _previousStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                8,
              ),
              child: Row(
                children: List.generate(
                  4,
                      (index) {
                    return Expanded(
                      child: Container(
                        margin:
                        const EdgeInsets.only(
                          right: 5,
                        ),
                        height: 5,
                        decoration:
                        BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(
                            10,
                          ),
                          color: index <=
                              _currentStep
                              ? Theme.of(context)
                              .colorScheme
                              .primary
                              : Colors.grey
                              .shade300,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Align(
                alignment:
                Alignment.centerLeft,
                child: Text(
                  'Step ${_currentStep + 1} of 4',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Align(
                alignment:
                Alignment.centerLeft,
                child: Text(
                  _stepDescription(),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.all(16),
                child: _buildCurrentStep(),
              ),
            ),

            // Bottom navigation
            Container(
              padding:
              const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black
                        .withValues(alpha: 0.08),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                        _isSubmitting
                            ? null
                            : _previousStep,
                        child:
                        const Text('Back'),
                      ),
                    ),

                  if (_currentStep > 0)
                    const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                      _isSubmitting
                          ? null
                          : _nextStep,
                      child: _isSubmitting
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        _currentStep == 3
                            ? 'Publish Donation'
                            : 'Continue',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}