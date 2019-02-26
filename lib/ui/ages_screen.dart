import 'package:ages/model/ages_item.dart';
import 'package:ages/util/database_client.dart';
import 'package:ages/util/formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ages/ui/form_insert_dialog.dart';
import 'package:ages/ui/form_update_dialog.dart';

class AgesScreen extends StatefulWidget {
  @override
  _AgesScreenState createState() => _AgesScreenState();
}

class _AgesScreenState extends State<AgesScreen> with SingleTickerProviderStateMixin {

  final TextEditingController _textEditingController = new TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SlidableController _slidableController = new SlidableController();

  bool _showFloatingBtn = true;
  var db = new DatabaseHelper();
  final List<AgesItem> _itemList = <AgesItem>[];
  final int _itemPerPage = 8;

  /* Colors */
  final Color _oddItemColor = Colors.grey[300];
  final Color _evenItemColor = Colors.grey[200];

  @override
  void initState() {
    _scrollController.addListener(scrollListener);
    super.initState();
    _readAgesList(); // read all items from db
  }

  @override 
  void dispose() {
    _textEditingController.dispose();
    _scrollController.removeListener(scrollListener);
    super.dispose();
  }

  void scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward || _itemList.length <= _itemPerPage)
      _showFloatingBtn = true;
    else
      _showFloatingBtn = false;
    setState(() {});
  }

  void _undo(String text, DateTime birthDate) async { 

    AgesItem agesItem = new AgesItem(text, dateFormatted(), dateBirthFormatted(birthDate)); // create item
    int savedItemId = await db.saveItem(agesItem); // retrieve itemId
   
    AgesItem addedItem = await db.getItem(savedItemId); // get item by its id from the db

    setState(() {   // in order to change the state of the widget by showing the list view
      _itemList.insert(0, addedItem);
      _itemList.sort((a, b) {
        return a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
      });
    });
    print("Item '${addedItem.itemName}' saved with id: $savedItemId");
  }

  @override
  Widget build(BuildContext context) {
      return new Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: _evenItemColor,
      body: new Column(
        children: <Widget>[
          new Flexible( // gives a flexibility to expand to fill the available space in the main axis (vertically in this case for column)
            child: new ListView.builder( // Creates a scrollable, linear array of widgets that are created on demand
                //padding: new EdgeInsets.only(top: 8.0, bottom: 8.0),
                controller: _scrollController,
                reverse: false,
                itemCount: _itemList.length,/*
                separatorBuilder: (BuildContext context, int index) => new Divider(   
                  indent: 0,
                  height: 0,
                  color: Colors.transparent,
                ),*/
                itemBuilder: (_, int index) { // '_' replaces 'context'
                  return new Slidable(
                    key: UniqueKey(),
                    controller: _slidableController,
                    delegate: new SlidableScrollDelegate(),
                    slideToDismissDelegate: new SlideToDismissDrawerDelegate(
                      //onDismissed: (actionType) {}
                    ),
                    actionExtentRatio: 0.25,
                    child: new Material( // 'Material' not 'Container' to preserve the splash effect when hit this ListTile
                      color: index % 2 == 0 ?_evenItemColor : _oddItemColor,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        title: _itemList[index],
                        leading: CircleAvatar(
                          maxRadius: 20,
                          child: Text(firstLastLetters(_itemList[index].itemName)),
                          backgroundColor: hexToColor(_itemList[index].avatarColor),
                          foregroundColor: Colors.white,
                        ),
                        onLongPress: () => _updateItem(_itemList[index], index),
                      ),
                    ),
                    secondaryActions: <Widget>[
                      new IconSlideAction(
                        caption: 'Rimuovi',
                        color: Colors.red,
                        icon: Icons.delete, 
                        onTap: () {
                          // Save old item variables in case of 'undo'
                          var oldName = _itemList[index].itemName;
                          var oldDateBirth = _itemList[index].dateBirth;

                          _deleteItem(_itemList[index].id, index);
                          Scaffold.of(context).removeCurrentSnackBar();
                          Scaffold.of(context).showSnackBar(new SnackBar(
                            content: new Text("'${_itemList[index].itemName}' rimosso dalla lista."), 
                            action: SnackBarAction(
                              label: 'Annulla',
                              onPressed: () => _undo(oldName, DateTime.parse(oldDateBirth))
                            ),
                            duration: const Duration(seconds: 2),
                          ),);
                        },
                      ),
                    ],
                  );
                }
            ),
          ),
        ],
      ),
      
      floatingActionButton: _showFloatingBtn ? FloatingActionButton(
          backgroundColor: Colors.orange, 
            child: new ListTile(
              title: new Icon(Icons.add),
            ),
          onPressed: () =>
            _showFormDialog()
          ,
      ) : Container(),
    );
  }

  _showFormDialog() {
    
    showDialog(
      context: context,
      builder: (_) {
        return FormInsertDialog();
      }).then((result) =>
        setState(() {  
          if(result != null) { // because we can tap outside form dialog and in this case result will be null
            _itemList.insert(0, result);
            _itemList.sort((a, b) {
              return a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
            });
            Scaffold.of(context).removeCurrentSnackBar();
            Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text("${result.itemName} aggiunto alla lista."), 
              duration: const Duration(seconds: 2),
            ),);
          }
      })
      );
  }

  _updateItem(AgesItem item, int index) {
    
    showDialog(
      context: context,
      builder: (_) {
        return FormUpdateDialog();
      }).then((result) async {
        if(result != null) { // because we can tap outside form dialog and in this case result will be null
          AgesItem newItemUpdated = AgesItem.fromMap(
            {
              "itemName": result[0], //result.text
              "dateCreated": dateFormatted(),
              "dateBirth": dateBirthFormatted(result[1]), //result.birthdate 
              "id": item.id,
              "avatarColor": item.avatarColor
            });

          setState(() {
            _itemList.removeWhere((element) {
            _itemList[index].itemName == item.itemName; // remove old item (the one we'are updating) from the list
            });
            _itemList.sort((a, b) {
              return a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
            });
          });

          await db.updateItem(newItemUpdated); // update our db with the new values
          
          setState(() {
            _readAgesList(); // redraw again the screen with all items saved (updated) in the db
            Scaffold.of(context).removeCurrentSnackBar();
            Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text("${newItemUpdated.itemName} modificato con successo."), 
              duration: const Duration(seconds: 2),
            ),);
          });
        }
      }
      );
  }

  _readAgesList() async {
    List items = await db.getItems();
    items.forEach((item) {
      setState(() { // change the state of the widget by uploading items from the db
        _itemList.add(AgesItem.map(item));
        _itemList.sort((a, b) {
          return a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
        });
      });
    });
  }

  _deleteItem(int id, int index) async {
    debugPrint("Deleted item!");

    await db.deleteItem(id);
    setState(() { // refresh list view
      _itemList.removeAt(index);
      _itemList.sort((a, b) {
        return a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
      });
    });
  }
}