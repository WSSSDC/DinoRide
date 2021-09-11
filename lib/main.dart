import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:prehistoric/location-controller.dart';
import 'package:prehistoric/map-data.dart';
import 'dart:ui' as ui;

double zoomx = 0.004;
double zoomy = 0.008;
double currentLon = -122.032;
double currentLat = 37.3317;

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
  List<Way> ways = [];
  ui.Image image;

  @override
  void initState() {
    getLocation();
    init();
    super.initState();
  }

  Future <Null> init() async {
    final ByteData data = await rootBundle.load('images/road.jpg');
    image = await loadImage(new Uint8List.view(data.buffer));
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {});
      return completer.complete(img);
    });
    return completer.future;
  }


  getLocation() async {
    var location = await LocationController.getLocation();
    currentLon = location.longitude - zoomx;
    currentLat = location.latitude - zoomy;
    Map<String, dynamic> map = Map<String, dynamic>.from(await OSM.getData(left:location.longitude - zoomx, right:location.longitude + zoomx, bottom:location.latitude - zoomy, top:location.latitude + zoomy));
    var waysData = map['elements'].where((e) => e['type']=='way');
    // waysData.toList().forEach((e) => print(e['tags']));
    ways = List<Way>.from(waysData.map((e) {
      List<Node> nodes = [];
      for (int id in e['nodes']) {
        var nodeData = map['elements'].firstWhere((element) => element['id'] == id, orElse: (){});
        if(nodeData != null) {
          nodes.add(
            Node()
            ..longitude = nodeData['lon']
            ..latitude = nodeData['lat']
          );
        }
      }
      return Way()..nodes = nodes..id=idFromWayData(e)..closed=isWayClosed(e);
    }).toList());

    setState(() => ways);
  }

  String idFromWayData(data) {
    if(data.containsKey('tags')) {
      if (data['tags'].containsKey('highway')) {
        if(data['tags']['highway'] == 'footway') {
          return 'sidewalk';
        }
        return 'road';
      } else if (data['tags'].containsKey('building')) {
        return 'building';
      } else if (data['tags'].containsKey('landuse')) {
        return 'land';
      }
    }
    return '';
  }

  bool isWayClosed(data) {
    List<dynamic> nodes = data['nodes'];
    return nodes.first == nodes.last;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Container(
          width: width,
          height: height,
          child: CustomPaint(
            painter: MapPainter(ways, image),
          ),
        ),
      )
    );
  }
}

class MapPainter extends CustomPainter {
  MapPainter(this.ways, this.image);
  final List<Way> ways;
  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.translate(0, 0);
    canvas.drawColor(Colors.transparent, BlendMode.src);
    // canvas.drawImage(image, Offset.zero, Paint());
    
    //canvas.rotate(-1.57079633);

    for (Way way in ways) {
      List<Offset> points = List<Offset>.from(way.nodes.map((node) => Offset((node.longitude - currentLon) * 250000, (node.latitude - currentLat) * 250000)).toList());
      
      final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
          ui.ParagraphStyle(
            fontSize: 13,
            // fontFamily: style.fontFamily, 
            // fontStyle:  style.fontStyle,
            // fontWeight: style.fontWeight,
            textAlign: TextAlign.justify,
          )
        )..addText(way.id);
        final ui.Paragraph paragraph = paragraphBuilder.build(); 
      
      canvas.drawParagraph(paragraph, points.reduce((a,b) => a + (b / points.length.toDouble())));
      if (!way.filled) {
        canvas.drawPoints(
          ui.PointMode.polygon,
          points, 
          Paint()..strokeWidth=5..color=way.color
        );
      } else {
        Path path = Path();
        for (Offset point in points) {
          path.lineTo(point.dx, point.dy);
        }

        canvas.drawPath(
          path,
          Paint()..strokeWidth=5..color=way.color
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Node {
  double longitude = 0.0;
  double latitude = 0.0;
}

class Way {
  List<Node> nodes = [];
  bool closed = false;
  String id = '';
  bool get filled {
    switch(id) {
      case 'building':
        return true;
      case 'land':
        return true;
    }
    return false;
  }

  Color get color {
    switch(id) {
      case 'sidewalk':
        return Colors.transparent;
      case 'building':
        return Colors.black;
      case 'road':
        return Colors.transparent;
    }
    return Colors.green;
  }
}