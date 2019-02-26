import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ages/util/database_client.dart';

class FormUpdateDialog extends StatefulWidget {
  static _FormUpdateDialogState of(BuildContext context) => context.ancestorStateOfType(const TypeMatcher<_FormUpdateDialogState>());

  @override
  _FormUpdateDialogState createState() => new _FormUpdateDialogState();
}

class _FormUpdateDialogState extends State<FormUpdateDialog> {

  final TextEditingController _textEditingCtrl = new TextEditingController();
  var db = new DatabaseHelper();

  bool _validateName = false;
  bool _validateDate = false;

  DateTime _birthDate;
  String _modifiedName;

  void _displayErrorMessage() {
   showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Errore"),
          content: new Text("Inserire Data di nascita"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
      title: new Text("Modifica dati"),
      content: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new SizedBox(
            height: 20.0,
          ),
          new TextField(
            autofocus: false,
            autocorrect: false,
            controller: _textEditingCtrl,
            decoration: new InputDecoration(
              suffixIcon: new Icon(Icons.person_add),
              labelText: "Nome",
              errorText: _validateName ? "Inserire un nome valido" : null,
              counterText: ""
            ),
            maxLength: 40,
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
            onPressed: () {
              setState(() {
                _modifiedName = _textEditingCtrl.text;
                _modifiedName = _modifiedName.replaceFirst(new RegExp(r"^\s+"), "");  // trims leading whitespace
                _modifiedName = _modifiedName.replaceFirst(new RegExp(r"\s+$"), "");  // trims trailing whitespace

                _modifiedName.isEmpty ? _validateName = true : _validateName = false;
                this._birthDate == null ? _validateDate = true :_validateDate = false;
              });
              if (!_validateName) {
                if(!_validateDate) {
                  _textEditingCtrl.clear();
                  Navigator.pop(context, [_modifiedName, _birthDate]);
                } else {                  
                  _displayErrorMessage();
                }
              } 
            },
            child: Text("Salva")
        ),
      ],
      );
    }
}