import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _origin =  //aqui va los datos de inicio de tu ruta
  Location(name: "Trabajo", latitude: 42.886448, longitude: -78.878372);
  final _destination = Location(  //aqui van los datos de destino
      name: "Casa", latitude: 42.8866177, longitude: -78.8814924);

  MapboxNavigation _directions;
  bool _arrived = false;
  double _distanceRemaining, _durationRemaining;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {

    if (!mounted) return;

    _directions = MapboxNavigation(onRouteProgress: (arrived) async {
      _distanceRemaining = await _directions.distanceRemaining;
      _durationRemaining = await _directions.durationRemaining;

      setState(() {
        _arrived = arrived;
      });
      if (arrived)
      {
        await Future.delayed(Duration(seconds: 3));
        await _directions.finishNavigation();
      }
    });

    String platformVersion;
    try {
      platformVersion = await _directions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ejemplo de mapbox navigation'),
        ),
        body: Center(
          child: Column(children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Text('Running on: $_platformVersion\n'),
            SizedBox(
              height: 60,
            ),
            RaisedButton(
              child: Text("Iniciar navegacion"),
              onPressed: () async {
                await _directions.startNavigation(
                    origin: _origin,
                    destination: _destination,
                    mode: NavigationMode.drivingWithTraffic,
                    simulateRoute: true, language: "Spanish", units: VoiceUnits.metric);
              },
            ),
            SizedBox(
              height: 60,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text("Distance Remaining: "),
                      Text(_distanceRemaining != null
                          ? "${(_distanceRemaining * 0.000621371).toStringAsFixed(1)} miles"
                          : "---")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text("Duration Remaining: "),
                      Text(_durationRemaining != null
                          ? "${(_durationRemaining / 60).toStringAsFixed(0)} minutes"
                          : "---")
                    ],
                  )
                ],
              ),
            ),

          ]),
        ),
      ),
    );
  }
}

