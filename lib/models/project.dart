import 'package:uuid/uuid.dart';

enum TejidoMode { crochet, palillo }

enum WorkStyle { plano, enRedondo }

class ProjectSection {
  String id;
  String name;
  int rowCount;

  ProjectSection({
    required this.id,
    required this.name,
    required this.rowCount,
  });

  factory ProjectSection.create(String name, int rowCount) => ProjectSection(
        id: const Uuid().v4(),
        name: name,
        rowCount: rowCount,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rowCount': rowCount,
      };

  factory ProjectSection.fromJson(Map<String, dynamic> json) => ProjectSection(
        id: json['id'] as String,
        name: json['name'] as String,
        rowCount: json['rowCount'] as int,
      );

  ProjectSection copyWith({String? name, int? rowCount}) => ProjectSection(
        id: id,
        name: name ?? this.name,
        rowCount: rowCount ?? this.rowCount,
      );
}

class Project {
  final String id;
  String name;
  TejidoMode mode;
  WorkStyle workStyle;
  int currentRow;
  int stitchesPerRow;
  List<ProjectSection> sections;
  bool row1IsRS;
  DateTime createdAt;
  DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.mode,
    this.workStyle = WorkStyle.plano,
    this.currentRow = 1,
    this.stitchesPerRow = 0,
    List<ProjectSection>? sections,
    this.row1IsRS = true,
    required this.createdAt,
    required this.updatedAt,
  }) : sections = sections ?? [];

  factory Project.create({
    required String name,
    required TejidoMode mode,
    WorkStyle workStyle = WorkStyle.plano,
    int stitchesPerRow = 0,
    bool row1IsRS = true,
  }) {
    final now = DateTime.now();
    return Project(
      id: const Uuid().v4(),
      name: name,
      mode: mode,
      workStyle: workStyle,
      currentRow: 1,
      stitchesPerRow: stitchesPerRow,
      sections: [],
      row1IsRS: row1IsRS,
      createdAt: now,
      updatedAt: now,
    );
  }

  // RS = Right Side (derecho), WS = Wrong Side (revés)
  bool get isCurrentRS {
    if (workStyle == WorkStyle.enRedondo) return true;
    return (currentRow % 2 == 1) == row1IsRS;
  }

  String get directionLabel => isCurrentRS ? 'RS' : 'WS';

  // Chart reading direction: RS rows read right-to-left in most charts
  String get readingDirection => isCurrentRS ? '← derecho' : '→ revés';

  int get totalDefinedRows =>
      sections.fold(0, (sum, s) => sum + s.rowCount);

  ({ProjectSection? section, int rowInSection, int sectionIndex, double progress})
      get currentSectionInfo {
    if (sections.isEmpty) {
      return (
        section: null,
        rowInSection: currentRow,
        sectionIndex: -1,
        progress: 0,
      );
    }

    int accumulated = 0;
    for (int i = 0; i < sections.length; i++) {
      final s = sections[i];
      final sectionEnd = accumulated + s.rowCount;
      if (currentRow <= sectionEnd) {
        final rowInSection = currentRow - accumulated;
        return (
          section: s,
          rowInSection: rowInSection,
          sectionIndex: i,
          progress: rowInSection / s.rowCount,
        );
      }
      accumulated += sectionEnd - accumulated;
    }
    // Más allá de las secciones definidas
    return (
      section: null,
      rowInSection: currentRow - totalDefinedRows,
      sectionIndex: sections.length,
      progress: 1.0,
    );
  }

  double get overallProgress {
    if (totalDefinedRows == 0) return 0;
    return (currentRow / totalDefinedRows).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mode': mode.name,
        'workStyle': workStyle.name,
        'currentRow': currentRow,
        'stitchesPerRow': stitchesPerRow,
        'sections': sections.map((s) => s.toJson()).toList(),
        'row1IsRS': row1IsRS,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        name: json['name'] as String,
        mode: TejidoMode.values.firstWhere((e) => e.name == json['mode']),
        workStyle: WorkStyle.values.firstWhere(
          (e) => e.name == (json['workStyle'] ?? 'plano'),
        ),
        currentRow: json['currentRow'] as int,
        stitchesPerRow: json['stitchesPerRow'] as int? ?? 0,
        sections: (json['sections'] as List<dynamic>? ?? [])
            .map((s) => ProjectSection.fromJson(s as Map<String, dynamic>))
            .toList(),
        row1IsRS: json['row1IsRS'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Project copyWith({
    String? name,
    TejidoMode? mode,
    WorkStyle? workStyle,
    int? currentRow,
    int? stitchesPerRow,
    List<ProjectSection>? sections,
    bool? row1IsRS,
  }) =>
      Project(
        id: id,
        name: name ?? this.name,
        mode: mode ?? this.mode,
        workStyle: workStyle ?? this.workStyle,
        currentRow: currentRow ?? this.currentRow,
        stitchesPerRow: stitchesPerRow ?? this.stitchesPerRow,
        sections: sections ?? List.from(this.sections),
        row1IsRS: row1IsRS ?? this.row1IsRS,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
