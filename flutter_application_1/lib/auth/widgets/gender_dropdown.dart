import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GenderDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const GenderDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text(
            'Не выбран',
            style: TextStyle(color: AppTheme.textHint, fontSize: 13),
          ),
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          style: const TextStyle(color: AppTheme.textDark, fontSize: 13),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textHint),
          items: const [
            DropdownMenuItem(value: 'М', child: Text('Мужской')),
            DropdownMenuItem(value: 'Ж', child: Text('Женский')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
