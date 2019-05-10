import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:komodo_dex/model/article.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "ArticlesSaved.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE ArticlesSaved ("
          "id TEXT PRIMARY KEY,"
          "media TEXT,"
          "title TEXT,"
          "header TEXT,"
          "body TEXT,"
          "keywords TEXT,"
          "isSavedArticle BIT,"
          "creationDate TEXT,"
          "author TEXT,"
          "v INTEGER"
          ")");
    });
  }

  saveArticle(Article newArticle) async {
    final db = await database;
    var res = await db.rawInsert(
        "INSERT Into ArticlesSaved (id, title, media, header, body, keywords, isSavedArticle, creationDate, author, v)"
        " VALUES ('${newArticle.id}','${newArticle.title}','${json.encode(newArticle.media)}', '${newArticle.header}','${newArticle.body}','${newArticle.keywords}','${newArticle.isSavedArticle}','${newArticle.creationDate.toString()}', '${newArticle.author == null ? "KomodoPlatform" : newArticle.author}','${newArticle.v}')",);
    print(res.toString());
    return res;
  }

  Future<List<Article>> getAllArticlesSaved() async {
    // Get a reference to the database
    final Database db = await database;

    // Query the table for All The Article.
    final List<Map<String, dynamic>> maps = await db.query('ArticlesSaved');
    print(maps.length);
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Article(
        id: maps[i]['id'],
        media: new List<String>.from(json.decode(maps[i]['media'])),
        title: maps[i]['title'],
        header: maps[i]['header'],
        body: maps[i]['body'],
        keywords: maps[i]['keywords'],
        author: maps[i]['author'],
        isSavedArticle: maps[i]['isSavedArticle'].toLowerCase() == 'true',
        creationDate: DateTime.parse(maps[i]['creationDate']),
        v: maps[i]['v'],
      );
    });
  }

  Future<void> deleteArticle(Article article) async {
    // Get a reference to the database
    final db = await database;

    // Remove the Article from the Database
    await db.delete(
      'ArticlesSaved',
      // Use a `where` clause to delete a specific article
      where: "id = ?",
      // Pass the Article's id through as a whereArg to prevent SQL injection
      whereArgs: [article.id],
    );
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.rawDelete("DELETE FROM ArticlesSaved");
  }
}
