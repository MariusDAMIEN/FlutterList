import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'menu.dart';

class SplashPage extends StatefulWidget {
  SplashPage({ Key key, this.prio}) : super(key: key);

  final String prio;

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  initState() {

    FirebaseAuth.instance
        .currentUser()
        .then((currentUser) => {
      if (currentUser == null)
        {Navigator.pushReplacementNamed(context, "/login")}
      else
        {
          Firestore.instance
              .collection("users")
              .document(currentUser.uid)
              .get()
              .then((DocumentSnapshot result) =>
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MenuPage(
                        title: "Bonjour ",
                        uid: currentUser.uid,
                        prio: widget.prio,
//                      ))))
                      ))))
              .catchError((err) => print(err))
        }
    })
        .catchError((err) => print(err));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text("Loading..."),
        ),
      ),
    );
  }
}