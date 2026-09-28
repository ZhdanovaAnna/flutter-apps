import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/supabase_service.dart';
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

  final _scrollController = ScrollController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        _scrollToField(_emailKey);
      }
    });

    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) {
        _scrollToField(_passwordKey);
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    _emailFocus.dispose();
    _passwordFocus.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _scrollToField(GlobalKey key) async {
    // Даём iOS Safari время открыть клавиатуру
    // и изменить доступную высоту viewport.
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    final context = key.currentContext;
    if (context == null) return;

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: 0.25,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final horizontalPadding = width < 360 ? 16.0 : 20.0;

            final cardWidth = (width - horizontalPadding * 2)
                .clamp(0.0, 440.0)
                .toDouble();

            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },

              child: SingleChildScrollView(
                controller: _scrollController,

                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,

                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  24,
                  horizontalPadding,
                  32,
                ),

                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 56,
                  ),

                  child: Center(
                    child: SizedBox(
                      width: cardWidth,

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),

                          Text(
                            'Вход в приложение',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: width < 360 ? 26 : 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Container(
                            width: double.infinity,

                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),

                            child: Form(
                              key: _formKey,

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,

                                children: [
                                  Container(
                                    key: _emailKey,
                                    child: _ResponsiveField(
                                      controller: _email,
                                      focusNode: _emailFocus,
                                      label: 'Email',
                                      hint: 'example@gmail.com',
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: _validateEmail,
                                      onSubmitted: (_) {
                                        _passwordFocus.requestFocus();
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Container(
                                    key: _passwordKey,
                                    child: _ResponsiveField(
                                      controller: _password,
                                      focusNode: _passwordFocus,
                                      label: 'Пароль',
                                      hint: 'Введите пароль',
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                      validator: _required,
                                      onSubmitted: (_) {
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
                                                builder: (_) =>
                                                    const RegisterScreen(),
                                              ),
                                            );
                                          },

                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      minimumSize: const Size(
                                        double.infinity,
                                        44,
                                      ),
                                    ),

                                    child: const Text(
                                      'Зарегистрироваться',
                                      textAlign: TextAlign.center,
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

                          SizedBox(
                            width: double.infinity,
                            height: 52,

                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.green
                                    .withValues(alpha: .55),
                                elevation: 0,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

                              child: Text(
                                _loading ? 'ВХОД...' : 'ВОЙТИ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),

                            child: Text(
                              _error ?? 'Введите email и пароль',
                              key: ValueKey(_error),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _error == null
                                    ? AppColors.muted
                                    : AppColors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ResponsiveField extends StatelessWidget {
  const _ResponsiveField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  final String label;
  final String hint;

  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,

      obscureText: obscureText,

      keyboardType: keyboardType,
      textInputAction: textInputAction,

      validator: validator,
      onFieldSubmitted: onSubmitted,

      // КЛЮЧЕВО ДЛЯ IPHONE SAFARI.
      // Реальный input должен быть >= 16px.
      style: const TextStyle(fontSize: 16, color: AppColors.text),

      cursorColor: AppColors.green,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        labelStyle: const TextStyle(fontSize: 16, color: AppColors.muted),

        hintStyle: const TextStyle(fontSize: 16, color: AppColors.muted),

        floatingLabelBehavior: FloatingLabelBehavior.always,

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.green, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.red, width: 2),
        ),

        errorStyle: const TextStyle(fontSize: 12, color: AppColors.red),
      ),
    );
  }
}
