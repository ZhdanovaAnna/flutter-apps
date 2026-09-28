import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/bmi_record.dart';
import '../services/supabase_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/screen_shell.dart';
import 'calculator_screen.dart';
import '../widgets/design_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<BmiRecord> _history = const [];
  bool _loading = true;
  String? _error;

  String get _firstName => SupabaseService.instance.firstName;
  String get _lastName => SupabaseService.instance.lastName;
  String get _email => SupabaseService.instance.email;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final history = await SupabaseService.instance.getHistory();
      if (!mounted) return;
      setState(() => _history = history);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Не удалось загрузить историю расчётов');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _date(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year}, '
        '${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final fullName = '$_firstName $_lastName'.trim();

    return DesignScreen(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Container(
            width: 188,
            height: 104,
            padding: const EdgeInsets.fromLTRB(11, 12, 11, 8),
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
            child: Row(
              children: [
                const ClipOval(
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty ? 'Имя Фамилия' : fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 188,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: TextButton(
              onPressed: _loadHistory,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                alignment: Alignment.centerLeft,
              ),
              child: const Text(
                'Активность',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.red, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  )
                : _history.isEmpty
                ? const Center(
                    child: Text(
                      'История расчётов пока пуста',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 8),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final record = _history[index];
                      return _HistoryCard(
                        record: record,
                        dateText: _date(record.createdAt),
                      );
                    },
                  ),
          ),
          BottomNav(
            selectedIndex: 1,
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const CalculatorScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record, required this.dateText});

  final BmiRecord record;
  final String dateText;

  String _category(double bmi) {
    if (bmi <= 16) return 'Выраженный дефицит массы тела';
    if (bmi < 18.5) return 'Недостаточная масса тела';
    if (bmi < 25) return 'Норма';
    if (bmi < 30) return 'Избыточная масса тела или предожирение';
    if (bmi < 35) return 'Ожирение';
    if (bmi < 40) return 'Ожирение резкое';
    return 'Очень резкое ожирение';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 188,
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Время расчёта',
            style: TextStyle(color: AppColors.muted, fontSize: 7),
          ),
          Text(
            dateText,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _Metric(label: 'Рост', value: record.heightCm.toStringAsFixed(0)),
              const SizedBox(width: 18),
              _Metric(label: 'Вес', value: record.weightKg.toStringAsFixed(0)),
              const SizedBox(width: 18),
              _Metric(
                label: 'Индекс массы тела',
                value: record.bmi.toStringAsFixed(2),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Рекомендация',
            style: TextStyle(color: AppColors.muted, fontSize: 7),
          ),
          Text(
            '${_category(record.bmi)}. ${record.recommendation}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 7.1,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 6.5),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
