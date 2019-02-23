import 'package:flutter/material.dart';
import 'package:ages/util/formatter.dart';
import 'dart:math';

class AgesItem extends StatelessWidget {

  String _itemName;   // '_' before name means private variable
  String _dateCreated;
  String _dateBirth;
  int _id;
  String _avatarColor;

  static List<MaterialColor> _avatarColors = Colors.primaries;
  static Random _rand = new Random();

  AgesItem(this._itemName, this._dateCreated, this._dateBirth) 
    : _avatarColor = _getRandomColor();

  /* To set up internal fields (instance variables) to the object that we're getting -> we're mapping instance variables to the obj */
  AgesItem.map(dynamic obj) { // 'dynamic' because obj value can be of any type (String, List<Object>, int, and so on)
    this._itemName = obj["itemName"];
    this._dateCreated = obj["dateCreated"];
    this._dateBirth = obj["dateBirth"];
    this._id = obj["id"];
    this._avatarColor = obj["avatarColor"];
  }

  String get itemName => _itemName;
  String get dateCreated => _dateCreated;
  String get dateBirth => _dateBirth;
  int get id => _id;
  String get avatarColor => _avatarColor;
  
  static String _getRandomColor() {
    MaterialColor color = _avatarColors[_rand.nextInt(_avatarColors.length)];
    return stringToHex(color.toString());
  }

  _getAge () {
    var ageDifMs = DateTime.now().difference(DateTime.parse(_dateBirth)).inMilliseconds;
    var ageDate = new DateTime.fromMillisecondsSinceEpoch(ageDifMs); // miliseconds from epoch
    return (ageDate.year - 1970).abs();
  }

  _getSecondLetter() {
    return _getAge() == 1 ? "anno" : "anni";
  }

  /* To create (and return) a map of our instance variables */
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["itemName"] = _itemName;
    map["dateCreated"] = _dateCreated;
    map["dateBirth"] = _dateBirth;
    map["avatarColor"] = _avatarColor;

    if (_id != null) {
      map["id"] = _id;
    }
    return map;
  }

  /* Here instance variables are coming in as a map, and we're getting the value from the map with a certain key and setting our instance variables */
  AgesItem.fromMap(Map<String, dynamic> map) {
    this._itemName = map["itemName"];
    this._dateCreated = map["dateCreated"];
    this._dateBirth = map["dateBirth"];
    this._id = map["id"];
    this._avatarColor = map["avatarColor"];
  }

@override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: new Row(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(_itemName,
                            style: new TextStyle( 
                            color: Colors.black87,
                            fontSize: 22.5, 
                ),)
              ),
              Column(
                children: <Widget>[
                  Container(
                    child: Row(children: <Widget>[
                      new Text("${_getAge()}", style: new TextStyle(
                          color: Colors.black,
                          fontSize:  24,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold,
                        )),
                  ],),
                  ),
                  Container(
                    child: Row(children: <Widget>[
                      new Text("${_getSecondLetter()}", style: new TextStyle(
                          color: Colors.grey,
                          fontSize:  16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.normal
                        ), textAlign: TextAlign.start,),
                    ],),
                  )
              ],),
            ],
          ),
      );
  }
}
