import 'dart:async';

import 'package:http/http.dart';
import 'package:komodo_dex/model/article.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:http/http.dart' as http;

MediaBloc mediaBloc = MediaBloc();

class MediaBloc implements BlocBase {
  List<Article> articles = <Article>[];
  List<Article> articlesSaved = <Article>[];

  final StreamController<List<Article>> _articlesController =
      StreamController<List<Article>>.broadcast();

  Sink<List<Article>> get _inArticles => _articlesController.sink;
  Stream<List<Article>> get outArticles => _articlesController.stream;

  final StreamController<List<Article>> _articlesSavedController =
      StreamController<List<Article>>.broadcast();

  Sink<List<Article>> get _inArticlesSaved => _articlesSavedController.sink;
  Stream<List<Article>> get outArticlesSaved => _articlesSavedController.stream;

  @override
  void dispose() {
    _articlesController.close();
    _articlesSavedController.close();
  }

  Future<void> getArticles() async {
    try {
      final Response response =
          await http.get(Uri.parse('https://composer.kmd.io/api/dex/news/all'));
      final List<Article> articlesSaved = await Db.getAllArticlesSaved();
      final List<Article> articles = articleFromJson(response.body);

      for (Article article in articles) {
        article.isSavedArticle = false;

        for (Article savedArticle in articlesSaved) {
          if (savedArticle.id == article.id) {
            article.isSavedArticle = true;
          }
        }
      }
      this.articles = articles;
      _inArticles.add(this.articles);
    } catch (e) {
      Log.println('media_bloc:53', e);
    }
  }

  Future<List<Article>> getArticlesSaved() async {
    final List<Article> articlesSaved = await Db.getAllArticlesSaved();
    this.articlesSaved = articlesSaved;
    _inArticlesSaved.add(this.articlesSaved);
    return articlesSaved;
  }

  Future<void> deleteArticle(Article article) async {
    await Db.deleteArticle(article);
    article.isSavedArticle = false;
    updateSavedArticle(article);
    getArticlesSaved();
  }

  Future<void> addArticle(Article article) async {
    article.isSavedArticle = true;
    await Db.saveArticle(article);
    updateSavedArticle(article);
    getArticlesSaved();
  }

  void updateSavedArticle(Article article) {
    for (Article _article in articles) {
      if (_article.id == article.id) {
        _article.isSavedArticle = article.isSavedArticle;
      }
    }
    _inArticles.add(articles);
  }

  Future<void> deleteAllArticles() async {
    await Db.deleteAllArticles();
  }
}
