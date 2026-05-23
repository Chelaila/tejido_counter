import 'package:flutter/material.dart';

import '../models/project.dart';

class DirectionBadge extends StatelessWidget {
  final Project project;

  const DirectionBadge({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    if (project.workStyle == WorkStyle.enRedondo) {
      return _Badge(
        label: 'En Redondo',
        icon: Icons.loop,
        color: Colors.teal,
      );
    }

    final isRS = project.isCurrentRS;
    return _Badge(
      label: isRS ? 'RS  ←' : 'WS  →',
      icon: isRS ? Icons.arrow_back : Icons.arrow_forward,
      color: isRS ? Colors.green.shade700 : Colors.orange.shade700,
      tooltip: isRS
          ? 'Derecho (Right Side) — leer de derecha a izquierda'
          : 'Revés (Wrong Side) — leer de izquierda a derecha',
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String? tooltip;

  const _Badge({
    required this.label,
    required this.icon,
    required this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: chip);
    }
    return chip;
  }
}

class ModeBadge extends StatelessWidget {
  final Project project;

  const ModeBadge({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final isCrochet = project.mode == TejidoMode.crochet;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isCrochet
            ? Colors.amber.withValues(alpha: 0.15)
            : Colors.indigo.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCrochet
              ? Colors.amber.shade600.withValues(alpha: 0.5)
              : Colors.indigo.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isCrochet ? '🪝' : '🧶',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 5),
          Text(
            isCrochet ? 'Crochet' : 'Palillo',
            style: TextStyle(
              color: isCrochet ? Colors.amber.shade800 : Colors.indigo,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
