import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/widgets/car_image.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/communication_service.dart';
import '../providers/auth_provider.dart';
import '../providers/car_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/favorites_provider.dart';

class CarDetailsScreen extends ConsumerStatefulWidget {
  final String carId;

  const CarDetailsScreen({super.key, required this.carId});

  @override
  ConsumerState<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends ConsumerState<CarDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Keep screen awake while user is viewing car details
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carAsync = ref.watch(carByIdProvider(widget.carId));
    final favoriteIds = ref.watch(favoriteCarIdsProvider);

    return carAsync.when(
      data: (car) {
        if (car == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Car not found')),
          );
        }

        final isFavorite = favoriteIds.contains(car.id);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Top Section with Image
                  SliverToBoxAdapter(
                    child: _buildImageSection(car, isFavorite),
                  ),
                  // Content Section
                  SliverToBoxAdapter(child: _buildContentSection(car)),
                ],
              ),
              // Bottom Action Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomActionBar(car),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildImageSection(dynamic car, bool isFavorite) {
    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          // Car Image with Page View
          SizedBox(
            height: 300,
            width: double.infinity,
            child: car.images.isNotEmpty
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: car.images.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _openFullScreenImage(context, car, index),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Hero(
                            tag: 'car_image_details_${car.id}_$index',
                            child: CarImage(
                              url: car.images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 80,
                      color: AppColors.textLight,
                    ),
                  ),
          ),
          // Gradient Overlay at the bottom of the image
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // App Bar Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircleButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => context.pop(),
                    ),
                    _buildCircleButton(
                      icon: Icons.ios_share_rounded,
                      onTap: () {
                        // Implement sharing
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Left/Right Navigation Arrows
          if (car.images.length > 1) ...[
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildCircleButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () {
                    if (_currentImageIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _pageController.animateToPage(
                        car.images.length - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildCircleButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () {
                    if (_currentImageIndex < car.images.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ),
          ],

          // Page Indicator
          if (car.images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  car.images.length,
                  (index) => GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentImageIndex == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentImageIndex == index
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildContentSection(dynamic car) {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Price Row
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${car.brand} ${car.name}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            car.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' (${car.reviewCount} trips)',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${car.pricePerDay.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      '/day',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Horizontal Specifications Slider
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                _buildSpecPill(Icons.speed_rounded, '${(car.seats * 30)} kW'),
                _buildSpecPill(Icons.settings_suggest_rounded, car.transmission),
                _buildSpecPill(Icons.airline_seat_recline_normal_rounded, '${car.seats} Seats'),
                _buildSpecPill(Icons.local_gas_station_rounded, car.fuelType),
                _buildSpecPill(Icons.category_rounded, car.category),
              ],
            ),
          ),

          // Overview
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  car.description.isNotEmpty 
                      ? car.description 
                      : 'Experience the thrill of driving with the ${car.brand} ${car.name}. Striking design, cutting-edge technology, and unparalleled driving dynamics make it the ultimate luxury vehicle for your journey.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          // Features List
          if (car.features.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: car.features.map<Widget>((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              feature,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Location View Area (Placeholder)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDRUGDG426huvmHBqm-3G8yKViOhclWQFpFKzjxqy3EogLe-b50H9mOTbxPRURj-aVc609Ll72BxKg8tvTH7qApWmH66vLGgRl3Jh2V8uyhlu5lA4WvCMqAPtzZhEIPplDW5WbUF5hVCunpwUqWR3rmONSriyukqjtgOFg92kL2Te31hgVR5McSE8UYPRB8R5tQIlVGueJ-JsfQAhC6gQbN0NgPR0YYsWpXxa6RLx8Rlc9Gnp4lkjs7vrV0h-oCZHlENJgn47X0yhM',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const Center(child: Icon(Icons.map, size: 40, color: AppColors.textLight)),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.location_on, color: AppColors.primary, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Central City Area',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom padding
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSpecPill(IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomActionBar(dynamic car) {
    final favoriteIds = ref.watch(favoriteCarIdsProvider);
    final isFavorite = favoriteIds.contains(car.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Favorite Button
            _buildActionButton(
              icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.error : AppColors.textSecondary,
              onTap: () {
                final userId = ref.read(currentUserProvider).valueOrNull?.uid;
                if (userId != null) {
                  ref.read(favoritesNotifierProvider.notifier).toggleFavorite(userId, car.id);
                }
              },
            ),
            const SizedBox(width: 12),
            // Chat Button
            _buildActionButton(
              icon: Icons.chat_bubble_outline_rounded,
              color: AppColors.textSecondary,
              onTap: () => CommunicationService.launchSms(
                context,
                CommunicationService.supportPhone,
                body: 'Hi, I am interested in renting the ${car.brand} ${car.name}. Could you please share more details?',
              ),
            ),
            const SizedBox(width: 16),
            // Book Now Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ref.read(bookingNotifierProvider.notifier).setCar(
                        carId: car.id,
                        carName: car.name,
                        carImage: car.firstImage,
                        pricePerDay: car.pricePerDay,
                      );
                  context.push(AppRoutes.booking);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 4,
            )
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 24),
      ),
    );
  }

  void _openFullScreenImage(BuildContext context, dynamic car, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenImageGallery(
          car: car,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class FullScreenImageGallery extends StatefulWidget {
  final dynamic car;
  final int initialIndex;

  const FullScreenImageGallery({
    super.key,
    required this.car,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.car.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: 'car_image_details_${widget.car.id}_$index',
                    child: CarImage(
                      url: widget.car.images[index],
                      fit: BoxFit.contain, // Fit contain to see full photo
                      width: double.infinity,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Navigation Arrows for Desktop/Web
          if (widget.car.images.length > 1) ...[
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 48),
                  onPressed: () {
                    if (_currentIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _pageController.animateToPage(
                        widget.car.images.length - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 48),
                  onPressed: () {
                    if (_currentIndex < widget.car.images.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
          
          // Page Indicator
          if (widget.car.images.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.car.images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentIndex == index
                          ? AppColors.primary
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
