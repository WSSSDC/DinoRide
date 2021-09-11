import 'package:flutter/material.dart';

class Waiting extends StatefulWidget {
  const Waiting({ Key key, this.dinoName, this.locationName}) : super(key: key);
  final String locationName;
  final String dinoName;

  @override
  _WaitingState createState() => _WaitingState();
}

class _WaitingState extends State<Waiting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Thanks for your order", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
              Text("Your " + (this.widget.dinoName ?? "dino") + " is on it's way", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              Container(height: 100),
              Container(
                width: 500,
                height: 265,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                  image: DecorationImage(
                    image: AssetImage('images/loading.gif')
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}