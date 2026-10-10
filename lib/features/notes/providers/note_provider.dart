import 'package:flutter/material.dart';
import '../../../core/db/note_dao.dart';
import '../models/note_model.dart';

class NoteProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedTag;

  NoteModel? _lastDeletedNote;

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedTag => _selectedTag;

  NoteProvider() {
    loadNotes();
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    _notes = await NoteDao.instance.getAllNotes();
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q.trim();
    notifyListeners();
  }

  void setSelectedTag(String? tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  List<String> get allTags {
    final Set<String> tagSet = {};
    for (final note in _notes) {
      for (final tag in note.tagList) {
        tagSet.add(tag);
      }
    }
    return tagSet.toList()..sort();
  }

  List<NoteModel> get filteredNotes {
    List<NoteModel> list = List.from(_notes);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((n) {
        return n.title.toLowerCase().contains(q) ||
            n.plainText.toLowerCase().contains(q) ||
            n.tags.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedTag != null && _selectedTag!.isNotEmpty) {
      list = list.where((n) => n.tagList.contains(_selectedTag)).toList();
    }

    // Sort: pinned first, then updated_at DESC
    list.sort((a, b) {
      if (a.pinned && !b.pinned) return -1;
      if (!a.pinned && b.pinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return list;
  }

  Future<NoteModel> createEmptyNote() async {
    final now = DateTime.now().toIso8601String();
    final newNote = NoteModel(
      title: '',
      bodyJson: NoteModel.encodeBlocks([NoteBlock()]),
      plainText: '',
      updatedAt: now,
      createdAt: now,
    );

    final id = await NoteDao.instance.insertNote(newNote);
    final inserted = newNote.copyWith(id: id);
    _notes.insert(0, inserted);
    notifyListeners();
    return inserted;
  }

  Future<void> saveNote(NoteModel note) async {
    final updated = note.copyWith(updatedAt: DateTime.now().toIso8601String());
    await NoteDao.instance.updateNote(updated);

    final index = _notes.indexWhere((n) => n.id == updated.id);
    if (index != -1) {
      _notes[index] = updated;
    } else {
      _notes.insert(0, updated);
    }
    notifyListeners();
  }

  Future<void> togglePin(NoteModel note) async {
    final updated = note.copyWith(pinned: !note.pinned);
    await saveNote(updated);
  }

  Future<void> deleteNote(NoteModel note) async {
    if (note.id == null) return;
    _lastDeletedNote = note;
    await NoteDao.instance.deleteNote(note.id!);
    _notes.removeWhere((n) => n.id == note.id);
    notifyListeners();
  }

  Future<void> undoDelete() async {
    if (_lastDeletedNote == null) return;
    final noteToRestore = _lastDeletedNote!;
    _lastDeletedNote = null;

    final id = await NoteDao.instance.insertNote(noteToRestore);
    final restored = noteToRestore.copyWith(id: id);
    _notes.insert(0, restored);
    notifyListeners();
  }
}
