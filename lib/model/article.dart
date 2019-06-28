// To parse this JSON data, do
//
//     final article = articleFromJson(jsonString);

import 'dart:convert';

import 'package:intl/intl.dart';

List<Article> articleFromJson(String str) =>
    new List<Article>.from(json.decode(str).map((x) => Article.fromJson(x)));

String articleToJson(List<Article> data) =>
    json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class Article {
  List<String> media;
  String id;
  String title;
  String header;
  String body;
  String keywords;
  DateTime creationDate;
  bool isSavedArticle;

  int v;
  String author;

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

  factory Article.fromJson(Map<String, dynamic> json) => new Article(
        media: json["media"] == null
            ? null
            : new List<String>.from(json["media"].map((x) => x)),
        id: json["_id"] == null ? null : json["_id"],
        title: json["title"] == null ? null : json["title"],
        header: json["header"] == null ? null : json["header"],
        body: json["body"] == null ? null : json["body"],
        isSavedArticle:
            json["isSavedArticle"] == null ? null : json["isSavedArticle"],
        keywords: json["keywords"] == null ? null : json["keywords"],
        creationDate: json["creation_date"] == null
            ? null
            : DateTime.parse(json["creation_date"]),
        v: json["__v"] == null ? null : json["__v"],
        author: json["author"] == null ? null : json["author"],
      );

  Map<String, dynamic> toJson() => {
        "media":
            media == null ? null : new List<dynamic>.from(media.map((x) => x)),
        "_id": id == null ? null : id,
        "title": title == null ? null : title,
        "header": header == null ? null : header,
        "body": body == null ? null : body,
        "keywords": keywords == null ? null : keywords,
        "isSavedArticle": isSavedArticle == null ? null : isSavedArticle,
        "creation_date":
            creationDate == null ? null : creationDate.toIso8601String(),
        "__v": v == null ? null : v,
        "author": author == null ? null : author,
      };

  String getTimeFormat() {
    return DateFormat('dd/MM/yyyy').format(creationDate);
  }
}
