import 'package:map4d_map/map4d_map.dart';
import 'package:map4d_services/map4d_services.dart';

List<List<MFLatLng>> routesFromDirections(MFDirectionsResult directionsResult) {
  List<List<MFLatLng>> routes = <List<MFLatLng>>[];
  directionsResult.routes?.forEach((routeResult) {
    List<MFLatLng> route = <MFLatLng>[];
    for (var legResult in routeResult.legs) {
      final startLocation = legResult.startLocation;
      route.add(MFLatLng(startLocation.latitude, startLocation.longitude));

      for (var stepResult in legResult.steps) {
        for (var element in stepResult.polyline) {
          route.add(MFLatLng(element.latitude, element.longitude));
        }
      }

      final endLocation = legResult.endLocation;
      route.add(MFLatLng(endLocation.latitude, endLocation.longitude));
    }

    if (route.isNotEmpty) {
      routes.add(route);
    }
  });
  return routes;
}
