import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/user.dart';
import 'package:fluttermessenger/pages/sign_in_up.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:provider/provider.dart';

import 'navigator.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN
}

class RootPage extends StatefulWidget{

  final BaseAuth auth;
  final BaseDb database;
  RootPage({this.auth, this.database});

  @override
  _RootPageState createState() => _RootPageState();

}

class _RootPageState extends State<RootPage>{
  AuthStatus status = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  void loginCallBack(){
    widget.auth.getCurrentUser().then((firebaseUser) => {
        setState((){
          status = AuthStatus.LOGGED_IN;
          _userId = firebaseUser.uid;
        })
    });
  }

  void logOutCallback(){
    setState(() {
      status = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  @override
  void initState(){
    widget.auth.getCurrentUser().then((firebaseUser) => {
      if(firebaseUser != null){
          setState((){
            _userId = firebaseUser.uid;
          })
      },
      setState((){
        status = firebaseUser?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      })
    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context){
    switch (status) {
      case AuthStatus.NOT_DETERMINED:
        return waitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return SignInUpPage(
          auth: widget.auth,
          database: widget.database,
          loginCallback: loginCallBack
        );
      case AuthStatus.LOGGED_IN:
        if(_userId.length > 0 && _userId != null){
          return MultiProvider(
            providers: [
              StreamProvider<User>.value(
                value: widget.database.streamUser(_userId)
              ),
            ],
              child: NavigatorPage(
              auth: widget.auth,
              logOutCallback : logOutCallback,
              database: widget.database,
            ),
          );
        }else{
          return waitingScreen();
        }
        break;
      default:
        return waitingScreen();
        break;
    }
  }

  Widget waitingScreen(){
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}