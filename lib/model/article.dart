// To parse this JSON data, do
//
//     final article = articleFromJson(jsonString);

import 'dart:convert';

import 'package:intl/intl.dart';

List<Article> articleFromJson(String str) => new List<Article>.from(json.decode(str).map((x) => Article.fromJson(x)));

String articleToJson(List<Article> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class Article {
    List<String> media;
    String id;
    String title;
    String header;
    String body;
    String keywords;
    DateTime creationDate;
    bool isSavedArticle;
    String author;
    int v;

    Article({
        this.media,
        this.id,
        this.title,
        this.header,
        this.body,
        this.keywords,
        this.creationDate,
        this.isSavedArticle,
        this.author,
        this.v,
    });

    factory Article.fromJson(Map<String, dynamic> json) => new Article(
        media: new List<String>.from(json["media"].map((x) => x)),
        id: json["_id"],
        title: json["title"],
        header: json["header"],
        body: json["body"],
        keywords: json["keywords"],
        isSavedArticle: json["isSavedArticle"],
        author: json["author"] == null ? "Komodo Platform" : json["author"],
        creationDate: DateTime.parse(json["creation_date"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "media": new List<dynamic>.from(media.map((x) => x)),
        "_id": id,
        "title": title,
        "header": header,
        "body": body,
        "keywords": keywords,
        "author": author,
        "isSavedArticle": isSavedArticle,
        "creation_date": creationDate.toIso8601String(),
        "__v": v,
    };

    String getTimeFormat() {
      return DateFormat('dd/MM/yyyy').format(creationDate);
    }
}
