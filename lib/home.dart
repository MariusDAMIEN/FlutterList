import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterlist/card.dart';
import 'package:flutterlist/task.dart';
import 'menu.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.uid, this.prio}) : super(key: key); //update this to include the uid in the constructor
  final String title;
  final String prio;
  final String uid; //include this

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
      body: Container(
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection("users")
                  .document(widget.uid)
                  .collection('tasks')
                  .where('priority', isEqualTo: widget.prio)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)

                  return new Text('je su');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new Text('Loading...');
                  default:
                    Text: "test";
                    return new ListView(
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                            return new NewCard(
                              document: document,
                              uid: widget.uid,
                            );
                      }).toList(),
                    );
                }
              },
            )
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