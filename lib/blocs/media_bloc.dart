import 'dart:async';

import 'package:komodo_dex/model/article.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:http/http.dart' as http;

final mediaBloc = MediaBloc();

class MediaBloc implements BlocBase {
  List<Article> articles = new List<Article>();
  List<Article> articlesSaved = new List<Article>();

  StreamController<List<Article>> _articlesController =
      StreamController<List<Article>>.broadcast();

  Sink<List<Article>> get _inArticles => _articlesController.sink;
  Stream<List<Article>> get outArticles => _articlesController.stream;

  StreamController<List<Article>> _articlesSavedController =
      StreamController<List<Article>>.broadcast();

  Sink<List<Article>> get _inArticlesSaved => _articlesSavedController.sink;
  Stream<List<Article>> get outArticlesSaved => _articlesSavedController.stream;

  @override
  void dispose() {
    _articlesController.close();
    _articlesSavedController.close();
  }

  void getArticles() async {
    final response =
        await http.get("https://genesis.kmd.dev/api/dex/news/all");
    List<Article> articlesSaved = await DBProvider.db.getAllArticlesSaved();
    List<Article> articles = articleFromJson(response.body);

    articles.forEach((article) {
      article.isSavedArticle = false;
      articlesSaved.forEach((savedArticle) {
        if (savedArticle.id == article.id) {
          article.isSavedArticle = true;
        }
      });
    });
    this.articles = articles;
    _inArticles.add(this.articles);
  }

  Future<List<Article>> getArticlesSaved() async {
    List<Article> articlesSaved = await DBProvider.db.getAllArticlesSaved();
    this.articlesSaved = articlesSaved;
    _inArticlesSaved.add(this.articlesSaved);
    return articlesSaved;
  }

  deleteArticle(Article article) async {
    print("deleteArticle");
    await DBProvider.db.deleteArticle(article);
    article.isSavedArticle = false;
    updateSavedArticle(article);
    getArticlesSaved();
  }

  addArticle(Article article) async {
    print("addarticle");
    article.isSavedArticle = true;
    await DBProvider.db.saveArticle(article);
    updateSavedArticle(article);
    getArticlesSaved();
  }

  updateSavedArticle(Article article) {
    this.articles.forEach((_article) {
      if (_article.id == article.id) {
        _article.isSavedArticle = article.isSavedArticle;
      }
    });
    _inArticles.add(this.articles);
  }

  deleteAll() async {
    await DBProvider.db.deleteAll();
  }
}
