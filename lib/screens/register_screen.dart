import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/supabase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _nameFocus = FocusNode();
  final _surnameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final _nameKey = GlobalKey();
  final _surnameKey = GlobalKey();
  final _emailKey = GlobalKey();
  final _passwordKey = GlobalKey();

  final _scrollController = ScrollController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _nameFocus.addListener(() {
      if (_nameFocus.hasFocus) {
        _scrollToField(_nameKey);
      }
    });

    _surnameFocus.addListener(() {
      if (_surnameFocus.hasFocus) {
        _scrollToField(_surnameKey);
      }
    });

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
    _name.dispose();
    _surname.dispose();
    _email.dispose();
    _password.dispose();

    _nameFocus.dispose();
    _surnameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _scrollToField(GlobalKey key) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    final context = key.currentContext;
    if (context == null) return;

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: 0.2,
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? '' : null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())
        ? null
        : '';
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _error = 'Заполните все поля';
      });
      return;
    }

    if (_password.text.length < 6) {
      setState(() {
        _error = 'Пароль должен содержать минимум 6 символов';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await SupabaseService.instance.signUp(
        firstName: _name.text.trim(),
        lastName: _surname.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;

      if (response.session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Регистрация успешна. '
              'Подтвердите email и войдите.',
            ),
          ),
        );

        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось создать аккаунт';
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

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.text,
          onPressed: () => Navigator.of(context).pop(),
        ),

        title: const Text(
          'Регистрация',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        top: false,

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
                  12,
                  horizontalPadding,
                  32,
                ),

                child: Center(
                  child: SizedBox(
                    width: cardWidth,

                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        Text(
                          'Создание аккаунта',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: width < 360 ? 25 : 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(20),

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
                              children: [
                                Container(
                                  key: _nameKey,
                                  child: _RegisterField(
                                    controller: _name,
                                    focusNode: _nameFocus,
                                    label: 'Имя',
                                    hint: 'Введите ваше имя',
                                    textInputAction: TextInputAction.next,
                                    validator: _required,
                                    onSubmitted: (_) {
                                      _surnameFocus.requestFocus();
                                    },
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Container(
                                  key: _surnameKey,
                                  child: _RegisterField(
                                    controller: _surname,
                                    focusNode: _surnameFocus,
                                    label: 'Фамилия',
                                    hint: 'Введите вашу фамилию',
                                    textInputAction: TextInputAction.next,
                                    validator: _required,
                                    onSubmitted: (_) {
                                      _emailFocus.requestFocus();
                                    },
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Container(
                                  key: _emailKey,
                                  child: _RegisterField(
                                    controller: _email,
                                    focusNode: _emailFocus,
                                    label: 'Email',
                                    hint: 'example@gmail.com',
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: _emailValidator,
                                    onSubmitted: (_) {
                                      _passwordFocus.requestFocus();
                                    },
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Container(
                                  key: _passwordKey,
                                  child: _RegisterField(
                                    controller: _password,
                                    focusNode: _passwordFocus,
                                    label: 'Пароль',
                                    hint: 'Введите пароль',
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    validator: _required,
                                    onSubmitted: (_) {
                                      if (!_loading) {
                                        _register();
                                      }
                                    },
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
                            onPressed: _loading ? null : _register,

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
                              _loading ? 'СОЗДАНИЕ...' : 'СОЗДАТЬ АККАУНТ',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (_error != null)
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.red,
                              fontSize: 14,
                            ),
                          ),

                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: _loading
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                },

                          child: const Text(
                            'Вернуться ко входу',
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RegisterField extends StatelessWidget {
  const _RegisterField({
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

      style: const TextStyle(fontSize: 16, color: AppColors.text),

      cursorColor: AppColors.green,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: const TextStyle(color: AppColors.muted, fontSize: 16),

        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 16),

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
