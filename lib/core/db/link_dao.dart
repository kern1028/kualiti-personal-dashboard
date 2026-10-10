import 'app_database.dart';
import '../../features/links/models/link_model.dart';

class LinkDao {
  static final LinkDao instance = LinkDao._internal();
  LinkDao._internal();

  Future<int> insertLink(LinkModel link) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('links', link.toMap());
  }

  Future<int> updateLink(LinkModel link) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'links',
      link.toMap(),
      where: 'id = ?',
      whereArgs: [link.id],
    );
  }

  Future<int> deleteLink(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.delete(
      'links',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<LinkModel>> getAllLinks() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query('links', orderBy: 'sort_order ASC, id DESC');
    return maps.map((m) => LinkModel.fromMap(m)).toList();
  }

  Future<List<LinkModel>> getHomeLinks() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'links',
      where: 'show_on_home = 1',
      orderBy: 'sort_order ASC, id DESC',
      limit: 4,
    );
    return maps.map((m) => LinkModel.fromMap(m)).toList();
  }
}
