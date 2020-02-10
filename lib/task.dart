import  'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterlist/card.dart';

class TaskPage extends StatefulWidget {
  TaskPage({@required this.title, this.description, this.id, this.uid, this.priority});

  final String title;
  final String description;
  final String priority;
  final String id;
  final String uid;



  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  TextEditingController taskTitleInputController;
  TextEditingController taskDescripInputController;
  FirebaseUser currentUser;

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
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(widget.description),
                RaisedButton(
                    child: Text('Modify Task'),
                    color: Theme
                        .of(context)
                        .primaryColor,
                    textColor: Colors.white,
                    onPressed: _showDialog
                ),
                RaisedButton(
                    child: Text('Delete Task'),
                    color: Colors.red,
                    textColor: Colors.black,
                    onPressed: _deleteTask,
                ),
                RaisedButton(
                    child: Text('Back To HomeScreen'),
                    color: Theme
                        .of(context)
                        .primaryColor,
                    textColor: Colors.white,
                    onPressed: () => Navigator.pop(context)),
              ]),
        ));
  }

  _showDialog() async {
    List<String> _priorities = <String>['DO FIRST', 'SCHEDULE', 'DELEGATE', "DON'T DO"];
    String _priority;
    String o;
    var t = await Firestore.instance
        .collection("users")
        .document(widget.uid)
        .collection('tasks')
        .document(widget.id)
        .get();
    taskTitleInputController.text = t.data['title'];
    taskDescripInputController.text = t.data['description'];
    _priority = t.data['priority'];
    await showDialog<String>(
      context: context,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          children: <Widget>[
            Text("Please fill all fields to Update  task"),
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
              child: Text('Modify'),
              onPressed: () {
                if (taskDescripInputController.text.isNotEmpty &&
                    taskTitleInputController.text.isNotEmpty) {
                  Firestore.instance
                      .collection("users")
                      .document(widget.uid)
                      .collection('tasks')
                      .document(widget.id)
                      .updateData({
                    "title": taskTitleInputController.text,
                    "description": taskDescripInputController.text,
                    "priority": _priority,
                  })
                      .then((result) =>
                  {
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

  _deleteTask() async {
    await showDialog<String>(
      context: context,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        actions: <Widget>[
          FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text('Delete'),
              onPressed: () {
                  Firestore.instance
                      .collection("users")
                      .document(widget.uid)
                      .collection('tasks')
                      .document(widget.id)
                      .delete()
                      .then((result) =>
                  {
                    Navigator.pop(context),
                  })
                      .catchError((err) => print(err));
              })
        ],
      ),
    );
  }
}