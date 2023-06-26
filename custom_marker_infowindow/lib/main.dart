import 'package:flutter/material.dart';
import 'package:map4d_map/map4d_map.dart';
import 'package:clippy_flutter/triangle.dart';
import 'package:get/get.dart';
import 'custom_info_window.dart';
import 'empty_page.dart';
import 'detail_page.dart';

void main() {
  // runApp(const MyApp());
  runApp(GetMaterialApp(
    initialRoute: "/",
    getPages: [
      GetPage(name: "/", page: () => const MyApp()),
      GetPage(name: "/empty", page: () => const EmptyPage()),
      GetPage(name: "/detail", page: () => const DetailPage()),
    ],
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map4D Custom Marker InfoWindow',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Custom InfoWindow'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MFMapViewController? controller;
  MFBitmap? _markerIcon;
  Map<MFMarkerId, MFMarker> markers = <MFMarkerId, MFMarker>{};

  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _createMarkerImageFromAsset(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: <Widget>[
            MFMapView(
                onMapCreated: _onMapCreated,
                onTap: (position) {
                  _customInfoWindowController.hideInfoWindow!();
                },
                onCameraMove: (position) {
                  _customInfoWindowController.onCameraMove!();
                },
                markers: Set<MFMarker>.of(markers.values)),
            CustomInfoWindow(
              controller: _customInfoWindowController,
              height: 75,
              width: 150,
              offset: 70,
            ),
          ],
        ));
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon != null) {
      return;
    }
    final ImageConfiguration imageConfiguration =
        createLocalImageConfiguration(context);
    _markerIcon =
        await MFBitmap.fromAssetImage(imageConfiguration, 'assets/shop.png');
  }

  void _onMapCreated(MFMapViewController controller) async {
    _customInfoWindowController.mapController = controller;
    final camera = (await controller.getCameraPosition())!;
    const markerId = MFMarkerId('marker_custom');
    final marker = MFMarker(
        consumeTapEvents: true,
        markerId: markerId,
        position: camera.target,
        anchor: const Offset(0.5, 1.0),
        icon: _markerIcon ?? MFBitmap.defaultIcon,
        onTap: () {
          _onMarkerTapped(markerId);
        });
    setState(() {
      markers[markerId] = marker;
    });
  }

  void _onPressedInfoWindowIcon(BuildContext context) {
    _customInfoWindowController.hideInfoWindow!();
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EmptyPage()));
    //
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    //Get.to(const EmptyPage());
    Get.toNamed("/detail", arguments: ["arg1"]);
  }

  void _onMarkerTapped(final MFMarkerId markerId) {
    final marker = markers[markerId];
    if (marker == null) {
      return;
    }
    _customInfoWindowController.addInfoWindow!(
      Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => _onPressedInfoWindowIcon(context),
                      icon: const Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    const Text("I am here"),
                  ],
                ),
              ),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Triangle.isosceles(
            edge: Edge.BOTTOM,
            child: Container(
              color: Colors.blue,
              width: 20.0,
              height: 10.0,
            ),
          ),
        ],
      ),
      marker.position,
    );
  }
}
