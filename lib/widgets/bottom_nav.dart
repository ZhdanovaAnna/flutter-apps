import 'package:flutter/material.dart';

import '../core/constants.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4E4E4))),
      ),
      child: Row(
        children: [
          Expanded(child: _item(0, 'Калькулятор')),
          Expanded(child: _item(1, 'Профиль')),
        ],
      ),
    );
  }

  Widget _item(int index, String label) {
    final selected = selectedIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: selected ? const Color(0xFF555555) : const Color(0xFF888888),
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
