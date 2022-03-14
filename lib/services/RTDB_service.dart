
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firenoteapp/models/post_user_model.dart';

class RTDBService{
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  static Future<Stream<DatabaseEvent>> addPost(Post post) async {
    _database.child("posts").push().set(post.toJson());
    return _database.onChildAdded;
  }

  static Future<List<Post>> getPosts(String id) async {
    List<Map<String?, Post>> items = [];
    List<Post> posts = [];
    Query _query = _database.child("posts").orderByChild("id").equalTo(id);
    var event = await _query.once();
    var result = event.snapshot.children;
    //posts = result.map((item) => Post.fromJson(Map<String,dynamic>.from(item.value as Map))).toList();
    items = result.map((item) => {item.key: Post.fromJson(jsonDecode(jsonEncode(item.value)))}).toList();

    posts = items.map((e) => Post(key: e.keys.first, id: e.values.first.id, name: e.values.first.name,
       content: e.values.first.content, imageUrl: e.values.first.imageUrl, date: e.values.first.date,)).toList();

    return posts;
  }

  static Future<Stream<DatabaseEvent>> updatePost(Post post) async{
    _database.child("posts").child(post.key!).update(post.toJson());
    return _database.onChildChanged;
  }

  static Future<Stream<DatabaseEvent>> removePost(String key) async {
    _database.child("posts").child(key).remove();
    return _database.onChildRemoved;
  }
  }