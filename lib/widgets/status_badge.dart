import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Huy hiệu hiển thị trạng thái tồn kho có ngữ nghĩa thị giác:
/// - Còn hàng (Emerald / Xanh lá)
/// - Sắp hết (Amber / Vàng cam)
/// - Hết hàng (Rose / Đỏ)
class StatusBadge extends StatelessWidget {
  final int soluong;

  const StatusBadge({super.key, required this.soluong});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color border;
    String label;
    IconData icon;

    if (soluong > 5) {
      bg = AppTheme.successBg;
      text = AppTheme.successText;
      border = AppTheme.successBorder;
      label = 'Còn $soluong sp';
      icon = Icons.check_circle_outline;
    } else if (soluong > 0) {
      bg = AppTheme.warningBg;
      text = AppTheme.warningText;
      border = AppTheme.warningBorder;
      label = 'Sắp hết ($soluong)';
      icon = Icons.warning_amber_rounded;
    } else {
      bg = AppTheme.dangerBg;
      text = AppTheme.dangerText;
      border = AppTheme.dangerBorder;
      label = 'Hết hàng';
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
