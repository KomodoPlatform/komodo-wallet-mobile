import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/model/article.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Db {
  static Database _db;
  static bool _initInvoked = false;

  static Future<Database> get db async {
    // Protect the database from being opened and initialized multiple times.
    if (_initInvoked) {
      while (_db == null) await sleepMs(111);
      return _db;
    }

    _initInvoked = true;
    _db = await _initDB();
    return _db;
  }

  static Future<Database> _initDB() async {
    final Directory documentsDirectory = await applicationDocumentsDirectory;
    final String path = join(documentsDirectory.path, 'AtomicDEX.db');
    final db = await openDatabase(path, version: 1, onOpen: (Database db) {},
        onCreate: (Database db, int version) async {
      Log('database:35', 'initDB, onCreate');
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

    // Drop tables no longer in use.
    await db.execute('DROP TABLE IF EXISTS CoinsDefault');
    await db.execute('DROP TABLE IF EXISTS CoinsConfig');

    // We're temporarily using a part of the CoinsActivated table but going to drop it in the future.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS CoinsActivated (
        name TEXT PRIMARY KEY,
        abbr TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS TxNotes (
        tx_hash TEXT PRIMARY KEY,
        note TEXT
      )
    ''');

    return db;
  }

  static Future<int> saveArticle(Article newArticle) async {
    final Database db = await Db.db;

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

  static Future<List<Article>> getAllArticlesSaved() async {
    final Database db = await Db.db;

    // Query the table for All The Article.
    final List<Map<String, dynamic>> maps = await db.query('ArticlesSaved');
    Log('database:105', maps.length);
    // Convert the List<Map<String, dynamic> into a List<Article>.
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

  static Future<void> deleteArticle(Article article) async {
    final Database db = await Db.db;

    // Remove the Article from the Database
    await db.delete(
      'ArticlesSaved',
      // Use a `where` clause to delete a specific article
      where: 'id = ?',
      // Pass the Article's id through as a whereArg to prevent SQL injection
      whereArgs: <dynamic>[article.id],
    );
  }

  static Future<void> deleteAllArticles() async {
    final Database db = await Db.db;
    await db.rawDelete('DELETE FROM ArticlesSaved');
  }

  static Future<int> saveWallet(Wallet newWallet) async {
    final Database db = await Db.db;

    final Map<String, dynamic> row = <String, dynamic>{
      'id': newWallet.id,
      'name': newWallet.name,
    };

    return await db.insert('Wallet ', row);
  }

  static Future<List<Wallet>> getAllWallet() async {
    final Database db = await Db.db;

    // Query the table for All The Article.
    final List<Map<String, dynamic>> maps = await db.query('Wallet');
    Log('database:157', maps.length);
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List<Wallet>.generate(maps.length, (int i) {
      return Wallet(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }

  Future<void> deleteAllWallets() async {
    final Database db = await Db.db;
    await db.rawDelete('DELETE FROM Wallet');
  }

  static Future<void> deleteWallet(Wallet wallet) async {
    Log('database:173', 'deleteWallet] id: ${wallet.id}');
    final Database db = await Db.db;
    await db.delete('Wallet', where: 'id = ?', whereArgs: <dynamic>[wallet.id]);
  }

  static Future<int> saveCurrentWallet(Wallet currentWallet) async {
    await deleteCurrentWallet();
    walletBloc.setCurrentWallet(currentWallet);
    final Database db = await Db.db;

    final Map<String, dynamic> row = <String, dynamic>{
      'id': currentWallet.id,
      'name': currentWallet.name,
    };

    return await db.insert('CurrentWallet ', row);
  }

  static Future<Wallet> getCurrentWallet() async {
    final Database db = await Db.db;

    final List<Map<String, dynamic>> maps = await db.query('CurrentWallet');

    final List<Wallet> wallets = List<Wallet>.generate(maps.length, (int i) {
      return Wallet(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
    if (wallets.isEmpty) {
      return null;
    } else {
      return wallets[0];
    }
  }

  static Future<void> deleteCurrentWallet() async {
    final Database db = await Db.db;
    await db.rawDelete('DELETE FROM CurrentWallet');
  }

  static final Set<String> _active = {};
  static bool _activeFromDb = false;

  static Future<Set<String>> get activeCoins async {
    if (_active.isNotEmpty && _activeFromDb) return _active;

    final Database db = await Db.db;
    for (final row in await db.rawQuery('SELECT abbr FROM CoinsActivated')) {
      final String ticker = row['abbr'];
      if (ticker != null) _active.add(ticker);
    }
    _activeFromDb = true;
    if (_active.isNotEmpty) return _active;

    // Use the first two coins by default.
    final known = await coins;
    _active.addAll(known.keys.take(2));

    return _active;
  }

  /// Add the coin to the list of activated coins.
  static Future<void> coinActive(Coin coin) async {
    _active.add(coin.abbr);
    final Database db = await Db.db;
    await db.insert('CoinsActivated',
        <String, dynamic>{'name': coin.name, 'abbr': coin.abbr},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Remove the coin from the list of activated coins.
  static Future<void> coinInactive(String ticker) async {
    Log('database:246', 'coinInactive] $ticker');
    _active.remove(ticker);
    final Database db = await Db.db;
    await db.delete('CoinsActivated',
        where: 'abbr = ?', whereArgs: <dynamic>[ticker]);
  }

  static Future<int> saveTxNote(String txHash, String note) async {
    final Database db = await Db.db;

    final r = await db.rawQuery(
        'SELECT COUNT(*) FROM TxNotes WHERE tx_hash = ?', <String>[txHash]);
    final count = Sqflite.firstIntValue(r);

    if (count == 0) {
      final Map<String, dynamic> row = <String, dynamic>{
        'tx_hash': txHash,
        'note': note,
      };

      return await db.insert('TxNotes ', row);
    } else {
      final Map<String, dynamic> row = <String, dynamic>{
        'note': note,
      };
      return await db.update('TxNotes', row,
          where: 'tx_hash = ?', whereArgs: <String>[txHash]);
    }
  }

  static Future<String> getTxNote(String txHash) async {
    final Database db = await Db.db;

    final List<Map<String, dynamic>> maps = await db
        .query('TxNotes', where: 'tx_hash = ?', whereArgs: <String>[txHash]);

    final List<String> notes = List<String>.generate(maps.length, (int i) {
      return maps[i]['note'];
    });
    if (notes.isEmpty) {
      return null;
    } else {
      return notes[0];
    }
  }
}
