import 'package:flutter/material.dart';
import '../../core/services/communication_service.dart';

/// Animated Speed Dial FAB — blue glassmorphism style
/// Actions: Email, Call, SMS
class SpeedDialFab extends StatefulWidget {
  const SpeedDialFab({super.key});

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  bool _isOpen = false;

  static const _actions = [
    _DialAction(
      icon: Icons.email_rounded,
      label: 'Email',
      color: Color(0xFF25AFF4),
    ),
    _DialAction(
      icon: Icons.phone_rounded,
      label: 'Call',
      color: Color(0xFF1C6EF2),
    ),
    _DialAction(
      icon: Icons.sms_rounded,
      label: 'SMS',
      color: Color(0xFF0EA5E9),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _controller.forward() : _controller.reverse();
  }

  void _handleAction(int index) {
    _toggle();
    switch (index) {
      case 0:
        CommunicationService.launchEmail(
          context,
          to: CommunicationService.supportEmail,
          subject: 'DriveEasy Support Request',
          body: 'Hi DriveEasy team, I need help with...',
        );
        break;
      case 1:
        CommunicationService.launchCall(
          context,
          CommunicationService.supportPhone,
        );
        break;
      case 2:
        CommunicationService.launchSms(
          context,
          CommunicationService.supportPhone,
          body: 'Hi DriveEasy, I need assistance with...',
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Dial Actions
        ...List.generate(_actions.length, (index) {
          final action = _actions[index];
          final start = (_actions.length - 1 - index) * 0.1;
          final end = (start + 0.6).clamp(0.0, 1.0);

          final slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _controller,
            curve: Interval(start.clamp(0, 1), end, curve: Curves.easeOutBack),
          ));

          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: _buildMiniFab(index, action),
            ),
          );
        }),
        const SizedBox(height: 16),
        // Main Trigger — glass blue orb
        GestureDetector(
          onTap: _toggle,
          child: Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1C6EF2), Color(0xFF25AFF4)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1C6EF2).withOpacity(0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF25AFF4).withOpacity(0.2),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isOpen
                  ? const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.white, size: 34, key: ValueKey('close'))
                  : const Icon(Icons.headset_mic_rounded,
                      color: Colors.white, size: 26, key: ValueKey('open')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniFab(int index, _DialAction action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Frosted glass label chip
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: action.color.withOpacity(0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: action.color.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                action.label,
                style: TextStyle(
                  color: action.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Glass circle FAB
          GestureDetector(
            onTap: () => _handleAction(index),
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [action.color, action.color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: action.color.withOpacity(0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Icon(action.icon, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialAction {
  final IconData icon;
  final String label;
  final Color color;
  const _DialAction({required this.icon, required this.label, required this.color});
}
