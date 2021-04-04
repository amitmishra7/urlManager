import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_demo/pages/add_edit_record_page.dart';
import 'package:firestore_demo/pages/record_details.dart';
import 'package:flutter/material.dart';

class RecordListPage extends StatefulWidget {
  String collectionName;
  String type;

  RecordListPage({this.collectionName, this.type});

  @override
  _RecordListPageState createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  Firestore fireStoreDataBase = Firestore.instance;
  List<DocumentSnapshot> documents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.type == 'All'
            ? fireStoreDataBase.collection(widget.collectionName).snapshots()
            : widget.type == 'Watchlist'
                ? fireStoreDataBase
                    .collection(widget.collectionName)
                    .where('toWatch', isEqualTo: true)
                    .snapshots()
                : widget.type == 'Watched'
                    ? fireStoreDataBase
                        .collection(widget.collectionName)
                        .where('watched', isEqualTo: true)
                        .snapshots()
                    : fireStoreDataBase
                        .collection(widget.collectionName)
                        .where('favorite', isEqualTo: true)
                        .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            documents = snapshot.data.documents;
            return buildContactList();
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget buildContactList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: documents.map((doc) {
          return _buildRecordWidget(doc);
        }).toList(),
      ),
    );
  }

  Widget _buildRecordWidget(DocumentSnapshot doc) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecordDetailsPage(
                collectionName: widget.collectionName, document: doc),
          ),
        );
      },
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 90.0,
                    width: 120,
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      shape: BoxShape.rectangle,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(doc['image'])),
                    )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc['title'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              height: 1.4,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          doc['description'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        Text(
                          '${doc['watched']} ${doc['toWatch']} ${doc['favorite']}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Divider(
              color: Colors.grey,
            )
          ]),
    );
  }
}
