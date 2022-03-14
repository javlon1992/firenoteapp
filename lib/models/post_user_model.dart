
class Post{
  String? key;
  String? id;
  String? name;
  String? imageUrl;
  String? content;
  String? date;

  Post({this.key, this.id, this.name, this.content, this.date, this.imageUrl});

  Post.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        key = json['key'],
        name = json['name'],
        imageUrl = json['imageUrl'],
        content = json['content'],
        date = json['date'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'name': name,
    'imageUrl': imageUrl,
    'content': content,
    'date': date,
  };
}