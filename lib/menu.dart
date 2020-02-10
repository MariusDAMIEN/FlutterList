import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterlist/card.dart';
import 'package:flutterlist/task.dart';
import 'package:flutter/material.dart';
import 'SplashPage.dart';
import 'home.dart';
import 'register.dart';
import 'login.dart';


class MenuPage extends StatefulWidget {
  const MenuPage({@required this.title, this.uid, this.prio});

  final String title;
  final String uid;
  final String prio;

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  TextEditingController taskTitleInputController;
  TextEditingController taskDescripInputController;
  FirebaseUser currentUser;
  String prio;

  @override
  initState() {
    taskTitleInputController = new TextEditingController();
    taskDescripInputController = new TextEditingController();
    this.getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return Scaffold(
        appBar: AppBar(
          title: Text("welcolme Marius"),
          actions: <Widget>[
            FlatButton(
              child: Text("Log Out"),
              textColor: Colors.white,
              onPressed: () {
                FirebaseAuth.instance
                    .signOut()
                    .then((result) =>
                    Navigator.pushReplacementNamed(context, "/login"))
                    .catchError((err) => print(err) );
              },
            )
          ],
        ),
        body: GridView.count(
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          crossAxisCount: 2,
          padding: const EdgeInsets.all(15.0),
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: (itemWidth / itemHeight),
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                                   builder: (context) => HomePage(
                        title: "DO FIRST",
                        uid: widget.uid,
                        prio: "DO FIRST",
                )));
//                Navigator.pushReplacementNamed(context, "/home");
              },
              child: Container(
                color: Colors.greenAccent,
                child: Center(
                  child: Text(
                      "DO FIRST",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  color: Colors.black,)
                ),
              ),
            ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                          title: "SCHEDULE",
                          uid: widget.uid,
                          prio: "SCHEDULE",
                        )));
//                Navigator.pushReplacementNamed(context, "/home");
              },
              child: Container(
                color: Colors.blueAccent,
                child: Center(
                  child: Text(
                      "SCHEDULE",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,)
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                          title: "DELEGATE",
                          uid: widget.uid,
                          prio: "DELEGATE",
                        )));
//                Navigator.pushReplacementNamed(context, "/home");
              },
              child: Container(
                color: Colors.orangeAccent,
                child: Center(
                  child: Text(
                      "DELEGATE",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,)
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                          title: "DON'T DO",
                          uid: widget.uid,
                          prio: "DON'T DO",
                        )));
//                Navigator.pushReplacementNamed(context, "/home");
              },
              child: Container(
                color: Colors.redAccent,
                child: Center(
                  child: Text(
                      "DON'T DO",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,)
                  ),
                ),
              ),
            ),
          ]
          ),
      floatingActionButton: FloatingActionButton(
      onPressed: _showDialog,
      tooltip: 'Add',
      child: Icon(Icons.add),
    ),

    );
  }

  _showDialog() async {
    List<String> _priorities = <String>['DO FIRST', 'SCHEDULE', 'DELEGATE', "DON'T DO"];
    String _priority = 'DO FIRST';

    await showDialog<String>(
      context: context,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          children: <Widget>[
            Text("Please fill all fields to create a new task"),
            Expanded(
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(labelText: 'Task Title*'),
                controller: taskTitleInputController,
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(labelText: 'Task Description*'),
                controller: taskDescripInputController,
              ),
            ),
            new FormField(
              builder: (FormFieldState state) {
                return InputDecorator(
                  decoration: InputDecoration(
                    icon: const Icon(Icons.check),
                    labelText: 'Priotity',
                  ),
                  isEmpty: _priority == '',
                  child: new DropdownButtonHideUnderline(
                    child: new DropdownButton(
                      value: _priority,
                      isDense: true,
                      onChanged: (String newValue) {
                        setState(() {
//                          prio = newValue;
                          _priority = newValue;
                          state.didChange(newValue);
                        });
                      },
                      items: _priorities.map((String value) {
                        return new DropdownMenuItem(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                taskTitleInputController.clear();
                taskDescripInputController.clear();
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text('Add'),
              onPressed: () {
                if (taskDescripInputController.text.isNotEmpty &&
                    taskTitleInputController.text.isNotEmpty) {
                  Firestore.instance
                      .collection("users")
                      .document(widget.uid)
                      .collection('tasks')
                      .add({
                    "title": taskTitleInputController.text,
                    "description": taskDescripInputController.text,
                    "priority": _priority,
                  })
                      .then((result) => {
                    Navigator.pop(context),
                    taskTitleInputController.clear(),
                    taskDescripInputController.clear(),
                  })
                      .catchError((err) => print(err));
                }
              })
        ],
      ),
    );
  }
}
