import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/loading_overlay.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).valueOrNull;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(
                  context,
                  await picker.pickImage(source: ImageSource.camera),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(
                  context,
                  await picker.pickImage(source: ImageSource.gallery),
                );
              },
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() => _selectedImage = File(result.path));
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) throw Exception('User not found');

      // Upload photo if selected
      String? photoUrl;
      if (_selectedImage != null) {
        photoUrl = await ref
            .read(userProfileNotifierProvider.notifier)
            .uploadAndUpdatePhoto(user.uid, _selectedImage!);
      }

      // Update profile
      await ref
          .read(userProfileNotifierProvider.notifier)
          .updateProfile(
            user.copyWith(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              photoUrl: photoUrl ?? user.photoUrl,
            ),
          );

      if (mounted) {
        Helpers.showSnackBar(context, AppStrings.profileUpdated);
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
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text(AppStrings.editProfile)),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile photo
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.1), // Glowing ring
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.teal.withOpacity(0.5),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(color: AppColors.teal.withOpacity(0.3), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.darkSurface,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (user?.photoUrl.isNotEmpty == true
                                  ? CachedNetworkImageProvider(user!.photoUrl)
                                  : null) as ImageProvider?,
                          child: _selectedImage == null &&
                                  (user?.photoUrl ?? '').isEmpty
                              ? Text(
                                  user?.name.isNotEmpty == true
                                      ? user!.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.scaffoldBackground, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.teal.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Name field
                CustomTextField(
                  label: AppStrings.fullName,
                  hint: 'Enter your full name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: Validators.name,
                ),
                const SizedBox(height: 24),
                // Email field (readonly)
                CustomTextField(
                  label: AppStrings.email,
                  hint: user?.email ?? '',
                  controller: TextEditingController(text: user?.email ?? ''),
                  prefixIcon: Icons.email_outlined,
                  enabled: false,
                ),
                const SizedBox(height: 24),
                // Phone field
                CustomTextField(
                  label: AppStrings.phone,
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 48),
                // Update button
                PrimaryButton(
                  text: AppStrings.updateProfile,
                  onPressed: _updateProfile,
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
