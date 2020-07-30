import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/user.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';

class EmailPage extends StatefulWidget{

  final BaseDb database;
  final User user;
  final BaseAuth auth;

  EmailPage({this.database, this.user, this.auth});

  @override
  _EmailPageState createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  String email = "";
  String password = "";
  bool _isLoading;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _fieldsValidator(String email, String password) async{
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if(email == "" || email.length < 5 && !regex.hasMatch(email)){
      showSnackBar("Email should contain @ and cant be empty", _scaffoldKey);
    }else if(password == ""){
      showSnackBar("Password should not be empty", _scaffoldKey);
    }else{
      setState(() {
        _isLoading = true;
      });
      _checkIfEmailAlreadyExists();
    }
  }

  void _checkIfEmailAlreadyExists() async {
    bool _exists = await widget.database.checkIfValueAlreadyExists(email, "email");
    if(_exists){
      setState(() {
        _isLoading = false;
      });
      showSnackBar("Email already exists", _scaffoldKey);
    }else{
      _reAuthenitcateAndUpdateEmail();
    }
  }

  void _reAuthenitcateAndUpdateEmail() async{
      AuthResult result = await widget.auth.reAuthenticate(password, widget.user.email);
      if(result == null){
        showSnackBar("Password is not correct", _scaffoldKey);
        setState(() {
          _isLoading = false;
        });
      }else{
        setState(() {
          _isLoading = false;
        });
        _updateEmail(result.user.uid);
      }
  }

  void _updateEmail(String userId) async{
    showSnackBar("Email has been updated", _scaffoldKey);
    await widget.auth.updateEmail(email);
    await widget.database.updateEmail(userId, email);
    Navigator.of(context).pop();
  }

  Widget waitingScreen(){
    if(_isLoading){
      return Container(
        margin: EdgeInsets.only(top: 25),
        alignment: Alignment.center,
        child: CircularProgressIndicator()
        );
    }else{
      return Container(width: 0,height: 0,);
    }
  }

  void initState(){
    _isLoading = false;
    super.initState();
  }

  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xff121212),
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xff2b2a2a),
        title: Text("Email"),
        centerTitle: true,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 17, right: 15),
            child: GestureDetector(
              child: Text("Done", style: TextStyle(color: Colors.white, fontSize: 20),),
              onTap: () => 
              _fieldsValidator(email, password),
            ),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text("Email", style: TextStyle(color: Colors.white),)
            ),
            Container(
            margin: EdgeInsets.only(top: 5),
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration.collapsed(
                filled: true,
                hintText: widget.user.email,
                fillColor: Color(0xff2b2a2a),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder( 
                  borderRadius : BorderRadius.all(Radius.circular(10))
                )
              ),
                onChanged: (value) => setState((){
                  email = value;
                }),
            ),
          ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Text("Please re-enter your password", style: TextStyle(color: Colors.white),)
            ),
            Container(
            margin: EdgeInsets.only(top: 5),
            child: TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration.collapsed(
                filled: true,
                hintText: "Password",
                fillColor: Color(0xff2b2a2a),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder( 
                  borderRadius : BorderRadius.all(Radius.circular(10))
                )
              ),
                onChanged: (value) => setState((){
                  password = value;
                }),
            ),
          ),
            waitingScreen()
          ],
        ),
      ),
    );
  }
}