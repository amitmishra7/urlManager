
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_demo/pages/add_edit_record_page.dart';
import 'package:firestore_demo/pages/record_details.dart';
import 'package:firestore_demo/pages/records_list.dart';
import 'package:flutter/material.dart';


class RecordsTabPage extends StatefulWidget {
  String collectionName;

  RecordsTabPage({this.collectionName});

  @override
  _RecordsTabPageState createState() => _RecordsTabPageState();
}

class _RecordsTabPageState extends State<RecordsTabPage> {
  Firestore fireStoreDataBase = Firestore.instance;
  List<DocumentSnapshot> documents;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            leading: InkWell(child: Padding(
              padding: const EdgeInsets.only(left : 12),
              child: Icon(Icons.arrow_back_ios,),
            ),onTap: (){
              Navigator.pop(context);
            },),
            actions: [
              InkWell(child: Padding(
                padding: const EdgeInsets.only(right : 12),
                child: Icon(Icons.add,size: 30,),
              ),onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddEditRecordPage(collectionName : widget.collectionName),
                  ),
                );
              },)
            ],
            bottom: TabBar(
              tabs: [
                Tab(text: 'All'),
                Tab(text: 'Watchlist'),
                Tab(text: 'Watched'),
                Tab(text: 'Favorites'),
              ],
            ),
            title: Text(widget.collectionName),
          ),
          body: TabBarView(
            children: [
              RecordListPage(collectionName:widget.collectionName,type: "All",),
              RecordListPage(collectionName:widget.collectionName,type: "Watchlist",),
              RecordListPage(collectionName:widget.collectionName,type: "Watched",),
              RecordListPage(collectionName:widget.collectionName,type: "Favorite",),

            ],
          ),
        ),
      ),
    );
  }
}
