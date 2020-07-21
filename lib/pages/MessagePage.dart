import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/groupModel.dart';
import 'package:fluttermessenger/models/messageModel.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/widgets/InternalImages.dart';
import 'package:fluttermessenger/pages/UserGroupPage.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';

class MessagePage extends StatefulWidget{

  final BaseDb database;
  final User user;
  final Group group;
  final User sender;
  final String typeKey;
  final bool isChat;
  
  MessagePage({this.database, this.user, this.group, this.sender, this.typeKey, this.isChat});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>{

  User currentUser;
  File file;
  bool imageSheet;

  void getUser() async {
    User dbUser = await widget.database.getUserObject(widget.sender.id);
    setState((){
      currentUser = dbUser;
    });
  }

  Widget _buildMessage(Message message, bool isMe){ 
    final msg = Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: isMe
          ? EdgeInsets.only(
            top: 8.0, 
            bottom: 8.0, 
            left: 80.0,
          ) 
          : EdgeInsets.only(
            top: 8.0, 
            bottom: 8.0,
          ),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: isMe ? Colors.blueAccent: Colors.grey,
        borderRadius: BorderRadius.all(
                Radius.circular(15.0),
              ) 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            formatDateToHoursAndMinutes(message.time),
            style: TextStyle(
              color: Colors.black, 
              fontWeight: FontWeight.bold, 
              fontSize: 15.0),
              ),
          SizedBox(height: 4.0,),
          Text(message.text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        ],
      ),
    );
    final img = Container(
      child:
        message.sender.imageUrl != "" && !isMe
        ? 
        CircleAvatar(
          backgroundImage: NetworkImage(
            message.sender.imageUrl
          ),
        ) 
        : Icon(Icons.android, size: 30,),
    );
    if(isMe){
      return msg;
    }else{
    return Row(
      children: <Widget>[
        img,
        msg,
        IconButton(
          icon: message.isLiked ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
          color: message.isLiked ? Colors.red : Colors.black,
          iconSize: 25.0,
          onPressed: () async {
            message.isLiked 
            ? 
            await widget.database.dislikeMessage(widget.typeKey,message.id) 
            : await widget.database.likeMessage(widget.typeKey, message.id);
          },
        ),
      ],
    );
    }
  }

  Widget _buildImagePicker(){
    if(imageSheet){
      return CustomMediaPicker();
    }else{
      return Container(
        width: 0,
        height: 0,
      );
    }
  }

  //TODO addTime where needed //example if past one day show date
  Widget timestamp(String t, String n){
    DateTime time = formatStringToDateTime(t);
    DateTime current = DateTime.now();
    DateTime next = formatStringToDateTime(n);
    int differenceToday = current.difference(time).inDays;
    int differenceNext = time.difference(next).inDays;
    int differenceNexth = next.difference(time).inHours;
    int differenceNextm = next.difference(time).inMinutes;
    int differenceTodayH = current.difference(time).inHours;
    if(differenceToday != 0 || differenceTodayH > 12){//if its not todat and its off by 12 hours
      if(true){
         return Text(t);
      }else{
        return Container(
          width: 0,
          height: 0,
        );
      }
    }else{
      return Container(
        width: 0,
        height: 0,
      );
    }
  }

  Future<String> _uploadFile() async{
    String url = "";
    try{
      file = await FilePicker.getFile();
      url = await widget.database.uploadChatFileToStorage(file, widget.sender.id);
    }catch(e){
      print(e);
    }
    return url;
  }

  String text = "";
  final textField = TextEditingController();
  Widget _buildMessageComposer(){
    String url = "";
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 40,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25.0,
            onPressed: (){
              setState(() {
                imageSheet = !imageSheet;
              });
            },
          ),
          //TODO enlarge container if picutre is chosen
          url != ""
          ? 
          Container(child: Text(url),)
          :
          Expanded(
            child: TextField(
              controller: textField,
              onChanged: (value) => text = value,
              decoration: InputDecoration.collapsed(hintText: "Send a message..",),
          )),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            onPressed: () => _sendMessage(text),
          )
        ]
      ),
    );
  }

  void _sendMessage(text) async{
    User sender = widget.sender;
    widget.database.addMessage(
      text,
      sender,
      false,
      false,
      getCurrentDate(),
      widget.typeKey
      );
    widget.database.updateLastMessageAndTime(widget.typeKey, text, getCurrentDate(), widget.isChat);
    textField.clear();
  }

  @override
  void initState(){
    getUser();
    imageSheet = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    String imageUrl = widget.isChat ? widget.user.imageUrl : widget.group.imageUrl;

    return Scaffold(
      bottomNavigationBar: null,
      appBar: AppBar(
        title: GestureDetector(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            imageUrl != ""
            ?
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(imageUrl),
            )
            :
            Icon(Icons.android),
            Text(widget.isChat ? widget.user.username : widget.group.name),
            ],),
          onTap: () => {
            widget.isChat ? 
              Navigator.push(context, (MaterialPageRoute(builder: (context) => UserGroupPage(
              user: widget.user,
              database: widget.database,
              currentUserId: widget.sender.id,
              typeKey: widget.typeKey,
              isChat: true,
              ))))
            :
              Navigator.push(context, (MaterialPageRoute(builder: (context) => UserGroupPage(
              group: widget.group,
              database: widget.database,
              currentUserId: widget.sender.id,
              typeKey: widget.typeKey,
              isChat: false,
              ))))
          },
        ),
        elevation: 0.0,//removes the shadow
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: (){},
          )
        ],),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: StreamBuilder(
                      stream: widget.database.getMessageRef().child(widget.typeKey).onValue,
                      builder: (context, snapshot){
                        if(snapshot.hasData && snapshot.data.snapshot.value != null){
                          Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                          List<Message> messages = List<Message>();
                          User sender;
                          Message message;
                          map.forEach((key, value) {
                            sender = User(
                              id: value["sender"]["id"],
                              imageUrl: value["sender"]["imageUrl"],
                              createdAt: value["sender"]["createdAt"],
                              username: value["sender"]["username"],
                              email: value["sender"]["email"]
                            );
                            message = Message(
                              id: key,
                              time: value["time"],
                              sender: sender,
                              text: value["text"],
                              isLiked: value["isLiked"],
                              isRead: value["isRead"]
                            );
                            messages.add(
                              message
                            );
                          });
                          messages.sort((a,b) => formatStringToDateTime(b.time).compareTo(formatStringToDateTime(a.time)));
                          return ListView.builder(
                            reverse: true,
                            padding: EdgeInsets.only(top: 15.0),
                            shrinkWrap: true,
                            itemCount: messages.length,
                            itemBuilder: (BuildContext context, int i){
                              int nextValue = (i + 1) % messages.length;
                              final Message message = messages[i];
                              final isMe = message.sender.id == widget.sender.id; //to differentiate which shows up on which side
                              return Column(
                                children: <Widget>[
                                  _buildMessage(message, isMe),
                                  i < messages.length ? 
                                  
                                  timestamp(message.time, messages[nextValue].time)
                                  :
                                  Container(width: 0, height: 0,)
                                ],
                                );
                            }
                          );
                        }else{
                          return Container(
                            child: Text("Add your first message")
                          );
                        }
                      },
                    )
                ),
              ),
            ),
            _buildMessageComposer(),
            _buildImagePicker()
        ],),
      )
    );
  }
}