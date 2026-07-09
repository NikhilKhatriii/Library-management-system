import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../application/auth_provider.dart';
import '../../domain/models/user_role.dart';
import '../widgets/role_selector.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'jane.doe@libreflow.app');
  final _passwordController = TextEditingController(text: 'password123');
  UserRole _selectedRole = UserRole.student;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
          rememberMe: _rememberMe,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: AppBackgrounds.auth(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_stories_rounded,
                    size: 64,
                    color: AppColors.royalBlue,
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'LibreFlow',
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
                          Text(
                            'Sign In',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Welcome back to your workspace',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          Text('Select Role', style: theme.textTheme.labelLarge),
                          const SizedBox(height: AppSpacing.sm),
                          RoleSelector(
                            selected: _selectedRole,
                            onChanged: (role) => setState(() => _selectedRole = role),
                          ),
                          const SizedBox(height: AppSpacing.lg),

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
                            hint: 'Enter your password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: Validators.password,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Remember me'),
                              const Spacer(),
                              TextButton(
                                onPressed: () => context.pushNamed(RouteNames.forgotPassword),
                                child: const Text('Forgot password?'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          PrimaryButton(
                            label: 'Sign In',
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
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => context.pushNamed(RouteNames.register),
                        child: Text(
                          'Create one',
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
