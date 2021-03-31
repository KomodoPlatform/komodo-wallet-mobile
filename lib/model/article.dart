// To parse this JSON data, do
//
//     final article = articleFromJson(jsonString);

import 'dart:convert';

import 'package:intl/intl.dart';

List<Article> articleFromJson(String str) => List<Article>.from(
    json.decode(str).map((dynamic x) => Article.fromJson(x)));

String articleToJson(List<Article> data) => json
    .encode(List<dynamic>.from(data.map<dynamic>((Article x) => x.toJson())));

class Article {
  Article({
    this.media,
    this.id,
    this.title,
    this.header,
    this.body,
    this.keywords,
    this.creationDate,
    this.isSavedArticle,
    this.v,
    this.author,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        media: List<String>.from(json['media'].map((dynamic x) => x)) ??
            <String>[],
        id: json['_id'] ?? '',
        title: json['title'] ?? '',
        header: json['header'] ?? '',
        body: json['body'] ?? '',
        isSavedArticle: json['isSavedArticle'] ?? false,
        keywords: json['keywords'] ?? '',
        creationDate: DateTime.parse(json['creation_date']) ?? DateTime.now(),
        v: json['__v'] ?? 0,
        author: json['author'] ?? '',
      );

  String id;
  String title;
  String header;
  String body;
  String keywords;
  String author;
  List<String> media;
  DateTime creationDate;
  bool isSavedArticle;
  int v;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'media': List<String>.from(media.map<String>((dynamic x) => x)) ??
            <String>[],
        '_id': id ?? '',
        'title': title ?? '',
        'header': header ?? '',
        'body': body ?? '',
        'keywords': keywords ?? '',
        'isSavedArticle': isSavedArticle ?? false,
        'creation_date': creationDate.toIso8601String() ?? DateTime.now(),
        '__v': v ?? 1,
        'author': author ?? '',
      };

  String getTimeFormat() {
    return DateFormat('dd/MM/yyyy').format(creationDate);
  }
}
