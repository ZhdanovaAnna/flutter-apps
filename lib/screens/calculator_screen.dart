import 'package:flutter/material.dart';

import '../core/bmi_calculator.dart';
import '../core/constants.dart';
import '../services/supabase_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/design_button.dart';
import '../widgets/design_text_field.dart';
import '../widgets/screen_shell.dart';
import 'profile_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _height = TextEditingController();
  final _weight = TextEditingController();

  final _heightFocus = FocusNode();
  final _weightFocus = FocusNode();

  final _heightKey = GlobalKey();
  final _weightKey = GlobalKey();

  BmiResult? _result;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _heightFocus.addListener(() {
      if (_heightFocus.hasFocus) {
        _ensureVisible(_heightKey);
      }
    });

    _weightFocus.addListener(() {
      if (_weightFocus.hasFocus) {
        _ensureVisible(_weightKey);
      }
    });
  }

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    _heightFocus.dispose();
    _weightFocus.dispose();
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
      alignment: .15,
    );
  }

  double? _parse(String value) {
    return double.tryParse(value.replaceAll(',', '.'));
  }

  Future<void> _calculate() async {
    FocusScope.of(context).unfocus();

    final height = _parse(_height.text.trim());

    final weight = _parse(_weight.text.trim());

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      setState(() {
        _error = 'Заполните все поля';
        _result = null;
      });
      return;
    }

    if (height < 80 || height > 250 || weight < 20 || weight > 400) {
      setState(() {
        _error = 'Проверьте значения роста и веса';
        _result = null;
      });
      return;
    }

    final result = BmiCalculator.calculate(heightCm: height, weightKg: weight);

    setState(() {
      _result = result;
      _error = null;
      _saving = true;
    });

    try {
      await SupabaseService.instance.saveBmi(
        heightCm: height,
        weightKg: weight,
        bmi: double.parse(result.value.toStringAsFixed(2)),
        recommendation: result.recommendation,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Результат рассчитан, но не сохранён в облако.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return DesignScreen(
      bottomNavigationBar: BottomNav(
        selectedIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),

          Text(
            'Индекс массы тела',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.green,
              fontSize: screenWidth < 360 ? 26 : 30,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 24),

          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  key: _heightKey,
                  child: DesignTextField(
                    controller: _height,
                    focusNode: _heightFocus,
                    label: 'Рост (см)',
                    hint: '185',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _weightFocus.requestFocus(),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  key: _weightKey,
                  child: DesignTextField(
                    controller: _weight,
                    focusNode: _weightFocus,
                    label: 'Вес (кг)',
                    hint: '77',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!_saving) {
                        _calculate();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          DesignButton(
            text: _saving ? 'СОХРАНЕНИЕ...' : 'РАССЧИТАТЬ',
            onPressed: _saving ? null : _calculate,
          ),

          const SizedBox(height: 12),

          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.red, fontSize: 14),
          ),

          if (_result != null) ...[
            const SizedBox(height: 20),
            _ResultCard(result: _result!),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final BmiResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Ваш индекс массы тела',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.green,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            result.value.toStringAsFixed(2),
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            result.category,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            result.recommendation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
