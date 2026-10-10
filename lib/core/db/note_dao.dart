import 'app_database.dart';
import '../../features/notes/models/note_model.dart';

class NoteDao {
  static final NoteDao instance = NoteDao._internal();
  NoteDao._internal();

  Future<int> insertNote(NoteModel note) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('notes', note.toMap());
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<NoteModel?> getNoteById(int id) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return NoteModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<NoteModel>> getAllNotes() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'notes',
      orderBy: 'pinned DESC, updated_at DESC',
    );
    return maps.map((m) => NoteModel.fromMap(m)).toList();
  }

  Future<List<NoteModel>> searchNotes(String query) async {
    final db = await AppDatabase.instance.database;
    final q = '%$query%';
    final maps = await db.query(
      'notes',
      where: 'title LIKE ? OR plain_text LIKE ? OR tags LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'pinned DESC, updated_at DESC',
    );
    return maps.map((m) => NoteModel.fromMap(m)).toList();
  }
}
