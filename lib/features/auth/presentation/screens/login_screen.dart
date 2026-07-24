import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../application/auth_provider.dart';
import '../../domain/models/user_role.dart';
import '../widgets/role_selector.dart';
import '../../../../core/utils/responsive_utils.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    final formWidget = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          _buildRoleSelectorLabel(theme),
          const SizedBox(height: AppSpacing.sm),
          RoleSelector(
            selected: _selectedRole,
            onChanged: (role) => setState(() => _selectedRole = role),
          ),
          const SizedBox(height: AppSpacing.lg),

          AppTextField(
            label: 'Email Address',
            controller: _emailController,
            hint: 'name@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          _buildPasswordLabel(context, theme),
          const SizedBox(height: 8),
          AppTextField(
            label: '', // Hidden label as we build it custom above
            controller: _passwordController,
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            validator: Validators.password,
            onFieldSubmitted: (_) => _submit(),
          ),
          
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _rememberMe,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  onChanged: (v) => setState(() => _rememberMe = v ?? true),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Remember this device', style: TextStyle(color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          PrimaryButton(
            label: 'Login',
            isLoading: authState.isLoading,
            icon: Icons.arrow_forward_rounded,
            onPressed: authState.isLoading ? null : _submit,
          ),
          
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              children: [
                const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF64748B))),
                GestureDetector(
                  onTap: () => context.pushNamed(RouteNames.register),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: AppColors.royalBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return ResponsiveBuilder(
      builder: (context, screenType, child) {
        if (screenType == ScreenType.desktop || screenType == ScreenType.wideDesktop) {
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
                                  Icons.auto_stories_rounded,
                                  color: Colors.white,
                                  size: 52,
                                ),
                              ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                'LibreFlow',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Intellectual stimulation, efficiently managed.',
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
                  flex: 4,
                  child: Container(
                    color: isDark ? AppColors.backgroundDark : Colors.white,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(context.responsivePadding * 2),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: formWidget,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: isDark ? null : AppColors.lightBgGradient,
              color: isDark ? AppColors.backgroundDark : null,
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsivePadding,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      // App Icon / Logo
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.royalBlue,
                          size: 36,
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      Text(
                        'Digital Sanctuary',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          letterSpacing: -1,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      
                      const SizedBox(height: 8),
                      Text(
                        'Intellectual stimulation, efficiently managed.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      
                      const SizedBox(height: AppSpacing.xxl),
                      
                      // Main Login Card
                      Container(
                        constraints: const BoxConstraints(maxWidth: 520),
                        padding: EdgeInsets.all(screenType == ScreenType.mobile ? 24 : 32),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: formWidget,
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Social Login Section
                      _buildSocialDivider(theme),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.sm,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: _SocialButton(
                              icon: Icons.g_mobiledata_rounded,
                              label: 'Google',
                              onTap: () {},
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: _SocialButton(
                              icon: Icons.fingerprint_rounded,
                              label: 'Biometrics',
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'System Version 2.4.0 • Sanctuary Secured',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
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

  Widget _buildRoleSelectorLabel(ThemeData theme) {
    return Text(
      'Account Type',
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildPasswordLabel(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Password',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        GestureDetector(
          onTap: () => context.pushNamed(RouteNames.forgotPassword),
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: AppColors.royalBlue,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialDivider(ThemeData theme) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDark ? Colors.white : const Color(0xFF1E293B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
