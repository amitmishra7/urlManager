
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';

class AddEditRecordPage extends StatefulWidget {
  String collectionName;
  DocumentSnapshot document;

  AddEditRecordPage({this.collectionName, this.document});

  @override
  _AddEditRecordPageState createState() => _AddEditRecordPageState();
}

class _AddEditRecordPageState extends State<AddEditRecordPage> {
  Firestore fireStoreDataBase = Firestore.instance;
  TextEditingController urlController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController previewController = TextEditingController();
  TextEditingController iconController = TextEditingController();
  TextEditingController otherInfoController = TextEditingController();

  List<DocumentSnapshot> documents;

  WebInfo webInfo;

  @override
  void initState() {
    setState(() {
      //urlController.text = "https://www.youtube.com/watch?v=0ZJLYx_hLxc";
      //urlController.text = "https://pub.dev/packages/cached_network_image/install";
      urlController.text = "https://www.youtube.com/watch?v=wKAg47kZxqU&t=1958s";
      if(widget.document!=null)
        {
          urlController.text = widget.document['url'];
          titleController.text = widget.document['title'];
          descriptionController.text = widget.document['description'];
          previewController.text = widget.document['image'];
          iconController.text = widget.document['icon'];
          otherInfoController.text = widget.document['otherInfo'];
        }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ' + widget.collectionName),
      ),
      body:
          buildBody(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              buildUrlField(),
              titleController.text!=null?buildItemInfo():Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUrlField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: urlController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(labelText: "Url"),
        ),
        ElevatedButton(
          child: Text('Fetch Info'),
          onPressed: () {
            getUrlInfo(urlController.text);
          },
        )
      ],
    );
  }

  Widget buildItemInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Text('Details'),
        SizedBox(
          height: 5,
        ),
        buildTitleField(),
        SizedBox(
          height: 5,
        ),
        buildDescriptionField(),
        SizedBox(
          height: 5,
        ),
        buildPreviewField(),
        SizedBox(
          height: 5,
        ),
        buildPreviewImage(),
        SizedBox(
          height: 5,
        ),
        buildIconField(),
        SizedBox(
          height: 5,
        ),
        buildIconImage(),
        SizedBox(
          height: 5,
        ),
        buildOtherInfoField(),
        SizedBox(
          height: 10,
        ),
        buildSubmitButton(),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget buildTitleField() {
    return TextField(
      controller: titleController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(labelText: "Title"),
    );
  }

  Widget buildDescriptionField() {
    return TextField(
      controller: descriptionController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(labelText: "Description"),
    );
  }

  Widget buildPreviewField() {
    return TextField(
      controller: previewController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(labelText: "Preview"),
    );
  }

  Widget buildPreviewImage() {
    return CachedNetworkImage(
      imageUrl: previewController.text,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  Widget buildOtherInfoField() {
    return TextField(
      controller: otherInfoController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(labelText: "Other Info"),
    );
  }

  Widget buildIconField() {
    return TextField(
      controller: iconController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(labelText: "Icon"),
    );
  }

  Widget buildSubmitButton(){
    return ElevatedButton(
        child: Text('Save Details'),
    onPressed: () {
          if(widget.document!=null){
            updateRecord();
          }else{
            createRecord();
          }
    });
  }

  Widget buildIconImage() {
    return CachedNetworkImage(
      imageUrl: iconController.text,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  Future<void> getUrlInfo(String _url) async {
    if (_url.startsWith("http")) {
      InfoBase _info = await WebAnalyzer.getInfo(
        _url,
      );

      webInfo = _info;
      setState(() {
        titleController.text = webInfo.title;
        descriptionController.text = webInfo.description;
        previewController.text = webInfo.image;
        iconController.text = webInfo.icon;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid Url. Does not begin with http.!!")));
    }
  }

  void createRecord() async {
    await fireStoreDataBase.collection(widget.collectionName).add({
      'title': titleController.text,
      'description': descriptionController.text,
      'image': previewController.text,
      'icon': iconController.text,
      'url' : urlController.text,
      'otherInfo' : otherInfoController.text,
      'watched' : false,
      'toWatch' : false,
      'favorite' : false
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Record Created..!!")));
    Navigator.pop(context);
  }

  void updateRecord() {
    try {
      fireStoreDataBase.collection(widget.collectionName).document(widget.document.documentID).updateData({
        'title': titleController.text,
        'description': descriptionController.text,
        'image': previewController.text,
        'icon': iconController.text,
        'url' : urlController.text,
        'otherInfo' : otherInfoController.text,
        'watched' : widget.document['watched'],
        'toWatch' : widget.document['toWatch'],
        'favorite' : widget.document['favorite'],
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Record Updated..!!")));
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
    }
  }
}
