import 'dart:io';
import 'package:flutter/material.dart';
import 'package:map4d_map/map4d_map.dart';

/// Controller to add, update and control the custom info window.
class CustomInfoWindowController {
  /// Add custom [Widget] and [MFMarker]'s [MFLatLng] to [CustomInfoWindow] and make it visible.
  Function(Widget, MFLatLng)? addInfoWindow;

  /// Notifies [CustomInfoWindow] to redraw as per change in position.
  VoidCallback? onCameraMove;

  /// Hides [CustomInfoWindow].
  VoidCallback? hideInfoWindow;

  /// Holds [mapController] for calculating [CustomInfoWindow] position.
  MFMapViewController? mapController;

  void dispose() {
    addInfoWindow = null;
    onCameraMove = null;
    hideInfoWindow = null;
    mapController = null;
  }
}

/// A stateful widget responsible to create widget based custom info window.
class CustomInfoWindow extends StatefulWidget {
  /// A [CustomInfoWindowController] to manipulate [CustomInfoWindow] state.
  final CustomInfoWindowController controller;

  /// Offset to maintain space between [MFMarker] and [CustomInfoWindow].
  final double offset;

  /// Height of [CustomInfoWindow].
  final double height;

  /// Width of [CustomInfoWindow].
  final double width;

  const CustomInfoWindow({
    required this.controller,
    this.offset = 50,
    this.height = 50,
    this.width = 100,
  })  : assert(offset >= 0),
        assert(height >= 0),
        assert(width >= 0);

  @override
  _CustomInfoWindowState createState() => _CustomInfoWindowState();
}

class _CustomInfoWindowState extends State<CustomInfoWindow> {
  bool _showNow = false;
  double _leftMargin = 0;
  double _topMargin = 0;
  Widget? _child;
  MFLatLng? _latLng;

  @override
  void initState() {
    super.initState();
    widget.controller.addInfoWindow = _addInfoWindow;
    widget.controller.onCameraMove = _onCameraMove;
    widget.controller.hideInfoWindow = _hideInfoWindow;
  }

  /// Calculate the position on [CustomInfoWindow] and redraw on screen.
  void _updateInfoWindow() async {
    if (_latLng == null ||
        _child == null ||
        widget.controller.mapController == null) {
      return;
    }

    final screenCoordinate =
        await widget.controller.mapController!.getScreenCoordinate(_latLng!);

    double left = screenCoordinate.x.toDouble() - (widget.width / 2);
    double top =
        screenCoordinate.y.toDouble() - (widget.offset + widget.height);
    setState(() {
      _showNow = true;
      _leftMargin = left;
      _topMargin = top;
    });
  }

  /// Assign the [Widget] and [MFMarker]'s [MFLatLng].
  void _addInfoWindow(Widget child, MFLatLng latLng) {
    _child = child;
    _latLng = latLng;
    _updateInfoWindow();
  }

  /// Notifies camera movements on [Map4dMap].
  void _onCameraMove() {
    if (!_showNow) return;
    _updateInfoWindow();
  }

  /// Disables [CustomInfoWindow] visibility.
  void _hideInfoWindow() {
    setState(() {
      _showNow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _leftMargin,
      top: _topMargin,
      child: Visibility(
        visible: (_showNow == false ||
                (_leftMargin == 0 && _topMargin == 0) ||
                _child == null ||
                _latLng == null)
            ? false
            : true,
        child: Container(
          child: _child,
          height: widget.height,
          width: widget.width,
        ),
      ),
    );
  }
}
