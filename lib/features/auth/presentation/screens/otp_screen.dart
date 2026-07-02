import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/primary_button.dart';
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
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Icon(Icons.sms_rounded, color: theme.colorScheme.primary, size: 40)
                  .animate()
                  .scale(curve: Curves.easeOutBack),
              const SizedBox(height: AppSpacing.lg),
              Text('Verify your identity', style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Enter the 6-digit code sent to ${widget.destination}.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _digitBox(index)),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
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
        ),
      ),
    );
  }

  Widget _digitBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _nodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: Theme.of(context).textTheme.titleLarge,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(counterText: ''),
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
    );
  }
}
