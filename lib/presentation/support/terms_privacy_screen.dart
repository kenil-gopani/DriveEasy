import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          title: const Text(AppStrings.termsPrivacy),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Terms of Service'),
              Tab(text: 'Privacy Policy'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: TabBarView(
          children: [
            _buildTermsOfService(context),
            _buildPrivacyPolicy(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsOfService(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms of Service',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: January 2026',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            '1. Acceptance of Terms',
            'By accessing and using RentCarPro, you accept and agree to be bound by the terms and conditions of this agreement.',
          ),
          _buildSection(
            context,
            '2. Rental Requirements',
            'Users must be at least 21 years old, possess a valid driver\'s license, and provide a valid form of payment to rent vehicles through our platform.',
          ),
          _buildSection(
            context,
            '3. Booking and Payment',
            'All bookings are subject to vehicle availability. Payment is required at the time of booking. We accept various payment methods including credit cards, debit cards, and UPI.',
          ),
          _buildSection(
            context,
            '4. Cancellation Policy',
            'Free cancellation is available up to 24 hours before the scheduled pickup time. Cancellations made within 24 hours may be subject to a cancellation fee.',
          ),
          _buildSection(
            context,
            '5. Vehicle Use',
            'Vehicles must only be used for lawful purposes. The renter is responsible for any traffic violations, parking tickets, or tolls incurred during the rental period.',
          ),
          _buildSection(
            context,
            '6. Insurance and Liability',
            'Basic insurance coverage is included with all rentals. Additional coverage options are available. The renter is responsible for any damages not covered by insurance.',
          ),
          _buildSection(
            context,
            '7. Fuel Policy',
            'Vehicles are provided with a full tank of fuel and must be returned with a full tank. Failure to do so will result in refueling charges.',
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Policy',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: January 2026',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            '1. Information We Collect',
            'We collect personal information such as your name, email address, phone number, and payment details when you create an account or make a booking.',
          ),
          _buildSection(
            context,
            '2. How We Use Your Information',
            'We use your information to process bookings, provide customer support, send booking confirmations and updates, and improve our services.',
          ),
          _buildSection(
            context,
            '3. Information Sharing',
            'We do not sell your personal information. We may share your information with service providers who assist us in operating our platform and providing services.',
          ),
          _buildSection(
            context,
            '4. Data Security',
            'We implement industry-standard security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.',
          ),
          _buildSection(
            context,
            '5. Your Rights',
            'You have the right to access, update, or delete your personal information. You can manage your account settings or contact us for assistance.',
          ),
          _buildSection(
            context,
            '6. Cookies',
            'We use cookies and similar technologies to enhance your experience, analyze usage, and assist in our marketing efforts.',
          ),
          _buildSection(
            context,
            '7. Contact Us',
            'If you have questions about this Privacy Policy, please contact us at support@rentcarpro.com.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
