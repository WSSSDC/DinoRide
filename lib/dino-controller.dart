import 'package:prehistoric/main.dart';

class DinoController {
  static List<Map<String, dynamic>> dinos = [];
  static Duration speed = Duration(seconds: 100);

  static int ms = 200;
  static Stream<List<Map<String, dynamic>>> get stream => Stream<List<Map<String, dynamic>>>.periodic(Duration(milliseconds: ms), (x) => updateDinos(x));

  static List<Map<String, dynamic>> updateDinos(int x) {
    List<Map<String, dynamic>> updatedDinos = [];
    for (Map<String, dynamic> dino in dinos) {
      double val = (x / (speed.inMilliseconds / ms / speed.inSeconds)) % speed.inSeconds.toDouble();
      val /= 10;
      dino['currentNode'] = toMap(val, dino);
      updatedDinos.add(dino);
    }
    return updatedDinos;
  }

  static toMap(double val, Map<String, dynamic> map) {
    List<Node> nodes = map['nodes'];
    List<double> nodesX = nodes.map((node) => node.longitude).toList();
    List<double> nodesY = nodes.map((node) => node.latitude).toList();

    double baseX = nodesX[val.toInt()];
    double baseY = nodesY[val.toInt()];
    double diff = val - val.toInt();
    
    double nextValX = val.toInt() >= nodesX.length ? nodesX[0] : nodesX[val.toInt() + 1];
    double nextValY = val.toInt() >= nodesY.length ? nodesY[0] : nodesY[val.toInt() + 1];
    double diffValX = (nextValX - baseX) * diff;
    double diffValY = (nextValY - baseY) * diff;
    return Node()..longitude=baseX+diffValX..latitude=baseY+diffValY;
  }
}