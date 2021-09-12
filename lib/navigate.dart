import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:prehistoric/navigate-choose.dart';

class Navigate extends StatefulWidget {
  const Navigate({ Key key }) : super(key: key);

  @override
  _NavigateState createState() => _NavigateState();
}

class _NavigateState extends State<Navigate> {
  String selectedLocation = "Cave";

  void select(String newLocation) {
    setState(() => selectedLocation = newLocation);
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
              Text("Navigate", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
              Container(height: 20),
              NavigationCard(name: "Search", selected: selectedLocation == 'Search', selectLocation: select),
              NavigationCard(name: "Cave", selected: selectedLocation == 'Cave', selectLocation: select),
              NavigationCard(name: "Hut", selected: selectedLocation == 'Hut', selectLocation: select),
              NavigationCard(name: "River", selected: selectedLocation == 'River', selectLocation: select),
              NavigationCard(name: "Nearest Rock", selected: selectedLocation == 'Nearest Rock', selectLocation: select),
              Expanded(child: Container()),
              Container(
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => NavigateChoose(name: selectedLocation)));
                  },
                  child: Center(child: Text("NEXT", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                    color: Colors.white
                  ),)),
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 25,
                      blurRadius: 50
                    )
                  ]
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationCard extends StatelessWidget {
  const NavigationCard({ Key key, this.name, this.selected, this.selectLocation}) : super(key: key);
  final String name;
  final bool selected;
  final Function selectLocation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        this.selectLocation(name);
      },
      child: Container(
        margin: EdgeInsets.only(top: 5, bottom: 5),
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black)),
            ] + (name == "Search" ? [
              Expanded(child: Container()),
              Icon(Icons.search)
            ] : []),
          )
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: selected ? [] : [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 25,
              blurRadius: 50
            )
          ]
        ),
      ),
    );
  }
}