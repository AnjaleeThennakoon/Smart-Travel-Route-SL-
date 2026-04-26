import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class TripTrackerPage extends StatefulWidget {
  final String vehicleName;
  final double ratePerKm;
  final double baseFee;

  const TripTrackerPage({
    super.key, 
    required this.vehicleName, 
    required this.ratePerKm, 
    required this.baseFee
  });

  @override
  State<TripTrackerPage> createState() => _TripTrackerPageState();
}

class _TripTrackerPageState extends State<TripTrackerPage> {
  double _totalDistance = 0.0;
  double _currentFare = 0.0;
  Position? _lastPos;
  bool _isTracking = false;
  StreamSubscription<Position>? _stream;

  @override
  void initState() {
    super.initState();
    _currentFare = widget.baseFee;
  }

  void _start() async {
    LocationPermission perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied) return;

    setState(() => _isTracking = true);
    _stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((pos) {
      if (_lastPos != null) {
        double dist = Geolocator.distanceBetween(_lastPos!.latitude, _lastPos!.longitude, pos.latitude, pos.longitude);
        setState(() {
          _totalDistance += dist / 1000;
          _currentFare = widget.baseFee + (_totalDistance * widget.ratePerKm);
        });
      }
      _lastPos = pos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.vehicleName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("CURRENT FARE", style: GoogleFonts.poppins(color: Colors.grey)),
            Text("LKR ${_currentFare.toStringAsFixed(2)}", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("${_totalDistance.toStringAsFixed(2)} KM Covered"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isTracking ? null : _start,
              child: Text(_isTracking ? "Tracking Live..." : "Start Trip"),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() { _stream?.cancel(); super.dispose(); }
}