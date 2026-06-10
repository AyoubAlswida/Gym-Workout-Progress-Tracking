import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    final authVM = context.read<AuthViewModel>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final ok = _isRegister
        ? await authVM.signUp(email, password)
        : await authVM.signIn(email, password);

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.error ?? l10n.syncError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginScreenTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? l10n.email : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? l10n.password : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: authVM.isLoading ? null : _submit,
                  child: authVM.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isRegister ? l10n.createAccount : l10n.signIn),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      setState(() => _isRegister = !_isRegister),
                  child: Text(_isRegister
                      ? l10n.haveAccountSignIn
                      : l10n.noAccountRegister),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
