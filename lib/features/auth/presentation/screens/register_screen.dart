import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../application/auth_provider.dart';
import '../../domain/models/user_role.dart';
import '../widgets/role_selector.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
        );
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
            image: const NetworkImage('https://images.unsplash.com/photo-1481627834876-b7833e8f5570?q=80&w=2000'),
            fit: BoxFit.cover,
            colorFilter: ColorScheme.fromSeed(seedColor: AppColors.royalBlue).brightness == Brightness.dark
                ? ColorFilter.mode(Colors.black.withValues(alpha: 0.7), BlendMode.darken)
                : ColorFilter.mode(Colors.white.withValues(alpha: 0.8), BlendMode.lighten),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
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
                  const SizedBox(height: AppSpacing.lg),
                  
                  const Icon(
                    Icons.person_add_rounded,
                    size: 64,
                    color: AppColors.royalBlue,
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: AppSpacing.lg),
                  
                  Text(
                    'Create Account',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppSpacing.xxl),

                  GlassCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Role', style: theme.textTheme.labelLarge),
                          const SizedBox(height: AppSpacing.sm),
                          RoleSelector(
                            selected: _selectedRole,
                            onChanged: (role) => setState(() => _selectedRole = role),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          AppTextField(
                            label: 'Full Name',
                            controller: _nameController,
                            hint: 'Jane Doe',
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (v) =>
                                (v == null || v.trim().length < 2) ? 'Enter your full name' : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Email',
                            controller: _emailController,
                            hint: 'you@example.com',
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Password',
                            controller: _passwordController,
                            hint: 'At least 8 characters',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: Validators.password,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Confirm Password',
                            controller: _confirmController,
                            hint: 'Re-enter password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (v) => v != _passwordController.text
                                ? 'Passwords do not match'
                                : null,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          PrimaryButton(
                            label: 'Create Account',
                            isLoading: authState.isLoading,
                            onPressed: authState.isLoading ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Sign in',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
