import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/project.dart';
import '../providers/projects_provider.dart';
import '../widgets/counter_tile.dart';
import '../widgets/direction_badge.dart';
import '../widgets/section_progress_card.dart';
import 'edit_project_screen.dart';

class CounterScreen extends StatelessWidget {
  final String projectId;

  const CounterScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectsProvider>(
      builder: (context, provider, _) {
        final project = provider.getProject(projectId);
        if (project == null) {
          return const Scaffold(
            body: Center(child: Text('Proyecto no encontrado')),
          );
        }
        return _CounterView(project: project, provider: provider);
      },
    );
  }
}

class _CounterView extends StatelessWidget {
  final Project project;
  final ProjectsProvider provider;

  const _CounterView({required this.project, required this.provider});

  @override
  Widget build(BuildContext context) {
    final info = project.currentSectionInfo;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar proyecto',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditProjectScreen(project: project),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        children: [
          // Mode + Direction status row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                ModeBadge(project: project),
                const SizedBox(width: 8),
                DirectionBadge(project: project),
                const Spacer(),
                if (project.workStyle == WorkStyle.plano)
                  _DirectionDetail(project: project),
              ],
            ),
          ),

          // Section progress card
          SectionProgressCard(project: project),

          const SizedBox(height: 4),

          // Main row counter (large)
          CounterTile(
            label: 'VUELTA',
            value: project.currentRow,
            large: true,
            subtitle: _rowSubtitle(project, info),
            onIncrement: () => provider.incrementRow(project.id),
            onDecrement: () => provider.decrementRow(project.id),
          ),

          // Stitch counter
          CounterTile(
            label: 'PUNTOS',
            value: project.stitchesPerRow,
            onIncrement: () =>
                provider.setStitches(project.id, project.stitchesPerRow + 1),
            onDecrement: () =>
                provider.setStitches(project.id, project.stitchesPerRow - 1),
          ),

          const SizedBox(height: 24),

          // Quick reset button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _confirmReset(context),
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Reiniciar vuelta'),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String? _rowSubtitle(
    Project project,
    ({
      ProjectSection? section,
      int rowInSection,
      int sectionIndex,
      double progress
    }) info,
  ) {
    if (project.sections.isEmpty) return null;
    if (info.section != null) {
      return '${info.section!.name}  •  ${info.rowInSection}/${info.section!.rowCount}';
    }
    return null;
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reiniciar vuelta'),
        content: const Text('¿Volver a la vuelta 1?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.updateProject(project.copyWith(currentRow: 1));
    }
  }
}

class _DirectionDetail extends StatelessWidget {
  final Project project;

  const _DirectionDetail({required this.project});

  @override
  Widget build(BuildContext context) {
    final isRS = project.isCurrentRS;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isRS ? Icons.arrow_back : Icons.arrow_forward,
          size: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 3),
        Text(
          isRS ? 'leer derecha→izq' : 'leer izq→derecha',
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
