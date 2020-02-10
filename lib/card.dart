import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart';


class NewCard extends StatefulWidget {
  NewCard({@required this.document, this.uid});

  final document;
  final uid;
  @override
  _NewCardState createState() => _NewCardState();
}

class _NewCardState extends State<NewCard> {

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
                      .document(widget.document.documentID)
                      .delete();
                  Navigator.pop(context);
                })
          ],
        ),
      );
    }

    _showDialog() async {
      List<String> _priorities = <String>['DO FIRST', 'SCHEDULE', 'DELEGATE', "DON'T DO"];
      String _priority;
      String o;
      var t = await Firestore.instance
          .collection("users")
          .document(widget.uid)
          .collection('tasks')
          .document(widget.document.documentID)
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
                        .document(widget.document.documentID)
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

    return (
         Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
          color: Colors.white,
          child: ListTile(
            title: Text(widget.document['title']),
            subtitle: Text(widget.document['description']),
          ),
        ),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Update',
            color: Colors.black45,
            icon: Icons.more_horiz,
            onTap: () => _showDialog(),
          ),
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => _deleteTask(),
          ),
        ],
      )
    );
  }
}