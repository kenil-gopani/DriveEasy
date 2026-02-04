import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text(AppStrings.helpSupport)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.support_agent,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Need Help?',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our support team is here to help you 24/7',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildContactButton(Icons.email, 'Email'),
                      const SizedBox(width: 16),
                      _buildContactButton(Icons.phone, 'Call'),
                      const SizedBox(width: 16),
                      _buildContactButton(Icons.chat, 'Chat'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // FAQ section
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              'How do I book a car?',
              'Browse through our collection of cars, select your preferred vehicle, choose your pickup dates and location, and complete the payment to confirm your booking.',
            ),
            _buildFAQItem(
              context,
              'Can I cancel my booking?',
              'Yes, you can cancel your booking from the Booking History section. Cancellation policies may apply depending on how close to the pickup date you cancel.',
            ),
            _buildFAQItem(
              context,
              'What payment methods are accepted?',
              'We accept UPI, Credit/Debit Cards, and Cash on pickup. All online payments are secure and encrypted.',
            ),
            _buildFAQItem(
              context,
              'What documents do I need?',
              'You need a valid driving license, government-issued ID proof, and the credit/debit card used for booking (if applicable).',
            ),
            _buildFAQItem(
              context,
              'Is insurance included?',
              'Basic insurance is included with all rentals. You can opt for additional coverage at the time of pickup.',
            ),
            _buildFAQItem(
              context,
              'What if the car breaks down?',
              'We provide 24/7 roadside assistance. Contact our support team immediately, and we\'ll arrange for assistance or a replacement vehicle.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(question, style: Theme.of(context).textTheme.titleMedium),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
