import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/project.dart';

class ProjectsProvider extends ChangeNotifier {
  static const _storageKey = 'tejido_projects';

  List<Project> _projects = [];
  bool _loaded = false;

  List<Project> get projects => List.unmodifiable(_projects);
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _projects = list
          .map((j) => Project.fromJson(j as Map<String, dynamic>))
          .toList();
      _sort();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_projects.map((p) => p.toJson()).toList()),
    );
  }

  void _sort() {
    _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> addProject(Project project) async {
    _projects.insert(0, project);
    await _persist();
    notifyListeners();
  }

  Future<void> updateProject(Project updated) async {
    final idx = _projects.indexWhere((p) => p.id == updated.id);
    if (idx == -1) return;
    _projects[idx] = updated;
    _sort();
    await _persist();
    notifyListeners();
  }

  Future<void> incrementRow(String id) async {
    final idx = _projects.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final p = _projects[idx];
    _projects[idx] = p.copyWith(currentRow: p.currentRow + 1);
    _sort();
    await _persist();
    notifyListeners();
  }

  Future<void> decrementRow(String id) async {
    final idx = _projects.indexWhere((p) => p.id == id);
    if (idx == -1 || _projects[idx].currentRow <= 1) return;
    final p = _projects[idx];
    _projects[idx] = p.copyWith(currentRow: p.currentRow - 1);
    _sort();
    await _persist();
    notifyListeners();
  }

  Future<void> setStitches(String id, int stitches) async {
    final idx = _projects.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    _projects[idx] = _projects[idx].copyWith(stitchesPerRow: stitches.clamp(0, 9999));
    await _persist();
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
    await _persist();
    notifyListeners();
  }

  Project? getProject(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
