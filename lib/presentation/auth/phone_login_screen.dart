import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/widgets/otp_input_field.dart';
import '../providers/auth_provider.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _otp = '';
  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;

  String _selectedCountryCode = '+91';
  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
    {'code': '+1', 'name': 'USA', 'flag': '🇺🇸'},
    {'code': '+44', 'name': 'UK', 'flag': '🇬🇧'},
    {'code': '+61', 'name': 'Australia', 'flag': '🇦🇺'},
    {'code': '+971', 'name': 'UAE', 'flag': '🇦🇪'},
    {'code': '+65', 'name': 'Singapore', 'flag': '🇸🇬'},
  ];

  Timer? _resendTimer;
  int _resendSeconds = 60;
  bool _canResend = false;

  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
    _contentController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _resendTimer?.cancel();
    _contentController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendSeconds > 0) {
            _resendSeconds--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  String get _formattedPhone => '$_selectedCountryCode${_phoneController.text.trim()}';

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).sendPhoneOTP(
            phoneNumber: _formattedPhone,
            onCodeSent: (verificationId) {
              if (mounted) {
                setState(() {
                  _verificationId = verificationId;
                  _codeSent = true;
                  _isLoading = false;
                });
                _startResendTimer();
                _contentController.reset();
                _contentController.forward();
                Helpers.showSnackBar(context, 'OTP sent to $_formattedPhone');
              }
            },
            onVerificationCompleted: (credential) async {
              setState(() => _isLoading = true);
              try {
                await ref.read(authNotifierProvider.notifier).signInWithPhoneCredential(credential);
                if (mounted) {
                  final user = ref.read(currentUserProvider).valueOrNull;
                  if (user != null && !user.profileComplete) {
                    context.go(AppRoutes.completeProfile);
                  } else {
                    context.go(AppRoutes.home);
                  }
                }
              } catch (e) {
                if (mounted) Helpers.showSnackBar(context, e.toString(), isError: true);
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            onVerificationFailed: (error) {
              if (mounted) {
                setState(() => _isLoading = false);
                Helpers.showSnackBar(context, error, isError: true);
              }
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (_otp.length != 6) {
      Helpers.showSnackBar(context, 'Please enter 6-digit OTP', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).verifyPhoneOTP(
        verificationId: _verificationId!,
        smsCode: _otp,
      );
      if (mounted) {
        final user = ref.read(currentUserProvider).valueOrNull;
        if (user != null && !user.profileComplete) {
          context.go(AppRoutes.completeProfile);
        } else {
          context.go(AppRoutes.home);
        }
      }
    } catch (e) {
      if (mounted) Helpers.showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    if (_codeSent) {
      setState(() {
        _codeSent = false;
        _otp = '';
        _verificationId = null;
        _resendTimer?.cancel();
      });
      _contentController.reset();
      _contentController.forward();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: _goBack,
        ),
        title: Text(
          _codeSent ? 'Verification' : 'Phone Login',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeroIcon(),
                      const SizedBox(height: 48),
                      Text(
                        _codeSent ? 'Enter OTP Code' : 'Phone Number',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _codeSent
                            ? 'We\'ve sent a 6-digit code to\n$_formattedPhone'
                            : 'Enter your phone number to receive a verification code',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      if (!_codeSent) ...[
                        _buildPhoneInput(),
                        const SizedBox(height: 40),
                        PrimaryButton(
                          text: 'Send Code',
                          onPressed: _sendOTP,
                          isLoading: _isLoading,
                        ),
                      ] else ...[
                        _buildOTPSection(),
                        const SizedBox(height: 40),
                        PrimaryButton(
                          text: 'Verify OTP',
                          onPressed: _otp.length == 6 ? _verifyOTP : null,
                          isLoading: _isLoading,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF34D399)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            _codeSent ? Icons.shield_rounded : Icons.phone_android_rounded,
            size: 44,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showCountryPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Text(_countryCodes.firstWhere((c) => c['code'] == _selectedCountryCode)['flag']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(_selectedCountryCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              decoration: const InputDecoration(
                hintText: '00000 00000',
                hintStyle: TextStyle(color: AppColors.textLight, letterSpacing: 1),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
              validator: Validators.phone,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPSection() {
    return Column(
      children: [
        OTPInputField(
          length: 6,
          onCompleted: (otp) {
            setState(() => _otp = otp);
            _verifyOTP();
          },
          onChanged: (otp) => setState(() => _otp = otp),
        ),
        const SizedBox(height: 32),
        if (!_canResend)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Resend code in ${_resendSeconds}s',
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
            ],
          )
        else
          TextButton.icon(
            onPressed: () {
              setState(() => _otp = '');
              _sendOTP();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Resend OTP Now'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF0D7FF2)),
          ),
      ],
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Country', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ..._countryCodes.map((c) => ListTile(
              leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
              title: Text(c['name']!),
              trailing: Text(c['code']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                setState(() => _selectedCountryCode = c['code']!);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}
