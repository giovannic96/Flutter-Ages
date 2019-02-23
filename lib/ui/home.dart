import 'package:ages/ui/ages_screen.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Ages", 
                    style: new TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600
        ),),
        backgroundColor: Colors.red,
      ),
      body: new AgesScreen(),
    );
  }
}