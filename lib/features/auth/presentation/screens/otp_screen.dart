import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../application/auth_provider.dart';

/// Six-digit OTP entry screen, e.g. for email verification during
/// registration or as a second factor during login.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, this.destination = 'your email'});

  final String destination;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final ok = await ref.read(authProvider.notifier).verifyOtp(_code);
    if (!mounted) return;
    if (ok) {
      context.goNamed(RouteNames.login);
    } else {
      setState(() => _error = 'Invalid code. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          image: DecorationImage(
            image: const NetworkImage('https://images.unsplash.com/photo-1512428559087-560fa5ceab42?q=80&w=2000'),
            fit: BoxFit.cover,
            colorFilter: ColorScheme.fromSeed(seedColor: AppColors.royalBlue).brightness == Brightness.dark
                ? ColorFilter.mode(Colors.black.withValues(alpha: 0.7), BlendMode.darken)
                : ColorFilter.mode(Colors.white.withValues(alpha: 0.8), BlendMode.lighten),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton.filledTonal(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ).animate().fadeIn(),
                const Spacer(),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.sms_rounded, color: AppColors.royalBlue, size: 48)
                          .animate()
                          .scale(curve: Curves.easeOutBack),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Verify Code', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Enter the 6-digit code sent to ${widget.destination}.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) => _digitBox(index)),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(_error!, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: 'Verify',
                        isLoading: authState.isLoading,
                        onPressed: authState.isLoading ? null : _verify,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Verification code resent.')),
                            );
                          },
                          child: const Text("Didn't get a code? Resend"),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _digitBox(int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 44,
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _controllers[index].text.isNotEmpty 
              ? theme.colorScheme.primary 
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _nodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            setState(() => _error = null);
            if (value.isNotEmpty && index < 5) {
              _nodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _nodes[index - 1].requestFocus();
            }
            if (_code.length == 6) _verify();
          },
        ),
      ),
    );
  }
}
