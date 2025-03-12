import 'package:flutter/material.dart';
import 'package:map4d_map/map4d_map.dart';
import 'package:map4d_services/map4d_services.dart';
import './directions_to_routes.dart';

class RoutesDirections extends StatefulWidget {
  const RoutesDirections({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoutesDirectionsState();
}

class _RoutesDirectionsState extends State<RoutesDirections> {
  late MFMapViewController _controller;
  final List<MFLocationComponent> _locations = <MFLocationComponent>[];

  late MFMarker targetMarker;
  late MFMarkerId targetMarkerId;
  MFBitmap? _targetMarkerIcon;

  int _markerIdCounter = 0;
  Map<MFMarkerId, MFMarker> markers = <MFMarkerId, MFMarker>{};

  MFDirectionsRenderer? _directionsRenderer;

  Future<void> _addLocation() async {
    final camera = (await _controller.getCameraPosition())!;
    final target = camera.target;

    _markerIdCounter++;
    final MFMarkerId markerId = MFMarkerId('marker_id_$_markerIdCounter');

    final MFMarker marker = MFMarker(
      markerId: markerId,
      position: target,
    );
    setState(() {
      markers[markerId] = marker;
      _locations.add(MFLocationComponent(
          latitude: target.latitude, longitude: target.longitude));
    });
  }

  void _getDirections() async {
    final origin = _locations.first;
    final destination = _locations.last;
    final waypoints = _locations.sublist(1, _locations.length - 1);
    try {
      final directions = await MFServices.routes.fetchDirections(
          origin, destination,
          waypoints: waypoints.isNotEmpty ? waypoints : null);
      final routes = routesFromDirections(directions);
      final directionsRenderer = MFDirectionsRenderer(
        rendererId: const MFDirectionsRendererId('renderer_id'),
        routes: routes,
        activedIndex: 1,
        originPOIOptions: MFDirectionsPOIOptions(
            position: MFLatLng(origin.latitude, origin.longitude)),
        destinationPOIOptions: MFDirectionsPOIOptions(
            position: MFLatLng(destination.latitude, destination.longitude)),
      );
      setState(() {
        markers.clear();
        _directionsRenderer = directionsRenderer;
      });
    } on MFServiceError catch (error) {
      print('Directions Error: ${error.code}, ${error.message}');
    }
  }

  void _onCameraMove(MFCameraPosition camera) {
    targetMarker = targetMarker.copyWith(positionParam: camera.target);
    setState(() {
      markers[targetMarkerId] = targetMarker;
    });
  }

  void _onMapCreated(MFMapViewController controller) {
    _controller = controller;
    setState(() {
      markers[targetMarkerId] = targetMarker;
    });
  }

  @override
  Widget build(BuildContext context) {
    _createMarkerImageFromAsset(context);
    Set<MFDirectionsRenderer> renderers = <MFDirectionsRenderer>{
      if (_directionsRenderer != null) _directionsRenderer!
    };
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          MFMapView(
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            markers: Set<MFMarker>.of(markers.values),
            directionsRenderers: renderers,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            FloatingActionButton(
              onPressed: _addLocation,
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: _locations.length > 1 ? _getDirections : null,
              child: const Icon(Icons.account_tree),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_targetMarkerIcon == null) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size.square(48));
      _targetMarkerIcon = await MFBitmap.fromAssetImage(
          imageConfiguration, 'assets/target.png');

      targetMarkerId = const MFMarkerId('target_marker');
      targetMarker = MFMarker(
        markerId: targetMarkerId,
        icon: _targetMarkerIcon!,
        zIndex: 10,
      );
    }
  }
}
