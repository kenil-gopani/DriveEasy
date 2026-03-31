import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Displays a curated list of hardcoded English-only driving tips.
class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {

  // ── Static English car tips ───────────────────────────────────────────────
  static final List<_Tip> _tips = [
    _Tip(
      id: 1,
      category: 'Safety',
      icon: Icons.health_and_safety_outlined,
      title: 'Always Check Your Tyre Pressure',
      body: 'Under-inflated tyres reduce fuel efficiency and increase the risk of a blowout. Check your tyre pressure at least once a month and before any long trip. Refer to your car manual for the recommended PSI.',
    ),
    _Tip(
      id: 2,
      category: 'Maintenance',
      icon: Icons.opacity,
      title: 'Change Your Engine Oil Regularly',
      body: 'Engine oil lubricates moving parts and keeps the engine cool. Most modern cars require an oil change every 5,000–10,000 km. Skipping oil changes can lead to costly engine damage over time.',
    ),
    _Tip(
      id: 3,
      category: 'Fuel',
      icon: Icons.local_gas_station_outlined,
      title: 'Use the Right Fuel Grade',
      body: 'Always use the fuel grade recommended in your owner manual. Using a lower octane than required can cause engine knocking and reduce performance. Higher octane will not benefit an engine not designed for it.',
    ),
    _Tip(
      id: 4,
      category: 'Safety',
      icon: Icons.visibility_outlined,
      title: 'Keep Your Windshield Clean',
      body: 'A dirty windshield reduces visibility, especially at night or when driving into sunlight. Clean both the inside and outside regularly and replace worn wiper blades every 6–12 months.',
    ),
    _Tip(
      id: 5,
      category: 'Driving',
      icon: Icons.speed_outlined,
      title: 'Maintain a Safe Following Distance',
      body: 'Keep at least a 3-second gap between your car and the vehicle ahead. In wet or slippery conditions, double that distance. Tailgating is a leading cause of rear-end collisions on highways.',
    ),
    _Tip(
      id: 6,
      category: 'Maintenance',
      icon: Icons.battery_charging_full_outlined,
      title: 'Test Your Battery Before Winter',
      body: 'Cold weather can dramatically reduce battery performance. Have your battery tested before winter arrives. A battery older than 3 years should be inspected annually to avoid unexpected breakdowns.',
    ),
    _Tip(
      id: 7,
      category: 'Fuel',
      icon: Icons.eco_outlined,
      title: 'Avoid Idling for Long Periods',
      body: 'Idling for more than 60 seconds wastes more fuel than restarting the engine. Turn off your car when parked or waiting. Excessive idling also increases wear and carbon emissions.',
    ),
    _Tip(
      id: 8,
      category: 'Driving',
      icon: Icons.nightlight_outlined,
      title: 'Use High Beams Responsibly',
      body: 'High beams improve visibility on dark rural roads, but always switch to low beams when another vehicle approaches within 150 metres. Blinding other drivers with high beams is dangerous.',
    ),
    _Tip(
      id: 9,
      category: 'Maintenance',
      icon: Icons.settings_outlined,
      title: 'Rotate Your Tyres Every 8,000 km',
      body: 'Regular tyre rotation ensures even wear across all four tyres, extending their lifespan and maintaining balanced handling. Check your owner manual for the recommended rotation pattern.',
    ),
    _Tip(
      id: 10,
      category: 'Safety',
      icon: Icons.lock_outline,
      title: 'Never Leave Valuables in Your Car',
      body: 'Even out of sight, valuables left in a car are a theft risk. Thieves can break windows in seconds. Always take your belongings with you or store them in the boot before arriving at your destination.',
    ),
    _Tip(
      id: 11,
      category: 'Driving',
      icon: Icons.phone_disabled_outlined,
      title: 'No Phone While Driving',
      body: 'Using a mobile phone while driving increases crash risk by up to 4 times. If you must take a call, pull over safely. Use hands-free systems only when necessary and keep conversations brief.',
    ),
    _Tip(
      id: 12,
      category: 'Maintenance',
      icon: Icons.air_outlined,
      title: 'Replace Your Air Filter Annually',
      body: 'A clogged air filter restricts airflow to the engine, reducing power and fuel efficiency. Replacing it once a year (or every 15,000 km) is simple and affordable.',
    ),
    _Tip(
      id: 13,
      category: 'Safety',
      icon: Icons.warning_amber_outlined,
      title: 'Know What Your Dashboard Lights Mean',
      body: 'Ignoring warning lights can turn a minor issue into an expensive repair. Yellow lights usually mean caution; red lights require immediate attention. Consult your manual or a mechanic promptly.',
    ),
    _Tip(
      id: 14,
      category: 'Fuel',
      icon: Icons.drive_eta_outlined,
      title: 'Smooth Driving Saves Fuel',
      body: 'Aggressive acceleration and hard braking can increase fuel consumption by up to 30%. Anticipate traffic, accelerate gradually, and coast to a stop when safe to do so.',
    ),
    _Tip(
      id: 15,
      category: 'Maintenance',
      icon: Icons.water_drop_outlined,
      title: 'Top Up Coolant to Prevent Overheating',
      body: 'Engine coolant regulates temperature and prevents freezing. Check the coolant level monthly and top it up with the correct mixture. Low coolant can cause your engine to overheat quickly.',
    ),
  ];

  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Safety', 'Maintenance', 'Fuel', 'Driving'];

  List<_Tip> get _filtered => _selectedCategory == 'All'
      ? _tips
      : _tips.where((t) => t.category == _selectedCategory).toList();

  Color _catColor(String cat) {
    switch (cat) {
      case 'Safety':      return const Color(0xFFEF4444);
      case 'Maintenance': return const Color(0xFF3B82F6);
      case 'Fuel':        return const Color(0xFF10B981);
      case 'Driving':     return const Color(0xFFF59E0B);
      default:            return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Driving Tips', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // ── Premium Filter Pills ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  final color = cat == 'All' ? AppColors.primary : _catColor(cat);
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? color : color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected ? color.withValues(alpha: 0.5) : Colors.transparent,
                          width: 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected ? Colors.white : color.withValues(alpha: 0.9),
                          fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Tips list ────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final tip = _filtered[index];
                return TweenAnimationBuilder<double>(
                  key: ValueKey(tip.id),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 250 + index.clamp(0, 15) * 40),
                  curve: Curves.easeOut,
                  builder: (_, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, (1 - v) * 16),
                      child: child,
                    ),
                  ),
                  child: _TipCard(tip: tip, color: _catColor(tip.category)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _Tip {
  final int id;
  final String category;
  final IconData icon;
  final String title;
  final String body;
  const _Tip({
    required this.id,
    required this.category,
    required this.icon,
    required this.title,
    required this.body,
  });
}

// ── Card widget ───────────────────────────────────────────────────────────────
class _TipCard extends StatefulWidget {
  final _Tip tip;
  final Color color;
  const _TipCard({required this.tip, required this.color});

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.tip.icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.tip.category,
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.tip.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textLight,
                    size: 22,
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    widget.tip.body,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.6,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 220),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
