import 'package:flutter/material.dart';

import '../core/bmi_calculator.dart';
import '../core/constants.dart';
import '../models/bmi_record.dart';
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
  BmiResult? _result;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  double? _parse(String value) => double.tryParse(value.replaceAll(',', '.'));

  Future<void> _calculate() async {
    FocusScope.of(context).unfocus();
    final height = _parse(_height.text.trim());
    final weight = _parse(_weight.text.trim());

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      setState(() {
        _error = 'Заполните все поля!';
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
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DesignScreen(
      child: Column(
        children: [
          const SizedBox(height: 119),
          const Text(
            'Индекс массы тела',
            style: TextStyle(
              color: AppColors.green,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 190,
            height: 116,
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 7,
                  spreadRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 39,
                  child: DesignTextField(
                    controller: _height,
                    label: 'Рост (см)',
                    hint: '',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 39,
                  child: DesignTextField(
                    controller: _weight,
                    label: 'Вес (кг)',
                    hint: '',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: DesignButton(
              text: _saving ? 'СОХРАНЕНИЕ...' : 'РАССЧИТАТЬ',
              onPressed: _saving ? null : _calculate,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            _error ?? (_result == null ? 'Заполните все поля!' : ''),
            style: const TextStyle(color: AppColors.red, fontSize: 7),
          ),
          if (_result != null) ...[
            const SizedBox(height: 8),
            _ResultCard(result: _result!),
          ],
          const Spacer(),
          BottomNav(
            selectedIndex: 0,
            onTap: (index) {
              if (index == 1) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              }
            },
          ),
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
      width: 190,
      constraints: const BoxConstraints(minHeight: 83),
      padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ваш индекс массы тела:',
            style: TextStyle(color: AppColors.green, fontSize: 8.5),
          ),
          const SizedBox(height: 3),
          Text(
            result.value.toStringAsFixed(2),
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${result.category}. ${result.recommendation}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 7.2,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
