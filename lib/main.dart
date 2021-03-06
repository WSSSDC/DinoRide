import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:prehistoric/dino-controller.dart';
import 'package:prehistoric/location-controller.dart';
import 'package:prehistoric/map-data.dart';
import 'dart:ui' as ui;
import 'package:prehistoric/navigate.dart';

double zoomx = 0.004;
double zoomy = 0.004;
double currentLon = -122.032;
double currentLat = 37.3317;
double expansion = 250000;
LocationData location;
var rng = new Random();
List<String> imagenames = ['dinolux-50.png', 'dino-50.png', 'dinox-50.png', 'dinocopter-50.png', 'caveman.png'];
List<String> rockimagenames = ['rock.png', 'rock2.png', 'rock3.png'];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'UberMove',
      ),
      debugShowCheckedModeBanner: false,
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
  List<ui.Image> _images = [];

  @override
  void initState() {
    DinoController.stream;
    imagenames.forEach((e) => _loadImage("images/" + e));
    getLocation();
    super.initState();
  }

  _loadImage(String asset) async {
    ByteData bd = await rootBundle.load(asset);
    final Uint8List bytes = Uint8List.view(bd.buffer);
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.Image image = (await codec.getNextFrame()).image;
    setState(() => _images.add(image));
  }

  getLocation() async {
    print("Getting Location...");
    location = await LocationController.getLocation();
    print("Location Received");
    currentLon = location.longitude + (-250/expansion);
    currentLat = location.latitude + (-400/expansion);
    print("Getting Map Data...");
    Map<String, dynamic> map = Map<String, dynamic>.from(await OSM.getData(left:location.longitude - zoomx, right:location.longitude + zoomx, bottom:location.latitude - zoomy, top:location.latitude + zoomy));
    
    print("Map Data Received");
    var waysData = map['elements'].where((e) => e['type']=='way');
    // waysData.toList().forEach((e) => print(e['tags']));
    ways = [];
    print("Generating Map...");
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
      return Way.fromData(e, nodes);
    }).toList());


    ways.sort((a,b) => layerFromID(a.id).compareTo(layerFromID(b.id)));

    print("Generated Map");
    setState(() => ways);
  }

  int layerFromID(String id) {
    switch (id) {
      case 'building':
        return 5;
      case 'land':
        return 3;
      case 'road':
        return 2;
    }
    return 1;
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
      body: Container(
        width: width,
        height: height,
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
              child: Image(
                image: AssetImage('images/road.jpg'),
                fit: BoxFit.fill,
                repeat: ImageRepeat.repeat,
                alignment: FractionalOffset(currentLon.abs() * -250, currentLat.abs() * -expansion * 0.01),
              ),
            )] + List<Widget>.from(ways.map((way) {
            if (way.id == 'land') {
              return ClipPath(
                child: SizedBox.expand(
                  child: Image(
                    image: AssetImage('images/grass.jpg'),
                    repeat: ImageRepeat.repeat,
                    alignment: FractionalOffset(currentLon.abs() * -250, currentLat.abs() * -expansion * 0.0015),
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                clipper: Clipper(way),
              );
            } else if (way.id == 'building') {
              return Container(
                child: Align(
                  alignment: FractionalOffset(((way.avg.longitude - currentLon) * expansion) / (width - 100) - 0.15, ((way.avg.latitude - currentLat) * expansion) / (height - 100) - 0.08),
                  child: Image.asset('images/' + way.rock, width: way.size * 10, height: way.size * 10,),
                ),
              );
            }
            return Container(color: Colors.transparent);
          }).toList()) + <Widget>[
            Container(
              width: width,
              height: height,
              child: CustomPaint(
                painter: MapPainter(ways, location, _images.length >= 5 ? _images[4] : null),
              ),
            ),
            Container(
              width: width,
              height: height,
              child: CustomPaint(
                painter: DinoPainter(DinoController.dinos ?? [], _images),
              ),
            ),
            GestureDetector(
              onPanUpdate: (v) {
                setState(() {
                  currentLon -= v.delta.dx / 250000;
                  currentLat -= v.delta.dy / 250000;                
                });
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigation),
        backgroundColor: Colors.black,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => Navigate()));
        },
      ),
    );
  }
}

double distance(x1, x2, y1, y2) {
  return ((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1));
}

class Node {
  double longitude = 0.0;
  double latitude = 0.0;
}

class Way {
  dynamic tags;
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

  Color color = Colors.transparent;

  Node avg = Node();
  double size = 0.0;

  String rock = 'images/rock.png';

  Way();

  Way.fromData(data, List<Node> nodes) {
    this.nodes = nodes;
    
    this.avg.longitude = nodes.map((e) => e.longitude).reduce((a, b) => a + b) / nodes.length;
    this.avg.latitude = nodes.map((e) => e.latitude).reduce((a, b) => a + b) / nodes.length;
    
    this.size = nodes.map((e) => Offset(e.longitude, e.latitude)).map((e) => (e - Offset(this.avg.longitude, this.avg.latitude)).distanceSquared).reduce(max) * expansion * 500;
    this.size = (min(this.size, 10));

    this.rock = rockimagenames[rng.nextInt(rockimagenames.length)];

    this.color = Colors.transparent;
    if(data.containsKey('tags')) {
      if (data['tags'].containsKey('highway')) {
        this.id = 'road';
        if(data['tags']['highway'] == 'footway') {
          this.id = 'sidewalk';
        } else {
          this.color = Colors.grey.withOpacity(0.8);
          
          if(rng.nextInt(10) % 5 == 0) {
            DinoController.dinos.add({
              'currentNode': nodes.first,
              'nodes': nodes,
              'nextNode': nodes[1] ?? nodes.first,
              'image': rng.nextInt(4)
            });
          }
        }
      } else if (data['tags'].containsKey('building')) {
        this.id = 'building';
      } else if (data['tags'].containsKey('landuse')) {
        this.id = 'land';
      }
    }
  }
}

class Clipper extends CustomClipper<Path> {
  Clipper(this.way);
  final Way way;

  @override
  Path getClip(Size size) {
    List<Offset> points = List<Offset>.from(way.nodes.map((node) => Offset((node.longitude - currentLon) * expansion, (node.latitude - currentLat) * expansion)).toList());
    Path path = Path();
    for (Offset point in points) {
      path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldDelegate) => true;
}

class MapPainter extends CustomPainter {
  MapPainter(this.ways, this.location, this.image);
  final List<Way> ways;
  final LocationData location;
  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.translate(0, 0);
    // canvas.drawImage(image, Offset.zero, Paint());
    
    //canvas.rotate(-1.57079633);

    for (Way way in ways) {
      List<Offset> points = List<Offset>.from(way.nodes.map((node) => Offset((node.longitude - currentLon) * expansion, (node.latitude - currentLat) * expansion)).toList());
      if (!way.filled) {
        canvas.drawPoints(
          ui.PointMode.polygon,
          points, 
          Paint()..strokeWidth=6..color=way.color
        );
      }
    }

    if(location != null) {
      Offset locationOffset = Offset((location.longitude - currentLon) * expansion, (location.latitude - currentLat) * expansion);
      canvas.drawCircle(
        locationOffset,
        11,
        Paint()..strokeWidth=3..color=Colors.white
      );
      canvas.drawCircle(
        locationOffset, 
        8,
        Paint()..strokeWidth=3..color=Colors.blueAccent
      );
      // canvas.drawImage(image, locationOffset, Paint());
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DinoPainter extends CustomPainter {
  DinoPainter(this.dinos, this.images);
  final List<Map<String, dynamic>> dinos;
  final List<ui.Image> images;

  @override
  void paint(Canvas canvas, Size size) {

    (dinos ?? []).forEach((entry){
      Node node = entry['currentNode'];
      var point = Offset((node.longitude - currentLon) * expansion - 25, (node.latitude - currentLat) * expansion - 25);
      canvas.drawImage(images[entry['image']], point, Paint());
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}