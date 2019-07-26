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
    if (_database != null) {
      return _database;
    }

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'AtomicDEX.db');
    return await openDatabase(path, version: 1, onOpen: (Database db) {},
        onCreate: (Database db, int version) async {
      await db.execute('''
      CREATE TABLE ArticlesSaved (
          id TEXT PRIMARY KEY,
          media TEXT,
          title TEXT,
          header TEXT,
          body TEXT,
          keywords TEXT,
          isSavedArticle BIT,
          creationDate TEXT,
          author TEXT,
          v INTEGER
        )
      ''');
      await db.execute('''
      CREATE TABLE Wallet (
          id TEXT PRIMARY KEY,
          name TEXT,
          is_fast_encryption BIT
        )
      ''');
      await db.execute('''
      CREATE TABLE CurrentWallet (
          id TEXT PRIMARY KEY,
          name TEXT,
          is_fast_encryption BIT
        )
      ''');
    });
  }

  Future<int> saveArticle(Article newArticle) async {
    final Database db = await database;

    final Map<String, dynamic> row = <String, dynamic>{
      'id': newArticle.id,
      'title': newArticle.title,
      'media': json.encode(newArticle.media),
      'header': newArticle.header,
      'body': newArticle.body,
      'keywords': newArticle.keywords,
      'isSavedArticle': newArticle.isSavedArticle,
      'creationDate': newArticle.creationDate.toString(),
      'author': newArticle.author ?? 'KomodoPlatform',
      'v': newArticle.v
    };

    return await db.insert('ArticlesSaved ', row);
  }

  Future<List<Article>> getAllArticlesSaved() async {
    // Get a reference to the database
    final Database db = await database;

    // Query the table for All The Article.
    final List<Map<String, dynamic>> maps = await db.query('ArticlesSaved');
    print(maps.length);
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List<Article>.generate(maps.length, (int i) {
      return Article(
        id: maps[i]['id'],
        media: List<String>.from(json.decode(maps[i]['media'])),
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
    final Database db = await database;

    // Remove the Article from the Database
    await db.delete(
      'ArticlesSaved',
      // Use a `where` clause to delete a specific article
      where: 'id = ?',
      // Pass the Article's id through as a whereArg to prevent SQL injection
      whereArgs: <dynamic>[article.id],
    );
  }

  Future<void> deleteAllArticles() async {
    final Database db = await database;
    await db.rawDelete('DELETE FROM ArticlesSaved');
  }

  Future<int> saveWallet(Wallet newWallet) async {
    final Database db = await database;

    final Map<String, dynamic> row = <String, dynamic>{
      'id': newWallet.id,
      'name': newWallet.name,
      'is_fast_encryption': newWallet.isFastEncryption
    };

    return await db.insert('Wallet ', row);
  }

  Future<List<Wallet>> getAllWallet() async {
    // Get a reference to the database
    final Database db = await database;

    // Query the table for All The Article.
    final List<Map<String, dynamic>> maps = await db.query('Wallet');
    print(maps.length);
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List<Wallet>.generate(maps.length, (int i) {
      return Wallet(
          id: maps[i]['id'],
          name: maps[i]['name'],
          isFastEncryption: maps[i]['is_fast_encryption'] == 1);
    });
  }

  Future<void> deleteAllWallets() async {
    final Database db = await database;
    await db.rawDelete('DELETE FROM Wallet');
  }

  Future<void> deleteWallet(Wallet wallet) async {
    print(wallet.id);
    final Database db = await database;
    await db.delete('Wallet', where: 'id = ?', whereArgs: <dynamic>[wallet.id]);
  }

  Future<int> saveCurrentWallet(Wallet currentWallet) async {
    await deleteCurrentWallet();
    walletBloc.setCurrentWallet(currentWallet);
    final Database db = await database;

    final Map<String, dynamic> row = <String, dynamic>{
      'id': currentWallet.id,
      'name': currentWallet.name,
      'is_fast_encryption': currentWallet.isFastEncryption
    };

    return await db.insert('CurrentWallet ', row);
  }

  Future<Wallet> getCurrentWallet() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('CurrentWallet');

    final List<Wallet> wallets = List<Wallet>.generate(maps.length, (int i) {
      return Wallet(
          id: maps[i]['id'],
          name: maps[i]['name'],
          isFastEncryption: maps[i]['is_fast_encryption'] == 1);
    });
    if (wallets.isEmpty) {
      return null;
    } else {
      return wallets[0];
    }
  }

  Future<void> deleteCurrentWallet() async {
    final Database db = await database;
    await db.rawDelete('DELETE FROM CurrentWallet');
  }
}
