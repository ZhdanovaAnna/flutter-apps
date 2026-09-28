import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/supabase_service.dart';
import '../widgets/design_button.dart';
import '../widgets/design_text_field.dart';
import '../widgets/screen_shell.dart';
import 'calculator_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();

  final _password = TextEditingController();

  final _emailFocus = FocusNode();

  final _passwordFocus = FocusNode();

  final _emailKey = GlobalKey();

  final _passwordKey = GlobalKey();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        _ensureVisible(_emailKey);
      }
    });

    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) {
        _ensureVisible(_passwordKey);
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _ensureVisible(GlobalKey key) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    final fieldContext = key.currentContext;

    if (fieldContext == null) return;

    await Scrollable.ensureVisible(
      fieldContext,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: .2,
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? '' : null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())
        ? null
        : '';
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _error = 'Заполните все поля';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await SupabaseService.instance.signIn(
        email: _email.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CalculatorScreen()),
        (route) => false,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Неверный email или пароль';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DesignScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),

          Text(
            'Вход в приложение',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.green,
              fontSize: MediaQuery.sizeOf(context).width < 360 ? 26 : 30,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 24),

          DesignCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    key: _emailKey,
                    child: DesignTextField(
                      controller: _email,
                      focusNode: _emailFocus,
                      label: 'Email',
                      hint: 'example@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      onFieldSubmitted: (_) {
                        _passwordFocus.requestFocus();
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    key: _passwordKey,
                    child: DesignTextField(
                      controller: _password,
                      focusNode: _passwordFocus,
                      label: 'Пароль',
                      hint: 'Введите пароль',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: _required,
                      onFieldSubmitted: (_) {
                        if (!_loading) {
                          _login();
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                    child: const Text(
                      'Зарегистрироваться',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          DesignButton(
            text: _loading ? 'ВХОД...' : 'ВОЙТИ',
            onPressed: _loading ? null : _login,
          ),

          const SizedBox(height: 12),

          Text(
            _error ?? 'Введите email и пароль',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _error == null ? AppColors.muted : AppColors.red,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
