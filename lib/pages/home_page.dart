import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firenoteapp/models/post_user_model.dart';
import 'package:firenoteapp/pages/detail_page.dart';
import 'package:firenoteapp/services/RTDB_service.dart';
import 'package:firenoteapp/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  static String id="home_page";
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child("posts");
  List<Post> items = [];

  Future _openAdd(BuildContext context) async {
    var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage()));
    if(result != null && result == "successful") AuthService.showSnackBar(context, "Added successfully");
  }

  Future _openEdit(BuildContext context,Post post) async {
    var result = await Navigator.push(context,MaterialPageRoute(builder: (context) => DetailPage(post: post),));
    if(result != null && result == "successful") AuthService.showSnackBar(context, "Edited successfully");
  }

  _openDelete(BuildContext context,String key){
    RTDBService.removePost(key).then((value) => AuthService.showSnackBar(context, "Deleted successfully"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Note"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(color: Colors.white,),
              ),
              currentAccountPictureSize: Size(70,70),
              accountEmail: Text(AuthService.getCurrentUser()?.email ?? "Email"),
              accountName: Text(AuthService.getCurrentUser()?.displayName ?? "DisplayName"),
            ),
            ListTile(
              onTap: (){AuthService.deleteUser(context);},
              leading: Icon(Icons.delete),
              title: Text("Delete Account"),
            ),
            ListTile(
              onTap: (){AuthService.logOutUser(context);},
              leading: Icon(Icons.logout),
              title: Text("Log Out"),
            ),
          ],
        ),
      ),
      body: FirebaseAnimatedList(
        defaultChild: const Center(child: CircularProgressIndicator.adaptive()),
        query: _database.orderByChild("id").limitToLast(20).equalTo(AuthService.getCurrentUser()!.uid),
        itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation animation, int index,) {
          Post post = Post.fromJson(jsonDecode(jsonEncode(snapshot.value)));
          post.key = snapshot.key;
          return buildSlidable(post);
        },
      ),

      // : ListView.separated(
      //   itemCount: items.length,
      //   separatorBuilder: (context, index) => const Divider(),
      //   itemBuilder: (context, index) {
      //     return buildSlidable(context,index);
      //     },
      // ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _openAdd(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Slidable buildSlidable(Post post) {
    return Slidable(
      startActionPane: ActionPane(
        extentRatio: 1 / 6,
        motion: const ScrollMotion(),
        children: [
          //Spacer(),
          SlidableAction(
            backgroundColor: Colors.blue,
            icon: Icons.edit,
            onPressed: (context) {
              _openEdit(context,post);
            },),
        ],
      ),
      endActionPane: ActionPane(
        extentRatio: 1/6,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.red,
            icon: Icons.delete,
            onPressed: (context) {
              _openDelete(context,post.key!);
              },),
        ],
      ),
      child: buildListTile(post),
    );
  }

  ListTile buildListTile(Post post) {
    return ListTile(
          leading: post.imageUrl != null?
            ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CachedNetworkImage(
              height: 40,width: 40,
              fit: BoxFit.cover,
              imageUrl: post.imageUrl!,
              placeholder: (context, url) => Container(height: 40,width: 40, color: Colors.grey.shade200,
                child: Icon(Icons.image_rounded,color: Colors.grey.shade400),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),),)
           :ClipRRect(
            borderRadius: BorderRadius.circular(100),
             child: Container(height: 40,width: 40,
                color: Colors.grey.shade200,
                child: Icon(Icons.image_rounded,color: Colors.grey.shade400,)),
           ),
          title: Text(post.name!),
          subtitle: Text("${post.date}\n${post.content}"),
        );
  }
}
