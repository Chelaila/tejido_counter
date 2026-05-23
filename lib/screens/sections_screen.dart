import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/project.dart';

class SectionsScreen extends StatefulWidget {
  final List<ProjectSection> sections;

  const SectionsScreen({super.key, required this.sections});

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  late List<ProjectSection> _sections;

  int get _totalRows => _sections.fold(0, (s, e) => s + e.rowCount);

  @override
  void initState() {
    super.initState();
    _sections = List.from(widget.sections);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Secciones',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_sections),
            child: const Text('Listo'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary bar
          if (_sections.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.layers_outlined,
                      size: 16, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    '${_sections.length} sección${_sections.length != 1 ? 'es' : ''}',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$_totalRows vueltas totales',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          // Tapestry help text
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _TapestryHelpCard(),
          ),

          // Sections list
          Expanded(
            child: _sections.isEmpty
                ? _EmptySections(onAdd: _addSection)
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _sections.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _sections.removeAt(oldIndex);
                        _sections.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, i) {
                      final section = _sections[i];
                      // Cumulative start row for this section
                      int startRow = 1;
                      for (int j = 0; j < i; j++) {
                        startRow += _sections[j].rowCount;
                      }
                      final endRow = startRow + section.rowCount - 1;

                      return _SectionTile(
                        key: ValueKey(section.id),
                        section: section,
                        index: i,
                        startRow: startRow,
                        endRow: endRow,
                        onEdit: () => _editSection(i),
                        onDelete: () =>
                            setState(() => _sections.removeAt(i)),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _sections.isNotEmpty
          ? FloatingActionButton(
              onPressed: _addSection,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _addSection() async {
    final result = await _showSectionDialog();
    if (result != null) {
      setState(() => _sections.add(result));
    }
  }

  Future<void> _editSection(int index) async {
    final result = await _showSectionDialog(existing: _sections[index]);
    if (result != null) {
      setState(() => _sections[index] = result);
    }
  }

  Future<ProjectSection?> _showSectionDialog({
    ProjectSection? existing,
  }) async {
    final nameController =
        TextEditingController(text: existing?.name ?? '');
    final rowsController = TextEditingController(
      text: existing != null ? existing.rowCount.toString() : '',
    );
    final formKey = GlobalKey<FormState>();

    return showDialog<ProjectSection>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Nueva sección' : 'Editar sección'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej: Borde, Cuerpo, Disminuciones…',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: rowsController,
                decoration: const InputDecoration(
                  labelText: 'Número de vueltas',
                  hintText: 'Ej: 20',
                  border: OutlineInputBorder(),
                  suffixText: 'vueltas',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Ingresa un número mayor a 0';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final section = existing != null
                  ? existing.copyWith(
                      name: nameController.text.trim(),
                      rowCount: int.parse(rowsController.text),
                    )
                  : ProjectSection.create(
                      nameController.text.trim(),
                      int.parse(rowsController.text),
                    );
              Navigator.pop(ctx, section);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final ProjectSection section;
  final int index;
  final int startRow;
  final int endRow;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SectionTile({
    super.key,
    required this.section,
    required this.index,
    required this.startRow,
    required this.endRow,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.pink,
    ];
    final color = colors[index % colors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 6,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        title: Text(
          section.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${section.rowCount} vueltas  •  filas $startRow–$endRow',
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: onEdit,
              tooltip: 'Editar',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 18, color: colorScheme.error),
              onPressed: onDelete,
              tooltip: 'Eliminar',
            ),
            const Icon(Icons.drag_handle, size: 18),
          ],
        ),
      ),
    );
  }
}

class _EmptySections extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptySections({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Sin secciones',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Las secciones agrupan vueltas para seguir el progreso de cada parte del patrón',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Agregar sección'),
          ),
        ],
      ),
    );
  }
}

class _TapestryHelpCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tapestry: agrupa filas del gráfico en secciones (borde, motivo, remate). '
              'Arrastra para reordenar. El contador mostrará en qué sección estás.',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
