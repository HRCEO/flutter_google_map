import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' show ChangeNotifier;
import 'package:flutter/cupertino.dart';
import 'package:flutter_google_map/utils/map_style.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HomeController extends ChangeNotifier {
  final Map<MarkerId,Marker> _markers = {};
  final Map<PolylineId,Polyline> _polylines = {};
  final Map<PolygonId,Polygon> _polygons = {};


  Set<Marker> get markers => _markers.values.toSet();
  Set<Polyline> get polylines => _polylines.values.toSet();
  Set<Polygon> get polygons => _polygons.values.toSet();

  final _markersController = StreamController<String>.broadcast();
  Stream<String> get onMarkerTap => _markersController.stream;

  Position? _initialPosition;
  Position? get initialPosition => _initialPosition;


  bool _loading = true;
  bool get loading => _loading;

  late bool _gpsEnabled;
  bool get gpsEnabled=>_gpsEnabled;

  StreamSubscription? _gpsSubscription, _postionSubscription;
  GoogleMapController? _mapController;

  String _polylineId = '0';
  String _polygonId = '0';

  HomeController(){
    _init();
  }

  Future<void> _init() async{
    _gpsEnabled = await Geolocator.isLocationServiceEnabled();
    _loading = false;
    _gpsSubscription = Geolocator.getServiceStatusStream().listen(
        (status) async {
          _gpsEnabled = status == ServiceStatus.enabled;
          if(_gpsEnabled){
            _initLocationUpdates();
          }
        },
    );
    _initLocationUpdates();
  }

  Future<void> _initLocationUpdates() async{
    bool initialized = false;
    await _postionSubscription?.cancel();
    _postionSubscription = Geolocator.getPositionStream().listen(
      (position) async {
        print("---------------------------------------------------------------------------------------------------------------------🎭 $position");
        if(!initialized){
          print("---------------------------------------------------------------------------------------------------------------------🎭 init $position");
          _setInitialPosition(position);
          initialized = true;
          notifyListeners();
        }
        if(_mapController != null){
          final zoom = await _mapController!.getZoomLevel();
          final cameraUpdate = CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            zoom,
          );
          _mapController!.animateCamera(cameraUpdate);
        }
      },
      onError:(e){
        print("---------------------------------------------------------------------------------------------------------------------🎆 onError${e.runtimeType}");
        if(e is LocationServiceDisabledException){
          _gpsEnabled = false;
          notifyListeners();
        }
      }
    );
  }

  void _setInitialPosition(Position position){
    if(_gpsEnabled && _initialPosition == null){
      //_initialPosition = await Geolocator.getLastKnownPosition(); //장치 마지막 위치
      //_initialPosition = await Geolocator.getCurrentPosition(); // 장치의 위치
      _initialPosition = position;
      print("initialPosition $_initialPosition");
    }
  }

  void onMapCreated(GoogleMapController controller){
    controller.setMapStyle(mapStyle);
    _mapController = controller;
  }

  Future<void> turnOnGPS() => Geolocator.openLocationSettings();

  void newPolyline(){
    _polylineId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void newPolygon(){
    _polygonId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void onTap(LatLng position) async{
    /// /클릭시 마커 다중 생성코드
    // final id = _markers.length.toString();
    // final markerId = MarkerId(id);
    // final marker = Marker(
    //   markerId: markerId,
    //   position: position,
    //   draggable: true,
    //   icon: BitmapDescriptor.defaultMarkerWithHue(0),
    //   onTap: (){
    //     _markersController.sink.add(id);
    //   },
    //   onDragEnd: (newPosition){
    //     print("---------------------------------------------------------------------------------------------------------------------🎭 new position $newPosition");
    //   }
    // );
    // _markers[markerId] = marker;
    // notifyListeners();
    
    /// /폴리라인
    // final PolylineId polylineId = PolylineId(_polylineId);
    // late Polyline polyline;
    // if(_polylines.containsKey(polylineId)){
    //   final tmp = _polylines[polylineId]!;
    //   polyline = tmp.copyWith(pointsParam: [...tmp.points, position],);
    // }
    // else {
    //   final color = Colors.primaries[_polylines.length];
    //  polyline = Polyline(
    //    polylineId: polylineId,
    //    points: [position],
    //    width: 3,
    //    color: color,
    //    startCap: Cap.roundCap,
    //    endCap: Cap.roundCap,
    //    // patterns: [
    //    //   PatternItem.dot,
    //    //   PatternItem.dash(10),
    //    // ],
    //  );
    // }
    // _polylines[polylineId] =polyline;
    // notifyListeners();

    /// / 폴리곤
    final polygonId = PolygonId(_polygonId);
    late Polygon polygon;
    if(_polygons.containsKey(polygonId)){
      final tmp = _polygons[polygonId]!;
      polygon = tmp.copyWith(
        pointsParam: [...tmp.points,position]
      );
    }else{
      final color = Colors.primaries[polygons.length];
      polygon = Polygon(
        polygonId: polygonId,
        points: [position],
        strokeWidth: 3,
        strokeColor: color,
        fillColor: color.withOpacity(0.4),
      );
    }
    _polygons[polygonId] = polygon;
    notifyListeners();

  }

  @override
  void dispose(){
    _postionSubscription?.cancel();
    _gpsSubscription?.cancel();
    _markersController.close();
    super.dispose();
  }

}