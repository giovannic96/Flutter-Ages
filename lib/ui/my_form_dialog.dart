import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ages/model/ages_item.dart';
import 'package:ages/util/database_client.dart';
import 'package:ages/util/formatter.dart';

class MyFormDialog extends StatefulWidget {
  static _MyFormDialogState of(BuildContext context) => context.ancestorStateOfType(const TypeMatcher<_MyFormDialogState>());

  @override
  _MyFormDialogState createState() => new _MyFormDialogState();
}

class _MyFormDialogState extends State<MyFormDialog> {

  final TextEditingController _textEditingCtrl = new TextEditingController();
  var db = new DatabaseHelper();
  DateTime _birthDate;
  AgesItem _addedItem;

  Future<AgesItem> _handleSubmitted(String text, DateTime birthDate) async { 
    _textEditingCtrl.clear(); // clear text
    AgesItem agesItem = new AgesItem(text, dateFormatted(), dateBirthFormatted(birthDate)); // create item
    int savedItemId = await db.saveItem(agesItem); // retrieve itemId

    AgesItem addedItem = await db.getItem(savedItemId); // get item by its id from the db
    setState(() {
     _addedItem = addedItem; 
    });
    print("Item '${addedItem.itemName}' saved with id: $savedItemId");
  }

  Future<Null> _setBirthDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      locale: Localizations.localeOf(context),
      initialDate: new DateTime.now(),
      firstDate: new DateTime(1900),
      lastDate: new DateTime.now()
    );

    if(picked != null) {
      print("Date selected: ${picked.toString()}");
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: new Text("Inserisci dati"),
      content: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new SizedBox(
            height: 20.0,
          ),
          new TextField(
            autofocus: false,
            controller: _textEditingCtrl,
            decoration: new InputDecoration(
              suffixIcon: new Icon(Icons.person_add),
              labelText: "Nome",
            ),
          ),
          new SizedBox(
            height: 20.0,
          ),
          new InkWell(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(_birthDate != null ? _birthDate.day.toString() + "-" + _birthDate.month.toString() + "-" +
                    _birthDate.year.toString() : "Data di nascita",
                    textAlign: TextAlign.start,
                    style: new TextStyle(
                      color: Colors.grey[600],
                      letterSpacing: 0.2)),
                  Container(
                    padding: EdgeInsets.only(right: 11.5),
                    child: Icon(Icons.event, color: Colors.grey[600])
                  )
                ],
              )
            ),
            onTap: () {
              _setBirthDate(context);
              FocusScope.of(context).requestFocus(new FocusNode());
            }
          )
          ],
        ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
              _textEditingCtrl.clear();
            },
            child: Text("Annulla")),
        new FlatButton(
            onPressed: () async {
              var nameItem = _textEditingCtrl.text;
              await _handleSubmitted(nameItem, _birthDate);
              _textEditingCtrl.clear();
              Navigator.pop(context, _addedItem);
            },
            child: Text("Salva")
        ),
      ],
      );
    }
}