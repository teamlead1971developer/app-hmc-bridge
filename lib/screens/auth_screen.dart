import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/company.dart';
import '../services/auth_session_service.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_controls.dart';

enum _AuthPanel { signIn, register, forgotPassword }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _AuthPanel _panel = _AuthPanel.signIn;
  Company _company = Company.defaultCompany;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlassBackground.position.value = GlowPosition.top;
    });
  }

  @override
  Widget build(BuildContext context) {
    final signInSelected = _panel != _AuthPanel.register;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 12, 26, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(kLogoAsset, height: 24, fit: BoxFit.contain, alignment: Alignment.centerLeft),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_panel == _AuthPanel.forgotPassword)
                        _ForgotPasswordPanel(
                          onBack: () => setState(() => _panel = _AuthPanel.signIn),
                        )
                      else ...[
                        Text('Welcome back', style: displayStyle(size: 34, weight: 600)),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in with your corporate account.',
                          style: bodyStyle(size: 14, color: kTextMuted),
                        ),
                        const SizedBox(height: 28),
                        AuthSegmentedPill(
                          signInSelected: signInSelected,
                          onSignIn: () => setState(() => _panel = _AuthPanel.signIn),
                          onRegister: () => setState(() => _panel = _AuthPanel.register),
                        ),
                        const SizedBox(height: 20),
                        GlassCompanySelector(
                          value: _company,
                          onChanged: (company) => setState(() => _company = company),
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: signInSelected
                              ? _SignInForm(
                                  key: const ValueKey('signIn'),
                                  company: _company,
                                  onForgotPassword: () =>
                                      setState(() => _panel = _AuthPanel.forgotPassword),
                                )
                              : _RegisterForm(
                                  key: const ValueKey('register'),
                                  company: _company,
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Text(
                'For authorized personnel only.',
                style: bodyStyle(size: 12, color: kTextFaint),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm({
    super.key,
    required this.company,
    required this.onForgotPassword,
  });

  final Company company;
  final VoidCallback onForgotPassword;

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await AuthSessionService.instance.completeCorporateSignIn(
        company: widget.company,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassInputRow(
            label: 'Work email',
            controller: _email,
            icon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required.';
              if (!v.contains('@')) return 'Enter a valid email address.';
              return null;
            },
          ),
          const SizedBox(height: 12),
          GlassInputRow(
            label: 'Password',
            controller: _password,
            icon: LucideIcons.lock,
            obscureText: _obscure,
            trailing: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(
                _obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 18,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required.';
              return null;
            },
          ),
          const SizedBox(height: 20),
          BridgePrimaryButton(label: 'Sign in', onPressed: _submit),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: widget.onForgotPassword,
            child: Text(
              'Forgot password?',
              style: bodyStyle(size: 13, color: kRedLight),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm({super.key, required this.company});

  final Company company;

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await AuthSessionService.instance.completeCorporateSignIn(
        company: widget.company,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassInputRow(
            label: 'Full name',
            controller: _name,
            icon: LucideIcons.user,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Full name is required.';
              return null;
            },
          ),
          const SizedBox(height: 12),
          GlassInputRow(
            label: 'Work email',
            controller: _email,
            icon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required.';
              if (!v.contains('@')) return 'Enter a valid email address.';
              return null;
            },
          ),
          const SizedBox(height: 12),
          GlassInputRow(
            label: 'Password',
            controller: _password,
            icon: LucideIcons.lock,
            obscureText: _obscurePassword,
            trailing: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 18,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required.';
              if (v.length < 8) return 'Password must be at least 8 characters.';
              return null;
            },
          ),
          const SizedBox(height: 12),
          GlassInputRow(
            label: 'Confirm password',
            controller: _confirm,
            icon: LucideIcons.lock,
            obscureText: _obscureConfirm,
            trailing: GestureDetector(
              onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
              child: Icon(
                _obscureConfirm ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 18,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password.';
              if (v != _password.text) return 'Passwords do not match.';
              return null;
            },
          ),
          const SizedBox(height: 20),
          BridgePrimaryButton(label: 'Submit request', onPressed: _submit),
        ],
      ),
    );
  }
}

class _ForgotPasswordPanel extends StatefulWidget {
  const _ForgotPasswordPanel({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_ForgotPasswordPanel> createState() => _ForgotPasswordPanelState();
}

class _ForgotPasswordPanelState extends State<_ForgotPasswordPanel> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(LucideIcons.mailCheck, size: 32, color: kRedLight),
          const SizedBox(height: 16),
          Text('Check your email', style: displayStyle(size: 22, weight: 600), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'We sent password reset instructions to ${_email.text}. '
            'Follow the link in the email to continue.',
            style: bodyStyle(size: 14, color: kTextMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          BridgePrimaryButton(label: 'Back to sign in', onPressed: widget.onBack),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Reset password', style: displayStyle(size: 28, weight: 600)),
        const SizedBox(height: 8),
        Text(
          'Enter your work email and we will send you reset instructions.',
          style: bodyStyle(size: 14, color: kTextMuted),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassInputRow(
                label: 'Work email',
                controller: _email,
                icon: LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required.';
                  if (!v.contains('@')) return 'Enter a valid email address.';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              BridgePrimaryButton(
                label: _sending ? 'Sending…' : 'Send reset link',
                onPressed: _sending ? null : _submit,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: widget.onBack,
                child: Text(
                  'Back to sign in',
                  style: bodyStyle(size: 13, color: kRedLight),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
