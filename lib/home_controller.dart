import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeController extends ChangeNotifier {
  final Map<MarkerId,Marker> _markers = {};
  Set<Marker> get markers => _markers.values.toSet();

  final initialCameraPosition = const CameraPosition(
    target: LatLng(37.405535, 127.152955),
    zoom: 15,
  );

  void onTap(LatLng position){
    final markerId = MarkerId(_markers.length.toString());
    final marker = Marker(
      markerId: markerId,
      position: position,
    );
    _markers[markerId] = marker;
    notifyListeners();
  }
}