import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FlutterMapMarkersDemo());
}

class FlutterMapMarkersDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapsDemo(title: 'Flutter Map Markers Demo'),
    );
  }
}

class MapsDemo extends StatefulWidget {
  MapsDemo({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MapsDemoState createState() => _MapsDemoState();
}

// Class which parse the data from database
class Marker {
  String country;
  late double latitude;
  late double longitude;

  Marker(
      {required this.country, required this.latitude, required this.longitude});

  Marker.fromJson(this.country, Map data) {
    latitude = data['latitude'];
    longitude = data['longitude'];
  }
}

class _MapsDemoState extends State<MapsDemo> {
  late MapShapeSource _dataSource;
  late List<Marker> _markers;

  @override
  void initState() {
    _markers = <Marker>[];
    //Load the data soucre
    _dataSource = MapShapeSource.asset(
      'assets/world_map.json',
    );

    super.initState();
  }

  // Get the markers from database to a local collection
  Future<List<Marker>> getMarkers() async {
    var _dbRef = FirebaseDatabase.instance.reference().once();
    _markers.clear();

    await _dbRef.then(
      (dataSnapShot) async {
        // Access the markers from database
        Map<dynamic, dynamic> mapMarkers = dataSnapShot.value;

        // Get the markers in a local collection
        mapMarkers.forEach(
          (key, value) {
            Marker marker = Marker.fromJson(key, value);
            _markers.add(Marker(
                country: key,
                latitude: double.parse(marker.latitude.toString()),
                longitude: double.parse(marker.longitude.toString())));
          },
        );
      },
    );
    return _markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(8),
          //Get the markers as collection and update the Maps
          child: FutureBuilder(
            future: getMarkers(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SfMaps(
                  layers: <MapLayer>[
                    MapShapeLayer(
                      source: _dataSource,
                      initialMarkersCount: _markers.length,
                      markerBuilder: (BuildContext context, int index) {
                        return MapMarker(
                          latitude: _markers[index].latitude,
                          longitude: _markers[index].longitude,
                        );
                      },
                    ),
                  ],
                );
              }
              return Text('Loading');
            },
          ),
        ),
      ),
    );
  }
}
