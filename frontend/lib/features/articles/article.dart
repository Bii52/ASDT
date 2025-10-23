class Article {
  final String id, title, summary;
  final String? thumbnail, content;
  Article({
    required this.id,
    required this.title,
    required this.summary,
    this.thumbnail,
    this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['_id'],
      title: json['title'],
      summary: json['summary'],
      thumbnail: json['thumbnail'],
      content: json['content'],
    );
  }
}
