import 'dart:developer';

import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void _backgroundCallback() {
  BackgroundLocationTrackerManager.handleBackgroundUpdated((data) async {
    log('lat: ${data.lat}, long: ${data.lon}');
  });
}

Future<void> _initializeBackgroundLocationTracker() {
  return BackgroundLocationTrackerManager.initialize(
    _backgroundCallback,
    config: const BackgroundLocationTrackerConfig(
      androidConfig: AndroidConfig(
        channelName: 'flutter_background_location_tracker',
        notificationBody: 'Running in the background',
      ),
      loggingEnabled: true,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeBackgroundLocationTracker();

  try {
    await FMTCObjectBoxBackend().initialise();
  } catch (e, s) {
    log('Error initialising FMTCObjectBoxBackend', error: e, stackTrace: s);
  }

  runApp(const AppWidget());
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: const FlutterMapScreen(),
    );
  }
}

class FlutterMapScreen extends StatefulWidget {
  const FlutterMapScreen({super.key});

  @override
  State<FlutterMapScreen> createState() => _FlutterMapScreenState();
}

class _FlutterMapScreenState extends State<FlutterMapScreen> {
  final _fmtcStore = const FMTCStore('example');
  var _isTracking = false;
  var _isReady = false;

  void _handleIsTracking(bool newValue) {
    if (mounted) setState(() => _isTracking = newValue);
  }

  void _handleIsReady(bool newValue) {
    if (mounted) setState(() => _isReady = newValue);
  }

  void _initIsTracking() {
    BackgroundLocationTrackerManager.isTracking().then(_handleIsTracking);
  }

  void _toggleBackgroundTracking() {
    _isTracking
        ? BackgroundLocationTrackerManager.stopTracking()
        : BackgroundLocationTrackerManager.startTracking();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isTracking
              ? 'Background location tracking stopped'
              : 'Background location tracking started',
        ),
      ),
    );

    _handleIsTracking(!_isTracking);
  }

  void _requestPermissions() {
    Permission.locationWhenInUse.request().whenComplete(() {
      Permission.locationAlways.request();
    });
  }

  void _tryCreateStore() {
    _fmtcStore.manage.ready.then((exists) {
      if (!exists) {
        _fmtcStore.manage.create().whenComplete(() => _handleIsReady(true));
      } else {
        _handleIsReady(true);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initIsTracking();
    _tryCreateStore();
    _requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: const MapOptions(),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.fmtc_with_background',
            tileProvider: _isReady ? _fmtcStore.getTileProvider() : null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleBackgroundTracking,
        child: Icon(
          _isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
        ),
      ),
    );
  }
}
