import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_demo/pages/records_list.dart';
import 'package:firestore_demo/pages/records_tab_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Firestore fireStoreDataBase = Firestore.instance;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<DocumentSnapshot> documents;

  String collectionName = "master";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('URL Manager'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreDataBase.collection(collectionName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            documents = snapshot.data.documents;
            return buildRecordList();
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addEditRecordDialog(context, null);
        },
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildRecordList() {
    return ListView(
      children: documents.map((doc) {
        return Dismissible(
          key: Key(doc['title']),
          onDismissed: (direction) {
            //deleteRecord(doc.documentID);
          },
          confirmDismiss: (direction) {
            confirmDeleteDialog(context,doc.documentID);
          },
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RecordsTabPage(collectionName: doc['title']),
                ),
              );
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          doc['title']!=null?Text('${doc['title']}',
                              style: (TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold))):Container(),
                          doc['description']!=null?SizedBox(
                            height: 5,
                          ):Container(),
                          doc['description']!=null?Text('${doc['description']}',
                              style: (TextStyle(
                                fontSize: 16,
                              ))):Container(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void createRecord() async {
    await fireStoreDataBase.collection(collectionName).add({
      'title': titleController.text,
      'description': descriptionController.text,
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Record Created..!!")));
  }

  void updateRecord(String documentId) {
    try {
      fireStoreDataBase
          .collection(collectionName)
          .document(documentId)
          .updateData({
        'title': titleController.text,
        'description': descriptionController.text,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Record Updated..!!")));
    } catch (e) {
      print(e.toString());
    }
  }

  void deleteRecord(String documentId) {
    try {
      fireStoreDataBase
          .collection(collectionName)
          .document(documentId)
          .delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Record Deleted..!!")));
    } catch (e) {
      print(e.toString());
    }
  }

  addEditRecordDialog(BuildContext context, DocumentSnapshot doc) async {
    if (doc != null) {
      /// extract text to update record
      titleController.text = doc['title'];
      descriptionController.text = doc['description'];
    } else {
      /// refresh texts add record
      titleController.text = "";
      descriptionController.text = "";
    }
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(doc != null ? 'Edit Record' : 'Add Record'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(labelText: "First Name"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: descriptionController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(labelText: "Last Name"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text('Save'),
                onPressed: () {
                  if (doc != null) {
                    /// update existing record
                    updateRecord(doc.documentID);
                  } else {
                    /// create new record
                    createRecord();
                  }
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }


  void confirmDeleteDialog(BuildContext context,String documentID) async {

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Record'),
            content: SingleChildScrollView(
              child: Column(
                children: [

                  SizedBox(
                    height: 10,
                  ),
                  Text('Are you sure you want to remove this record. All the data pertaining to this record will be lost. Continue?'),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text('Yes'),
                onPressed: () {
                  /// delete record
                  deleteRecord(documentID);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
