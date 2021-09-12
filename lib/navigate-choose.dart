import 'package:flutter/material.dart';
import 'package:prehistoric/waiting.dart';

class NavigateChoose extends StatefulWidget {
  const NavigateChoose({ Key key, this.name }) : super(key: key);
  final String name;

  @override
  _NavigateChooseState createState() => _NavigateChooseState();
}

class _NavigateChooseState extends State<NavigateChoose> {
  String selectedDino = "DinoX";

  void select(String newDino) {
    setState(() => selectedDino = newDino);
  }

  String get cost{
    switch (selectedDino) {
      case 'DinoX':
        return '5';
      case 'Dino Green':
        return '8';
      case 'Dino Lux':
        return '69';
      case 'Dino Copter':
        return '420';
    }
    return '5';
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
              Text("Navigate To " + this.widget.name, style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
              Container(height: 20),
              NavigationCard(name: "DinoX", image: 'images/dinox.png', desc: 'Affordable rides whenever you need them.', selected: selectedDino == 'DinoX', selectDino: select),
              NavigationCard(name: "Dino Green", image: 'images/dino.png', desc: 'Help preserve the earth with a herbivore.', selected: selectedDino == 'Dino Green', selectDino: select),
              NavigationCard(name: "Dino Lux", image: 'images/dinolux2.png', desc: 'Ride on top of our most comfortable dinos and have a pleasant experience.', selected: selectedDino == 'Dino Lux', selectDino: select),
              NavigationCard(name: "Dino Copter", image: 'images/dinocopter.png', desc: 'Avoid traffic by soaring across the sky on a majestic Pterodactyl.', selected: selectedDino == 'Dino Copter', selectDino: select),
              Expanded(child: Container()),
                Container(
                  height: 50,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => Waiting(dinoName: selectedDino)));
                    },
                    child: Center(child: Text("PAY " + cost + " ROCKS", style: TextStyle(
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
  const NavigationCard({ Key key, this.name, this.image, this.desc, this.selected, this.selectDino}) : super(key: key);
  final String name;
  final String desc;
  final String image;
  final bool selected;
  final Function selectDino;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        this.selectDino(name);
      },
      child: Container(
        margin: EdgeInsets.only(top: 5, bottom: 5),
        height: 115,
        child: Center(
          child: Row(
            children: [
              Container(width: 15),
              SizedBox(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 15),
                    Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black)),
                    Container(height: 2),
                    Text(desc, style: TextStyle(color: selected ? Colors.white : Colors.black)),
                  ],
                ),
              ),
              Spacer(flex: 4),
              Image.asset(image),
              Container(width: 15),
            ],
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