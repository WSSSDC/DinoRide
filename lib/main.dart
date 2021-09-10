import 'package:flutter/material.dart';
import 'package:prehistoric/location-controller.dart';
import 'package:prehistoric/map-data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
    void initState() {
      //getData();
      getLocation();
      super.initState();
    }

  getLocation() async {
    var location = await LocationController.getLocation();
    var map = await OSM.getData(left:location.longitude - 0.001, right:location.longitude + 0.001, bottom:location.latitude - 0.001, top:location.latitude + 0.001);
    print(map['elements'].where((e) => e['type']=='way').forEach((e) => print(e)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Lemme get them commits pls.',
            ),
          ],
        ),
      ),
    );
  }
}
