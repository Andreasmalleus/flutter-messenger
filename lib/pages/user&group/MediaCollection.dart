import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/storageFile.dart';
import 'package:fluttermessenger/services/database.dart';

class MediaCollection extends StatefulWidget{

  MediaCollection({this.database, this.typeId});
  final BaseDb database;
  final String typeId;

  @override
  _MediaCollectionState createState() => _MediaCollectionState();
}

class _MediaCollectionState extends State<MediaCollection> {


  List<StorageFile> files = List<StorageFile>();
  void initState(){
    super.initState();
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Photos and videos"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: widget.database.listAllStorageFilesById(widget.typeId),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
          files = snapshot.data;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ), 
            itemCount: files.length,
            itemBuilder: (BuildContext context, int i){
              return Container(
                child: GestureDetector(
                  onTap: () => print("Enlarge picture"),
                  child: Container(
                    child: Image.network(files[i].url, fit: BoxFit.cover,)
                  ),
                ),
              );
            });
          }else{
            return Container(
              alignment: Alignment.center,
              child: Text("No images so far", style: TextStyle(fontSize: 20),),
            );
          }
        },
      )
    );
  }
}

class DetailScreen extends StatelessWidget{
  Widget build(BuildContext context){
    return Container(child: Text("Enlarged"),);
  }
}