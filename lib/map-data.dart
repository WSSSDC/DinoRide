import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class OSM {
  static Future<dynamic> getData({double left, double right, double top, double bottom}) {
    String bbox = [left,bottom,right,top].map((e) => e.toStringAsFixed(3)).join(',');
    return http.get(
      Uri.parse('https://api.openstreetmap.org/api/0.6/map?bbox=' + bbox),
      headers: {
        HttpHeaders.acceptHeader: 'application/json'
      }
    ).then((http.Response response) => jsonDecode(response.body));
  }
}