import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/bmi_record.dart';
import '../services/supabase_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/screen_shell.dart';
import 'calculator_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<BmiRecord> _history = const [];
  bool _loading = true;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await SupabaseService.instance.getHistory();

      if (!mounted) return;

      setState(() {
        _history = history;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    if (_loggingOut) return;

    setState(() {
      _loggingOut = true;
    });

    try {
      await SupabaseService.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось выйти из аккаунта.')),
      );
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');

    final month = local.month.toString().padLeft(2, '0');

    final year = local.year.toString();

    final hour = local.hour.toString().padLeft(2, '0');

    final minute = local.minute.toString().padLeft(2, '0');

    return '$day.$month.$year, $hour:$minute';
  }

  String _userName() {
    final firstName = SupabaseService.instance.firstName.trim();

    final lastName = SupabaseService.instance.lastName.trim();

    final fullName = '$firstName $lastName'.trim();

    if (fullName.isEmpty) {
      return 'Пользователь';
    }

    return fullName;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

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

          // ─────────────────────────────
          // ЗАГОЛОВОК
          // ─────────────────────────────
          Text(
            'Профиль',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.green,
              fontSize: screenWidth < 360 ? 26 : 30,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 24),

          // ─────────────────────────────
          // ПЛАШКА ПРОФИЛЯ
          // АВАТАР
          // ИМЯ
          // EMAIL
          // ─────────────────────────────
          DesignCard(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // АВАТАР
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greenLight,
                    border: Border.all(color: AppColors.green, width: 1),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 32,
                    color: AppColors.green,
                  ),
                ),

                const SizedBox(height: 7),

                // ИМЯ И ФАМИЛИЯ
                Text(
                  _userName(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                // EMAIL
                Text(
                  SupabaseService.instance.email,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ─────────────────────────────
          // ИСТОРИЯ РАСЧЁТОВ
          // ─────────────────────────────
          DesignCard(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'История расчётов',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 14),

                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.green),
                    ),
                  )
                else if (_history.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Расчётов пока нет.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 15),
                    ),
                  )
                else
                  ..._history.map(
                    (record) =>
                        _HistoryItem(record: record, formatDate: _formatDate),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ─────────────────────────────
          // КНОПКА ВЫХОДА
          // ─────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _loggingOut ? null : _logout,
              icon: _loggingOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.red,
                      ),
                    )
                  : const Icon(Icons.logout, size: 21),
              label: Text(
                _loggingOut ? 'ВЫХОД...' : 'ВЫЙТИ ИЗ АККАУНТА',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// ОДИН ЭЛЕМЕНТ ИСТОРИИ
// ═══════════════════════════════════════

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.record, required this.formatDate});

  final BmiRecord record;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ДАТА И ВРЕМЯ
          const Text(
            'Время расчёта',
            style: TextStyle(color: AppColors.muted, fontSize: 11),
          ),

          const SizedBox(height: 2),

          Text(
            formatDate(record.createdAt),
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          // РОСТ / ВЕС / ИМТ
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _HistoryValue(
                  title: 'Рост',
                  value: '${record.heightCm.round()}',
                ),
              ),

              Expanded(
                child: _HistoryValue(
                  title: 'Вес',
                  value: '${record.weightKg.round()}',
                ),
              ),

              Expanded(
                child: _HistoryValue(
                  title: 'Индекс массы тела',
                  value: record.bmi.toStringAsFixed(2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // РЕКОМЕНДАЦИЯ
          const Text(
            'Рекомендация',
            style: TextStyle(color: AppColors.muted, fontSize: 11),
          ),

          const SizedBox(height: 2),

          Text(
            record.recommendation,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// ЗНАЧЕНИЕ В ИСТОРИИ
// ═══════════════════════════════════════

class _HistoryValue extends StatelessWidget {
  const _HistoryValue({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),

        const SizedBox(height: 2),

        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
