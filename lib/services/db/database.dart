import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/model/article.dart';
import 'package:komodo_dex/model/wallet.dart';
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
    String path = join(documentsDirectory.path, "AtomicDEX.db");
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
      await db.execute("CREATE TABLE Wallet ("
          "id TEXT PRIMARY KEY,"
          "name TEXT"
          ")");
      await db.execute("CREATE TABLE CurrentWallet ("
          "id TEXT PRIMARY KEY,"
          "name TEXT"
          ")");
    });
  }

  saveArticle(Article newArticle) async {
    final db = await database;

    Map<String, dynamic> row = {
      'id': newArticle.id,
      'title': newArticle.title,
      'media': json.encode(newArticle.media),
      'header': newArticle.header,
      'body': newArticle.body,
      'keywords': newArticle.keywords,
      'isSavedArticle': newArticle.isSavedArticle,
      'creationDate': newArticle.creationDate.toString(),
      'author':
          newArticle.author == null ? "KomodoPlatform" : newArticle.author,
      'v': newArticle.v
    };
    int res = await db.insert('ArticlesSaved ', row);

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
        isSavedArticle: maps[i]['isSavedArticle'] == 1,
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

  Future<void> deleteAllArticles() async {
    final db = await database;
    await db.rawDelete("DELETE FROM ArticlesSaved");
  }

  saveWallet(Wallet newWallet) async {
    final db = await database;

    Map<String, dynamic> row = {
      'id': newWallet.id,
      'name': newWallet.name
    };
    int res = await db.insert('Wallet ', row);

    return res;
  }

  Future<List<Wallet>> getAllWallet() async {
    // Get a reference to the database
    final Database db = await database;

    // Query the table for All The Article.
    final List<Map<String, dynamic>> maps = await db.query('Wallet');
    print(maps.length);
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Wallet(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }

  Future<void> deleteAllWallets() async {
    final db = await database;
    await db.rawDelete("DELETE FROM Wallet");
  }

  Future<void> deleteWallet(Wallet wallet) async {
    print(wallet.id);
    final db = await database;
    await db.delete("Wallet", where: 'id = ?', whereArgs: [wallet.id]);
  }

  saveCurrentWallet(Wallet currentWallet) async {
    await deleteCurrentWallet();
    walletBloc.setCurrentWallet(currentWallet);
    final db = await database;

    Map<String, dynamic> row = {
      'id': currentWallet.id,
      'name': currentWallet.name
    };
    int res = await db.insert('CurrentWallet ', row);

    return res;
  }

  Future<Wallet> getCurrentWallet() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('CurrentWallet');

    List<Wallet> wallets = List.generate(maps.length, (i) {
      return Wallet(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
    if (wallets.length == 0) {
      return null;
    } else {
      return wallets[0];
    }
  }

  Future<void> deleteCurrentWallet() async {
    final db = await database;
    await db.rawDelete("DELETE FROM CurrentWallet");
  }

}
