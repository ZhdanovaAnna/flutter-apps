import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/bmi_record.dart';
import '../services/supabase_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/screen_shell.dart';
import 'calculator_screen.dart';

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
        setState(() {
          _error = 'Не удалось загрузить историю расчётов';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _logout() async {
    await SupabaseService.instance.signOut();
  }

  String _date(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(date.day)}.'
        '${two(date.month)}.'
        '${date.year}, '
        '${two(date.hour)}:'
        '${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final fullName = '$_firstName $_lastName'.trim();

    return DesignScreen(
      bottomNavigationBar: BottomNav(
        selectedIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const CalculatorScreen()),
            );
          }
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          const Text(
            'Профиль',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.green,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 24),

          DesignCard(
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/avatar.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty ? 'Имя Фамилия' : fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        _email.isEmpty ? 'Email' : _email,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'История расчётов',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              IconButton(
                onPressed: _loading ? null : _loadHistory,
                tooltip: 'Обновить',
                icon: const Icon(Icons.refresh),
                color: AppColors.green,
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _MessageCard(text: _error!, color: AppColors.red)
          else if (_history.isEmpty)
            const _MessageCard(
              text: 'История расчётов пока пуста',
              color: AppColors.muted,
            )
          else
            Column(
              children: [
                for (final record in _history) ...[
                  _HistoryCard(
                    record: record,
                    dateText: _date(record.createdAt),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),

          const SizedBox(height: 8),

          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Выйти из аккаунта'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: 15),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record, required this.dateText});

  final BmiRecord record;
  final String dateText;

  String _category(double bmi) {
    if (bmi <= 16) {
      return 'Выраженный дефицит массы тела';
    }

    if (bmi < 18.5) {
      return 'Недостаточная масса тела';
    }

    if (bmi < 25) {
      return 'Норма';
    }

    if (bmi < 30) {
      return 'Избыточная масса тела или предожирение';
    }

    if (bmi < 35) {
      return 'Ожирение';
    }

    if (bmi < 40) {
      return 'Ожирение резкое';
    }

    return 'Очень резкое ожирение';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateText,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _Metric(
                label: 'Рост',
                value: '${record.heightCm.toStringAsFixed(0)} см',
              ),
              const SizedBox(width: 12),
              _Metric(
                label: 'Вес',
                value: '${record.weightKg.toStringAsFixed(0)} кг',
              ),
              const SizedBox(width: 12),
              _Metric(label: 'ИМТ', value: record.bmi.toStringAsFixed(2)),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'Рекомендация',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),

          const SizedBox(height: 4),

          Text(
            '${_category(record.bmi)}. '
            '${record.recommendation}',
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              height: 1.35,
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
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
