import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../data/models/car_model.dart';
import '../providers/car_provider.dart';
import '../providers/auth_provider.dart';

class AddEditCarScreen extends ConsumerStatefulWidget {
  final String? carId;

  const AddEditCarScreen({super.key, this.carId});

  @override
  ConsumerState<AddEditCarScreen> createState() => _AddEditCarScreenState();
}

class _AddEditCarScreenState extends ConsumerState<AddEditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();
  final _mileageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _featuresController = TextEditingController();
  final _locationsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'SUV';
  String _selectedFuelType = 'Petrol';
  String _selectedTransmission = 'Manual';
  List<String> _imageUrls = [];
  List<Uint8List> _newImageBytes = [];
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.carId != null) {
      _isEditing = true;
      _loadCarData();
    }
  }

  Future<void> _loadCarData() async {
    final car = await ref.read(carByIdProvider(widget.carId!).future);
    if (car != null && mounted) {
      setState(() {
        _nameController.text = car.name;
        _brandController.text = car.brand;
        _priceController.text = car.pricePerDay.toString();
        _seatsController.text = car.seats.toString();
        _mileageController.text = car.mileage;
        _descriptionController.text = car.description;
        _featuresController.text = car.features.join(', ');
        _locationsController.text = car.pickupLocations.join(', ');
        _selectedCategory = car.category;
        _selectedFuelType = car.fuelType;
        _selectedTransmission = car.transmission;
        _imageUrls = List.from(car.images);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _mileageController.dispose();
    _descriptionController.dispose();
    _featuresController.dispose();
    _locationsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (kIsWeb) {
      // On web, use image picker but store bytes
      final picker = ImagePicker();
      final results = await picker.pickMultiImage();
      if (results.isNotEmpty) {
        for (var xfile in results) {
          final bytes = await xfile.readAsBytes();
          setState(() {
            _newImageBytes.add(bytes);
          });
        }
      }
    } else {
      // Show dialog to add image URL for simplicity
      _showAddImageUrlDialog();
    }
  }

  void _showAddImageUrlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image URL'),
        content: TextField(
          controller: _imageUrlController,
          decoration: const InputDecoration(
            hintText: 'Paste image URL here',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_imageUrlController.text.isNotEmpty) {
                setState(() {
                  _imageUrls.add(_imageUrlController.text.trim());
                  _imageUrlController.clear();
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrls.isEmpty && _newImageBytes.isEmpty) {
      Helpers.showSnackBar(
        context,
        'Please add at least one image URL',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user's ID for ownerId
      final currentUser = ref.read(currentUserProvider).valueOrNull;

      final car = CarModel(
        id: widget.carId ?? '',
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        category: _selectedCategory,
        pricePerDay: double.parse(_priceController.text),
        images: _imageUrls,
        seats: int.parse(_seatsController.text),
        fuelType: _selectedFuelType,
        transmission: _selectedTransmission,
        mileage: _mileageController.text.trim(),
        description: _descriptionController.text.trim(),
        features: _featuresController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        pickupLocations: _locationsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        ownerId: currentUser?.uid ?? '',
        createdAt: DateTime.now(),
      );

      if (_isEditing) {
        await ref.read(carManagementProvider.notifier).updateCar(car);
        if (mounted) {
          Helpers.showSnackBar(context, AppStrings.carUpdated);
        }
      } else {
        await ref.read(carManagementProvider.notifier).addCar(car);
        if (mounted) {
          Helpers.showSnackBar(context, AppStrings.carAdded);
        }
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editCar : AppStrings.addCar),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Images section
                Text(
                  'Car Images',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add image URLs for your car photos',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),

                // Image URL list
                if (_imageUrls.isNotEmpty) ...[
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 12),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _imageUrls[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.surface,
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _imageUrls.removeAt(index),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Add image button
                OutlinedButton.icon(
                  onPressed: _showAddImageUrlDialog,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Image URL'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),

                const SizedBox(height: 20),
                // Basic info
                CustomTextField(
                  label: AppStrings.carName,
                  hint: 'e.g., Model X',
                  controller: _nameController,
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.brand,
                  hint: 'e.g., Tesla',
                  controller: _brandController,
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                // Category dropdown
                Text(
                  AppStrings.category,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: carCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value!),
                ),
                const SizedBox(height: 16),
                // Price and seats row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Price/Day (\$)',
                        hint: '50',
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        validator: Validators.price,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: AppStrings.seats,
                        hint: '5',
                        controller: _seatsController,
                        keyboardType: TextInputType.number,
                        validator: Validators.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Fuel and transmission
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.fuelType,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedFuelType,
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            items: fuelTypes
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(f),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedFuelType = value!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.transmission,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedTransmission,
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            items: transmissionTypes
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedTransmission = value!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.mileage,
                  hint: 'e.g., 15 km/l',
                  controller: _mileageController,
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.description,
                  hint: 'Describe the car...',
                  controller: _descriptionController,
                  maxLines: 3,
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: '${AppStrings.features} (comma separated)',
                  hint: 'AC, GPS, Bluetooth',
                  controller: _featuresController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Pickup Locations (comma separated)',
                  hint: 'Airport, Downtown, Station',
                  controller: _locationsController,
                  validator: Validators.required,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: _isEditing ? AppStrings.update : AppStrings.save,
                  onPressed: _saveCar,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
