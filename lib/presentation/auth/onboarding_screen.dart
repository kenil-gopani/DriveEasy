import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.directions_car_rounded,
      title: 'Wide Car Selection',
      description: 'Choose from our extensive fleet of premium and verified vehicles across all categories.',
      color: const Color(0xFF0D7FF2),
      gradient: [const Color(0xFF0D7FF2), const Color(0xFF60A5FA)],
      features: [
        OnboardingFeature('100+ Premium Cars', Icons.check_circle),
        OnboardingFeature('All Categories', Icons.check_circle),
        OnboardingFeature('Verified Vehicles', Icons.check_circle),
      ],
    ),
    OnboardingData(
      icon: Icons.bolt_rounded,
      title: 'Instant Booking',
      description: 'Book your perfect ride in seconds with our streamlined process. No waiting required.',
      color: const Color(0xFFF48C25),
      gradient: [const Color(0xFFF48C25), const Color(0xFFFF4B2B)],
      features: [
        OnboardingFeature('3-Tap Booking', Icons.touch_app_rounded),
        OnboardingFeature('Instant Confirmation', Icons.check_circle_rounded),
        OnboardingFeature('Flexible Dates', Icons.calendar_month_rounded),
      ],
    ),
    OnboardingData(
      icon: Icons.security_rounded,
      title: 'Full Insurance Cover',
      description: 'Drive with peace of mind. Every rental includes comprehensive insurance and 24/7 support.',
      color: const Color(0xFF10B981),
      gradient: [const Color(0xFF10B981), const Color(0xFF34D399)],
      features: [
        OnboardingFeature('Zero Liability', Icons.check_circle),
        OnboardingFeature('24/7 Support', Icons.check_circle),
        OnboardingFeature('Roadside Assistance', Icons.check_circle),
      ],
    ),
    OnboardingData(
      icon: Icons.redeem_rounded,
      title: 'Earn Rewards',
      description: 'Join our loyalty program to earn points on every rental, unlock exclusive offers, and get cashback.',
      color: const Color(0xFF7F19E6),
      gradient: [const Color(0xFF7F19E6), const Color(0xFFB673F8)],
      features: [
        OnboardingFeature('Loyalty Points', Icons.stars_rounded),
        OnboardingFeature('Exclusive Offers', Icons.local_offer_rounded),
        OnboardingFeature('Cashback Rewards', Icons.payments_rounded),
      ],
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   if (_currentPage > 0) 
                    GestureDetector(
                      onTap: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
                      ),
                    )
                  else
                    const SizedBox(width: 36), // Balanced space

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: page.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${_pages.length}',
                      style: TextStyle(
                        color: page.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: page.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPageContent(_pages[index]);
                },
              ),
            ),
            
            // Bottom Section
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: page.color,
                      dotColor: AppColors.border,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3.5,
                      spacing: 8,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: page.color,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: page.color.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == _pages.length - 1 
                                ? Icons.rocket_launch_rounded 
                                : Icons.arrow_forward_rounded,
                            size: 22,
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
    );
  }

  Widget _buildPageContent(OnboardingData data) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Icon Section
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: data.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: data.color.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(data.icon, size: 64, color: Colors.white),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Features
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: data.features.map((f) => _buildFeatureChip(f, data.color)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(OnboardingFeature feature, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(feature.icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            feature.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<Color> gradient;
  final List<OnboardingFeature> features;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.gradient,
    required this.features,
  });
}

class OnboardingFeature {
  final String label;
  final IconData icon;
  OnboardingFeature(this.label, this.icon);
}
