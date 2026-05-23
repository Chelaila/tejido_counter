import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/project.dart';
import '../providers/projects_provider.dart';
import 'sections_screen.dart';

class EditProjectScreen extends StatefulWidget {
  final Project? project;

  const EditProjectScreen({super.key, this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _stitchesController;

  late TejidoMode _mode;
  late WorkStyle _workStyle;
  late bool _row1IsRS;
  late List<ProjectSection> _sections;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _nameController = TextEditingController(text: p?.name ?? '');
    _stitchesController = TextEditingController(
      text: (p?.stitchesPerRow ?? 0) > 0 ? (p!.stitchesPerRow.toString()) : '',
    );
    _mode = p?.mode ?? TejidoMode.crochet;
    _workStyle = p?.workStyle ?? WorkStyle.plano;
    _row1IsRS = p?.row1IsRS ?? true;
    _sections = List.from(p?.sections ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stitchesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar tejido' : 'Nuevo tejido',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del tejido',
                hintText: 'Ej: Bufanda azul, Gorro navideño…',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingresa un nombre' : null,
              autofocus: !_isEditing,
            ),
            const SizedBox(height: 20),

            _SectionHeader(label: 'Modo'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ModeOption(
                    label: 'Crochet',
                    emoji: '🪝',
                    selected: _mode == TejidoMode.crochet,
                    onTap: () => setState(() => _mode = TejidoMode.crochet),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ModeOption(
                    label: 'Palillo',
                    emoji: '🧶',
                    selected: _mode == TejidoMode.palillo,
                    onTap: () => setState(() => _mode = TejidoMode.palillo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _SectionHeader(label: 'Estilo de trabajo'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ModeOption(
                    label: 'Plano',
                    emoji: '↔️',
                    description: 'RS/WS alternos',
                    selected: _workStyle == WorkStyle.plano,
                    onTap: () => setState(() => _workStyle = WorkStyle.plano),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ModeOption(
                    label: 'En redondo',
                    emoji: '🔄',
                    description: 'Siempre RS',
                    selected: _workStyle == WorkStyle.enRedondo,
                    onTap: () =>
                        setState(() => _workStyle = WorkStyle.enRedondo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_workStyle == WorkStyle.plano) ...[
              _SectionHeader(label: 'Dirección primera vuelta'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ModeOption(
                      label: 'RS (derecho)',
                      emoji: '→',
                      description: 'Vuelta 1 es el lado derecho',
                      selected: _row1IsRS,
                      onTap: () => setState(() => _row1IsRS = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeOption(
                      label: 'WS (revés)',
                      emoji: '←',
                      description: 'Vuelta 1 es el lado revés',
                      selected: !_row1IsRS,
                      onTap: () => setState(() => _row1IsRS = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            _SectionHeader(label: 'Puntos por vuelta (opcional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _stitchesController,
              decoration: const InputDecoration(
                labelText: 'Número de puntos',
                hintText: 'Ej: 120',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),

            _SectionHeader(label: 'Secciones / Tapestry'),
            const SizedBox(height: 8),
            _SectionsPreview(
              sections: _sections,
              onEdit: _openSections,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _openSections() async {
    final result = await Navigator.of(context).push<List<ProjectSection>>(
      MaterialPageRoute(
        builder: (_) => SectionsScreen(sections: _sections),
      ),
    );
    if (result != null) {
      setState(() => _sections = result);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final stitches = int.tryParse(_stitchesController.text.trim()) ?? 0;
    final provider = context.read<ProjectsProvider>();

    if (_isEditing) {
      final updated = widget.project!.copyWith(
        name: _nameController.text.trim(),
        mode: _mode,
        workStyle: _workStyle,
        row1IsRS: _row1IsRS,
        stitchesPerRow: stitches,
        sections: _sections,
      );
      await provider.updateProject(updated);
    } else {
      final project = Project.create(
        name: _nameController.text.trim(),
        mode: _mode,
        workStyle: _workStyle,
        row1IsRS: _row1IsRS,
        stitchesPerRow: stitches,
      );
      project.sections.addAll(_sections);
      await provider.addProject(project);
    }

    if (mounted) Navigator.of(context).pop();
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final String label;
  final String emoji;
  final String? description;
  final bool selected;
  final VoidCallback onTap;

  const _ModeOption({
    required this.label,
    required this.emoji,
    this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 11,
                        color: selected
                            ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionsPreview extends StatelessWidget {
  final List<ProjectSection> sections;
  final VoidCallback onEdit;

  const _SectionsPreview({required this.sections, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalRows = sections.fold(0, (s, e) => s + e.rowCount);

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.layers_outlined, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: sections.isEmpty
                  ? Text(
                      'Sin secciones  —  toca para agregar',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${sections.length} sección${sections.length != 1 ? 'es' : ''}  •  $totalRows vueltas totales',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sections.map((s) => s.name).join(', '),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
