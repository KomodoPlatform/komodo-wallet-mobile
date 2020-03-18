import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/model/article.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

enum CoinEletrum { DEFAULT, SAVED, CONFIG }

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
    final Directory documentsDirectory = await applicationDocumentsDirectory;
    final String path = join(documentsDirectory.path, 'AtomicDEX.db');
    return await openDatabase(path, version: 1, onOpen: (Database db) {},
        onCreate: (Database db, int version) async {
      Log('database:38', 'initDB - openDB');
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

      await db.execute(createTableCoins(CoinEletrum.SAVED));
      await db.execute(createTableCoins(CoinEletrum.DEFAULT));
      await db.execute(createTableCoins(CoinEletrum.CONFIG));

      //temporary quick-fix/hackaround for 'no such table' error after app update - cc: tonymorony
      // try {
      //   final dynamic res = await db.query('CoinsActivated');
      //   if (res is ErrorString && res.error.contains('no such')) {
      //     Log(
      //         'database:77', 'noSuchCoinsActivatedError - creating table...');
      //     await db.execute('''
      // CREATE TABLE CoinsActivated} (
      //     name TEXT PRIMARY KEY UNIQUE,
      //     type TEXT,
      //     address TEXT,
      //     port INTEGER,
      //     proto TEXT,
      //     txfee INTEGER,
      //     priceUSD REAL,
      //     mm2 INTEGER,
      //     swap_contract_address TEXT,
      //     abbr TEXT,
      //     coingeckoId TEXT,
      //     colorCoin TEXT,
      //     serverList TEXT,
      //     explorerUrl TEXT
      //   )
      // ''');
      //   } else {
      //     Log('database:97', 'Table exists');
      //   }
      // } catch (e) {
      //   Log('database:100', 'DB INIT ERROR: ' + e.toString());
      // }
    });
  }

  String createTableCoins(CoinEletrum coinEletrum) {
    Log('database:106', 'CREATE: ' + _getDbElectrum(coinEletrum));
    return '''
      CREATE TABLE ${_getDbElectrum(coinEletrum)} (
          name TEXT PRIMARY KEY UNIQUE,
          type TEXT,
          address TEXT,
          port INTEGER,
          proto TEXT,
          txfee INTEGER,
          priceUSD REAL,
          mm2 INTEGER,
          swap_contract_address TEXT,
          abbr TEXT,
          coingeckoId TEXT,
          colorCoin TEXT,
          serverList TEXT,
          explorerUrl TEXT
        )
      ''';
  }

  String _getDbElectrum(CoinEletrum coinEletrum) {
    switch (coinEletrum) {
      case CoinEletrum.DEFAULT:
        return 'CoinsDefault';
      case CoinEletrum.SAVED:
        return 'CoinsActivated';
      case CoinEletrum.CONFIG:
        return 'CoinsConfig';
      default:
        return 'CoinsDefault';
    }
  }

  String _getPathJsonElectrum(CoinEletrum coinEletrum) {
    switch (coinEletrum) {
      case CoinEletrum.DEFAULT:
        return 'coins_activate_default';
      case CoinEletrum.SAVED:
        return 'coins_activate_default';
      case CoinEletrum.CONFIG:
        return 'coins_config';
      default:
        return 'coins_activate_default';
    }
  }

  Future<void> saveCoinActivate(CoinEletrum coinEletrum, Coin coin) async {
    final Database db = await database;

    final Map<String, dynamic> row = <String, dynamic>{
      'name': coin.name ?? '',
      'type': coin.type ?? '',
      'address': coin.address ?? '',
      'port': coin.port ?? 0,
      'proto': coin.proto ?? '',
      'txfee': coin.txfee ?? 0,
      'priceUSD': coin.priceUsd ?? 0.0,
      'mm2': coin.mm2 ?? 0,
      'abbr': coin.abbr ?? '',
      'coingeckoId': coin.coingeckoId ?? '',
      'swap_contract_address': coin.swapContractAddress ?? '',
      'colorCoin': coin.colorCoin ?? '',
      'serverList': json.encode(coin.serverList) ?? <String>[],
      'explorerUrl': json.encode(coin.explorerUrl) ?? <String>[],
    };
    if (!(await exists(coinEletrum, coin.name))) {
      await db.insert(_getDbElectrum(coinEletrum), row);
    }
  }

  Future<bool> exists(CoinEletrum coinEletrum, String name) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
        _getDbElectrum(coinEletrum),
        where: 'name = ?',
        whereArgs: <dynamic>[name]);
    if (maps.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Coin>> electrumCoins(CoinEletrum coinEletrum) async {
    // Get a reference to the database
    final Database db = await database;

    // Query the table for All The CoinSActivate.
    final List<Map<String, dynamic>> maps =
        await db.query(_getDbElectrum(coinEletrum));

    // Convert the List<Map<String, dynamic> into a List<Coin>.
    return List<Coin>.generate(maps.length, (int i) {
      return Coin(
        name: maps[i]['name'],
        type: maps[i]['type'],
        swapContractAddress: maps[i]['swap_contract_address'],
        mm2: maps[i]['mm2'],
        priceUsd: maps[i]['priceUSD'],
        address: maps[i]['address'],
        port: maps[i]['port'],
        proto: maps[i]['proto'],
        txfee: maps[i]['txfee'],
        abbr: maps[i]['abbr'],
        coingeckoId: maps[i]['coingeckoId'],
        colorCoin: maps[i]['colorCoin'],
        serverList: List<String>.from(json.decode(maps[i]['serverList'])),
        explorerUrl: List<String>.from(json.decode(maps[i]['explorerUrl'])),
      );
    });
  }

  Future<void> updateCoinActivate(CoinEletrum coinEletrum, Coin coin) async {
    // Get a reference to the database
    final Database db = await database;

    final Map<String, dynamic> row = <String, dynamic>{
      'name': coin.name,
      'type': coin.type,
      'address': coin.address,
      'port': coin.port,
      'proto': coin.proto,
      'txfee': coin.txfee,
      'abbr': coin.abbr,
      'coingeckoId': coin.coingeckoId,
      'colorCoin': coin.colorCoin,
      'serverList': json.encode(coin.serverList),
      'explorerUrl': json.encode(coin.explorerUrl)
    };
    // Update the Coin from the Database
    if (await exists(coinEletrum, coin.name)) {
      await db.update(
        _getDbElectrum(coinEletrum),
        row,
        where: 'name = ?',
        whereArgs: <dynamic>[coin.name],
      );
    } else {
      await saveCoinActivate(coinEletrum, coin);
    }
  }

  Future<void> deleteCoinActivate(CoinEletrum coinEletrum, Coin coin) async {
    // Get a reference to the database
    final Database db = await database;

    // Remove the Coin from the Database
    await db.delete(
      _getDbElectrum(coinEletrum),
      where: 'name = ?',
      whereArgs: <dynamic>[coin.name],
    );
  }

  Future<void> deleteAllCoinActivate(CoinEletrum coinEletrum) async {
    final Database db = await database;
    await db.delete(_getDbElectrum(coinEletrum));
  }

  Future<void> initCoinsActivateDefault(CoinEletrum coinEletrum) async {
    await deleteAllCoinActivate(coinEletrum);
    try {
      final String contents = await rootBundle
          .loadString('assets/${_getPathJsonElectrum(coinEletrum)}.json');
      for (Coin coin in coinFromJson(contents)) {
        await saveCoinActivate(coinEletrum, coin);
      }
    } catch (e) {
      Log('database:275', 'Error on initCoinsActivateDefault');
    }
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
    Log('database:304', maps.length);
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
    };

    return await db.insert('Wallet ', row);
  }

  Future<List<Wallet>> getAllWallet() async {
    // Get a reference to the database
    final Database db = await database;

    // Query the table for All The Article.
    final List<Map<String, dynamic>> maps = await db.query('Wallet');
    Log('database:358', maps.length);
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List<Wallet>.generate(maps.length, (int i) {
      return Wallet(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }

  Future<void> deleteAllWallets() async {
    final Database db = await database;
    await db.rawDelete('DELETE FROM Wallet');
  }

  Future<void> deleteWallet(Wallet wallet) async {
    Log('database:374', wallet.id);
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
      );
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
