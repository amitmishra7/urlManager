import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';

import 'add_edit_record_page.dart';

class RecordDetailsPage extends StatefulWidget {
  String collectionName;
  DocumentSnapshot document;

  RecordDetailsPage({this.collectionName, this.document});

  @override
  _RecordDetailsPageState createState() => _RecordDetailsPageState();
}

class _RecordDetailsPageState extends State<RecordDetailsPage> {
  DocumentSnapshot document;
  Firestore fireStoreDataBase = Firestore.instance;

  @override
  void initState() {
    document = widget.document;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Details'),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: onOptionsSelected,
              itemBuilder: (BuildContext context) {
                return {'Share','Copy', 'Update', 'Remove'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        // drawer: Drawer(),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 5.0,
                ),
                Container(
                    height: 300.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      shape: BoxShape.rectangle,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(document['image'])),
                    )),
                SizedBox(
                  height: 10.0,
                ),
                Text('Title'),
                Text(
                  document['title'],
                  style: TextStyle(
                      height: 1.4, fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text('Description'),
                Text(
                  document['description'],
                  maxLines: 2,
                  style: TextStyle(
                      height: 1.4, fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
                document['otherInfo'] != null
                    ? SizedBox(
                        height: 10.0,
                      )
                    : Container(),
                document['otherInfo'] != null
                    ? Text('Other Info')
                    : Container(),
                document['otherInfo'] != null
                    ? Text(
                        document['otherInfo'],
                        style: TextStyle(
                            height: 1.4,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      )
                    : Container(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          document['icon'] != null
                              ? SizedBox(
                                  height: 10.0,
                                )
                              : Container(),
                          document['icon'] != null
                              ? Text('Source')
                              : Container(),
                          document['icon'] != null
                              ? CachedNetworkImage(
                                  imageUrl: document['icon'],
                                  width: 30,
                                  height: 30,
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          updateFavorite(!document['favorite']);
                        },
                        child: document['favorite'] != null &&
                                document['favorite'] == true
                            ? Icon(
                                Icons.favorite,
                                color: Colors.pink,
                                size: 30,
                              )
                            : Icon(
                                Icons.favorite_border,
                                color: Colors.pink,
                                size: 30,
                              ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      child: Text(
                        document['toWatch']
                            ? 'Remove from Watchlist'
                            : 'Add to Watch List',
                      ),
                      onPressed: () {
                        updateToWatch(!document['toWatch']);
                      },
                    ),
                    ElevatedButton(
                      child: Text(
                        document['watched']
                            ? 'Remove from Watched List'
                            : 'Add to Watched',
                      ),
                      onPressed: () {
                        updateWatched(!document['watched']);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ));
  }

  void onOptionsSelected(String value) {
    switch (value) {
      case 'Share':
        shareURL();
        break;
        case 'Copy':
          copyUrl();
        break;
      case 'Update':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEditRecordPage(
              collectionName: widget.collectionName,
              document: widget.document,
            ),
          ),
        );
        break;
      case 'Remove':
        confirmDeleteDialog(context);
        break;
    }
  }

  void updateWatched(bool watched) {
    try {
      fireStoreDataBase
          .collection(widget.collectionName)
          .document(widget.document.documentID)
          .updateData({
        'title': widget.document['title'],
        'description': widget.document['description'],
        'image': widget.document['image'],
        'icon': widget.document['icon'],
        'url': widget.document['preview'],
        'otherInfo': widget.document['otherInfo'],
        'watched': watched,
        'toWatch': watched ? false : widget.document['toWatch'],
        'favorite': widget.document['favorite'],
        'url': widget.document['url'],
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              (watched ? "Added to" : "Removed from") + " to Watched..!!")));
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
    }
  }

  void updateToWatch(bool toWatch) {
    try {
      fireStoreDataBase
          .collection(widget.collectionName)
          .document(widget.document.documentID)
          .updateData({
        'title': widget.document['title'],
        'description': widget.document['description'],
        'image': widget.document['image'],
        'icon': widget.document['icon'],
        'url': widget.document['preview'],
        'otherInfo': widget.document['otherInfo'],
        'watched': toWatch ? false : widget.document['watched'],
        'toWatch': toWatch,
        'favorite': widget.document['favorite'],
        'url': widget.document['url'],
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              (toWatch ? "Added to" : "Removed from") + " Watchlist..!!")));
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
    }
  }

  void updateFavorite(bool favorite) {
    print('Amit favorite $favorite');
    try {
      fireStoreDataBase
          .collection(widget.collectionName)
          .document(widget.document.documentID)
          .updateData({
        'title': widget.document['title'],
        'description': widget.document['description'],
        'image': widget.document['image'],
        'icon': widget.document['icon'],
        'url': widget.document['preview'],
        'otherInfo': widget.document['otherInfo'],
        'watched': widget.document['watched'],
        'toWatch': widget.document['toWatch'],
        'favorite': favorite,
        'url': widget.document['url'],
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              (favorite ? "Added to" : "Removed from") + " Favorites..!!")));
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
    }
  }

  void confirmDeleteDialog(BuildContext context) async {
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
                  Text('Are you sure you want to remove this record..?'),
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
                  deleteRecord(widget.document.documentID);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void deleteRecord(String documentId) {
    try {
      fireStoreDataBase
          .collection(widget.collectionName)
          .document(documentId)
          .delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Record Deleted..!!")));
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
    }
  }

  void copyUrl(){
    Clipboard.setData(new ClipboardData(text: document['url']));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Url copied..!!")));
  }

  Future<void> shareURL() async {
    await FlutterShare.share(
        title: 'URL share',
        linkUrl: document['url'],
        chooserTitle: 'Share using.');
  }
}
