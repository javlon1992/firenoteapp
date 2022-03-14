import 'dart:io';
import 'package:firenoteapp/models/post_user_model.dart';
import 'package:firenoteapp/services/RTDB_service.dart';
import 'package:firenoteapp/services/auth_service.dart';
import 'package:firenoteapp/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class DetailPage extends StatefulWidget {
  static String id="detail_page";
  Post? post;
  DetailPage({Key? key,this.post}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  var contentController = TextEditingController();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var dateController = TextEditingController();
  File? _image;
  bool isLoad = false;
  String? imgUrl;

  Future<void> _getImage() async{
   try{
     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
     if(pickedFile != null){
      setState(() {
        isLoad = true;
        _image = File(pickedFile.path);
      });
      await StorageService.deleteImage(widget.post?.imageUrl);
      imgUrl = await StorageService.getImageUrl(_image);
      if (mounted) {
        setState(() {isLoad = false;});
      }
    }else{
       AuthService.showSnackBar(context, "PickedFile is null");
     }
  }on PlatformException catch (e) {
    AuthService.showSnackBar(context, e.message.toString());
   }
  }

  Future<void> _addPost(BuildContext context) async{

    setState(() {isLoad = true;});
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String content = contentController.text.trim();
    String date = dateController.text.trim();

    Post post = Post(id: AuthService.getCurrentUser()!.uid, key: widget.post?.key, content: content,
        imageUrl:_image != null? imgUrl: widget.post?.imageUrl, name: "$firstName $lastName", date: date);

    if(widget.post == null) {
      RTDBService.addPost(post).then((value){
        setState(() {isLoad = false;});
        Navigator.of(context).pop("successful");});
    }else{
      RTDBService.updatePost(post).then((value){
        setState(() {isLoad = false;});
        Navigator.of(context).pop("successful");});
    }

  }

  @override
  void dispose() {
    super.dispose();
    contentController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.post == null ? "Add" : "Edit"),
      ),
  body: isLoad ? const Center(child: CircularProgressIndicator.adaptive())
        : SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25),
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Stack(
                 children: [
                   Center(
                     child: Container(
                       height: 200,width: 200,
                       decoration: const BoxDecoration(
                         shape: BoxShape.circle,
                         color: Colors.black12,
                       ),
                       child: (_image == null && widget.post?.imageUrl == null)
                          ? const Center(child: Icon(Icons.image_rounded,size: 100,color: Colors.grey,))
                          : (_image != null)
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.file(_image!, fit: BoxFit.cover))
                          : ClipRRect(
                           borderRadius: BorderRadius.circular(100),
                           child: Image.network(widget.post!.imageUrl!, fit: BoxFit.cover)),

                     ),
                   ),
                  Positioned(
                    bottom: 0,right: 60,
                    child: MaterialButton(
                      color: Colors.blue,
                      height: 40,minWidth: 40,
                      shape: CircleBorder(),
                      child: const Icon(Icons.add,color: Colors.white,),
                     onPressed: () async {
                       await _getImage();
                    }),
                  )
                 ],
               ),
              // #firstname
              TextField(
                textInputAction: TextInputAction.next,
                controller: firstNameController..text = widget.post == null ?  firstNameController.text : widget.post!.name!.split(" ").first,
                decoration: InputDecoration(hintText: "Firstname"),
              ),
              SizedBox(height: 10,),

              // #lastname
              TextField(
                textInputAction: TextInputAction.next,
                controller: lastNameController..text = widget.post == null ? lastNameController.text : widget.post!.name!.split(" ").last,
                decoration: InputDecoration(hintText: "Lastname"),
              ),
              SizedBox(height: 10,),

              // #email
              TextField(
                textInputAction: TextInputAction.next,
                controller: contentController..text = widget.post == null ? contentController.text : widget.post!.content.toString(),
                decoration: InputDecoration(hintText: "Content"),
              ),
              SizedBox(height: 10,),

              // #password
              TextField(
                controller: dateController..text = widget.post == null ? dateController.text : widget.post!.date.toString(),
                decoration: InputDecoration(hintText: "Date"),
              ),
              SizedBox(height: 10,),

              // #sign_up
              MaterialButton(
                onPressed: (){
                  _addPost(context);
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                //focusNode: FocusNode(),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                ),
                height: 50,
                minWidth: MediaQuery.of(context).size.width - 50,
                color: Colors.blueAccent,
                child: Text(widget.post == null ? "Add" : "Edit"),
                textColor: Colors.white,
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}
