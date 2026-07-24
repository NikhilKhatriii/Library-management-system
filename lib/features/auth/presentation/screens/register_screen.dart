import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_background.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return ResponsiveBuilder(
      builder: (context, screenType, child) {
        final isDesktop = screenType == ScreenType.desktop || screenType == ScreenType.wideDesktop;
        
        final formFields = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Role', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            RoleSelector(
              selected: _selectedRole,
              onChanged: (role) => setState(() => _selectedRole = role),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      hint: 'Jane Doe',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) =>
                          (v == null || v.trim().length < 2) ? 'Enter your full name' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Email',
                      controller: _emailController,
                      hint: 'you@example.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                  ),
                ],
              )
            else ...[
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
            ],
            
            const SizedBox(height: AppSpacing.md),

            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Password',
                      controller: _passwordController,
                      hint: 'At least 8 characters',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: Validators.password,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
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
                  ),
                ],
              )
            else ...[
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
            ],
            
            const SizedBox(height: AppSpacing.xl),

            PrimaryButton(
              label: 'Create Account',
              isLoading: authState.isLoading,
              onPressed: authState.isLoading ? null : _submit,
            ),
          ],
        );

        final formWidget = Form(
          key: _formKey,
          child: formFields,
        );

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundDark,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.2,
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                           .fadeIn(duration: 3.seconds)
                           .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 10.seconds),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_add_rounded,
                                  color: Colors.white,
                                  size: 52,
                                ),
                              ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                'Join LibreFlow',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your digital library sanctuary awaits.',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    color: isDark ? AppColors.backgroundDark : Colors.white,
                    child: Stack(
                      children: [
                        Positioned(
                          top: AppSpacing.xl,
                          left: AppSpacing.xl,
                          child: IconButton.filledTonal(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ).animate().fadeIn(),
                        ),
                        Center(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(context.responsivePadding * 2),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create Account',
                                    style: theme.textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -1,
                                    ),
                                  ).animate().fadeIn(),
                                  const SizedBox(height: AppSpacing.xxl),
                                  formWidget,
                                  const SizedBox(height: AppSpacing.xl),
                                  Center(
                                    child: Wrap(
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: AppBackgrounds.auth(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.responsivePadding),
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

                      Container(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: GlassCard(
                          child: formWidget,
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                      ),
                      
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
      },
    );
  }
}
