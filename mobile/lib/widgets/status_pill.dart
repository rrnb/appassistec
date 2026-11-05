import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  final String status;
  final bool isSelected;
  final VoidCallback? onTap;

  const StatusPill({
    Key? key,
    required this.status,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  Color get _color {
    switch (status.toLowerCase()) {
      case 'concluída':
      case 'aprovado':
      case 'conforme':
      case 'sincronizado':
        return AppColors.statusSuccess;
      case 'reprovado':
      case 'não conforme':
      case 'cancelada':
        return AppColors.statusError;
      case 'agendada':
      case 'pendente':
        return AppColors.statusWarning;
      case 'em andamento':
        return AppColors.statusInfo;
      case 'enviado para faturamento':
        return AppColors.statusPurple;
      case 'faturado':
        return const Color(0xFF4F46E5);
      default:
        return AppColors.textMuted;
    }
  }

  Color get _bg {
    switch (status.toLowerCase()) {
      case 'concluída':
      case 'aprovado':
      case 'conforme':
      case 'sincronizado':
        return AppColors.statusSuccessBg;
      case 'reprovado':
      case 'não conforme':
      case 'cancelada':
        return AppColors.statusErrorBg;
      case 'agendada':
      case 'pendente':
        return AppColors.statusWarningBg;
      case 'em andamento':
        return AppColors.statusInfoBg;
      case 'enviado para faturamento':
        return AppColors.statusPurpleBg;
      case 'faturado':
        return const Color(0xFFEEF2FF);
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _color : _bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? Colors.white : _color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
