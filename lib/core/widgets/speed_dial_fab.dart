import 'package:flutter/material.dart';
import '../../core/services/communication_service.dart';
import 'ai_assistant_sheet.dart';

/// An animated Floating Action Button that expands into a premium speed-dial
/// with four actions: AI Assistant, Email, Call, and SMS.
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
      icon: Icons.auto_awesome_rounded,
      label: 'AI Assistant',
      color: Color(0xFF8E2DE2), // Premium Purple
      isGold: true,
    ),
    _DialAction(
      icon: Icons.email_rounded,
      label: 'Email',
      color: Color(0xFF6C63FF),
    ),
    _DialAction(
      icon: Icons.phone_rounded,
      label: 'Call',
      color: Color(0xFF00C896),
    ),
    _DialAction(
      icon: Icons.sms_rounded,
      label: 'SMS',
      color: Color(0xFFFF6B6B),
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
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleAction(int index) {
    _toggle();
    switch (index) {
      case 0: // AI Assistant
        _showAiSheet();
        break;
      case 1: // Email
        CommunicationService.launchEmail(
          context,
          to: CommunicationService.supportEmail,
          subject: 'DriveEasy Support Request',
          body: 'Hi DriveEasy team, I need help with...',
        );
        break;
      case 2: // Call
        CommunicationService.launchCall(
          context,
          CommunicationService.supportPhone,
        );
        break;
      case 3: // SMS
        CommunicationService.launchSms(
          context,
          CommunicationService.supportPhone,
          body: 'Hi DriveEasy, I need assistance with...',
        );
        break;
    }
  }

  void _showAiSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiAssistantSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Dial Actions ──────────
        ...List.generate(_actions.length, (index) {
          final action = _actions[index];
          final start = ( _actions.length - 1 - index ) * 0.1;
          final end = start + 0.6;
          
          final slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(start.clamp(0,1), end.clamp(0,1), curve: Curves.easeOutBack),
            ),
          );

          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: _buildMiniFab(index, action),
            ),
          );
        }),
        const SizedBox(height: 16),
        // ── Main Trigger ──────────
        GestureDetector(
          onTap: _toggle,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isOpen
                  ? const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 36, key: ValueKey('close'))
                  : const Icon(Icons.support_agent_rounded, color: Colors.white, size: 28, key: ValueKey('contact')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniFab(int index, _DialAction action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label with Glassmorphism feel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
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
          const SizedBox(width: 12),
          // Gradient FABs
          GestureDetector(
            onTap: () => _handleAction(index),
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [action.color, action.color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: action.color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
  final bool isGold;

  const _DialAction({
    required this.icon,
    required this.label,
    required this.color,
    this.isGold = false,
  });
}
