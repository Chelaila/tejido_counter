import 'package:flutter/material.dart';

import '../models/project.dart';

class SectionProgressCard extends StatelessWidget {
  final Project project;

  const SectionProgressCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    if (project.sections.isEmpty) return const SizedBox.shrink();

    final info = project.currentSectionInfo;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.layers_outlined,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Sección',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                _SectionChips(project: project, currentIndex: info.sectionIndex),
              ],
            ),
            const SizedBox(height: 8),
            if (info.section != null) ...[
              Text(
                info.section!.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Vuelta ${info.rowInSection} de ${info.section!.rowCount}',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: info.progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
            ] else ...[
              Text(
                info.sectionIndex >= project.sections.length
                    ? 'Más allá de las secciones (vuelta ${project.currentRow})'
                    : 'Sin sección activa',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
              ),
            ],
            if (project.totalDefinedRows > 0) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Progreso total',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(project.overallProgress * 100).toStringAsFixed(0)}%  '
                    '(${project.currentRow}/${project.totalDefinedRows})',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: project.overallProgress,
                  minHeight: 4,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.tertiary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionChips extends StatelessWidget {
  final Project project;
  final int currentIndex;

  const _SectionChips({required this.project, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const maxDots = 7;
    final count = project.sections.length;

    if (count <= maxDots) {
      return Row(
        children: List.generate(count, (i) {
          final isActive = i == currentIndex;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: isActive ? 10 : 7,
            height: isActive ? 10 : 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: i < currentIndex
                    ? colorScheme.primary.withValues(alpha: 0.5)
                    : colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          );
        }),
      );
    }

    return Text(
      '${currentIndex + 1}/$count',
      style: TextStyle(
        fontSize: 12,
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
