import 'package:flutter/material.dart';
import '../../core/services/communication_service.dart';

/// An animated Floating Action Button that expands into a speed-dial
/// with three actions: Email, Call, and SMS.
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
      duration: const Duration(milliseconds: 280),
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
      case 0:
        CommunicationService.launchEmail(
          context,
          to: CommunicationService.supportEmail,
          subject: 'DriveEasy Support Request',
          body: 'Hi DriveEasy team, I need help with...',
        );
      case 1:
        CommunicationService.launchCall(
          context,
          CommunicationService.supportPhone,
        );
      case 2:
        CommunicationService.launchSms(
          context,
          CommunicationService.supportPhone,
          body: 'Hi DriveEasy, I need assistance with...',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Mini action buttons (slide up, staggered) ──────────
        ..._actions.asMap().entries.map((entry) {
          final i = entry.key;
          final action = entry.value;
          // Stagger offset: each button has slightly delayed interval
          final start = i * 0.1;
          final end = start + 0.6;
          final slideAnim =
              Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    start.clamp(0, 1),
                    end.clamp(0, 1),
                    curve: Curves.easeOut,
                  ),
                ),
              );
          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: _buildMiniFab(i, action),
            ),
          );
        }),
        const SizedBox(height: 12),
        // ── Main FAB ───────────────────────────────────────────
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: const Color(0xFF6C63FF),
          elevation: 6,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: _isOpen
                ? const Icon(
                    Icons.close_rounded,
                    key: ValueKey('close'),
                    color: Colors.white,
                    size: 26,
                  )
                : const Icon(
                    Icons.contact_support_rounded,
                    key: ValueKey('contact'),
                    color: Colors.white,
                    size: 26,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniFab(int index, _DialAction action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              action.label,
              style: TextStyle(
                color: action.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Circle button
          GestureDetector(
            onTap: () => _handleAction(index),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: action.color,
              child: Icon(action.icon, color: Colors.white, size: 20),
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

  const _DialAction({
    required this.icon,
    required this.label,
    required this.color,
  });
}
