import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:map4d_map/map4d_map.dart';
import 'package:map4d_services/map4d_services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AutoSuggest Demo',
      home: AutoSuggestSample(),
    );
  }
}

class AutoSuggestSample extends StatefulWidget {
  const AutoSuggestSample({Key? key}) : super(key: key);

  @override
  _AutoSuggestSampleState createState() => _AutoSuggestSampleState();
}

class _AutoSuggestSampleState extends State<AutoSuggestSample> {
  final Completer<MFMapViewController> _controller = Completer();
  List<ListTile> _listTile = <ListTile>[];

  static const MFLatLng _kDaNang = MFLatLng(16.071958, 108.225429);
  static const MFCameraPosition _kInitialCameraPosition =
      MFCameraPosition(target: _kDaNang, zoom: 14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          MFMapView(
              initialCameraPosition: _kInitialCameraPosition,
              onMapCreated: (MFMapViewController controller) {
                _controller.complete(controller);
              }),
          buildFloatingSearchBar()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'My Location',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (text) {
        print(text);
        getListAutoSuggestion(text);
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
              color: Colors.white,
              elevation: 4.0,
              child: Column(
                children: _listTile,
              )),
        );
      },
    );
  }

  void getListAutoSuggestion(String textSearch) async {
    if (textSearch.isEmpty) {
      return;
    }

    try {
      final places = await MFServices.places.fetchSuggestion(
        textSearch,
        location: const MFLocationComponent(
            latitude: 16.071958, longitude: 108.225429),
        acronym: false,
      );
      print('Auto Suggest: $places');
      List<ListTile> list = <ListTile>[];
      for (var element in places) {
        list.add(ListTile(
          title: Text(element.name),
          subtitle: Text(element.address),
        ));
      }
      setState(() {
        _listTile = list;
      });
    } on MFServiceError catch (error) {
      print('Auto Suggest Error: ${error.code}, ${error.message}');
    }
  }
}
