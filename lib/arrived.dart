import 'package:flutter/material.dart';

class Arrived extends StatefulWidget {
  const Arrived({ Key key, this.dinoName, this.locationName}) : super(key: key);
  final String locationName;
  final String dinoName;

  @override
  _ArrivedState createState() => _ArrivedState();
}

class _ArrivedState extends State<Arrived> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your " + (this.widget.dinoName ?? "dino") + " has arrived!", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
              Expanded(
                child: Center(
                  child: Icon(Icons.check, size: 100)
                )
              ),
              Text("Your " + (this.widget.dinoName ?? "dino") + " is on its way", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.transparent)),
            ],
          ),
        ),
      ),
    );
  }
}