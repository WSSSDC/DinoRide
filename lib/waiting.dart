import 'package:flutter/material.dart';
import 'arrived.dart';

class Waiting extends StatefulWidget {
  const Waiting({Key key, this.dinoName, this.locationName}) : super(key: key);
  final String locationName;
  final String dinoName;

  @override
  _WaitingState createState() => _WaitingState();
}

class _WaitingState extends State<Waiting> {
  @override
  void initState() {
    startCountdown();
    super.initState();
  }

  startCountdown() async {
    await Future.delayed(Duration(seconds: 5));
    Navigator.push(context, MaterialPageRoute(builder: (_) => Arrived()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Your " +
                      (this.widget.dinoName ?? "dino") +
                      " is on its way...",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
              Expanded(
                  child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      image: DecorationImage(
                          image: AssetImage('images/loading.gif'))),
                ),
              )),
              Text(
                  "Your " + (this.widget.dinoName ?? "dino") + " is on its way",
                  style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.transparent)),
            ],
          ),
        ),
      ),
    );
  }
}
