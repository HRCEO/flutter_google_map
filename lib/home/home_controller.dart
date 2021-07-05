import 'dart:async';
import 'package:flutter/widgets.dart' show ChangeNotifier;
import 'package:flutter/cupertino.dart';
import 'package:flutter_google_map/utils/map_style.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HomeController extends ChangeNotifier {
  final Map<MarkerId,Marker> _markers = {};
  Set<Marker> get markers => _markers.values.toSet();

  final _markersController = StreamController<String>.broadcast();
  Stream<String> get onMarkerTap => _markersController.stream;

  Position? _initialPosition;
  CameraPosition get initialCameraPosition => CameraPosition(
      target : LatLng(
        _initialPosition!.latitude,
        _initialPosition!.longitude,
      ),
    zoom: 15,
  );

  bool _loading = true;
  bool get loading => _loading;

  late bool _gpsEnabled;
  bool get gpsEnabled=>_gpsEnabled;

  StreamSubscription? _gpsSubscription, _postionSubscription;

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
      (position) {
        print("---------------------------------------------------------------------------------------------------------------------🎭 $position");
        if(!initialized){
          print("---------------------------------------------------------------------------------------------------------------------🎭 init $position");
          _setInitialPosition(position);
          initialized = true;
          notifyListeners();
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
  }

  Future<void> turnOnGPS() => Geolocator.openLocationSettings();

  void onTap(LatLng position) async{
    final id = _markers.length.toString();
    final markerId = MarkerId(id);
    final marker = Marker(
      markerId: markerId,
      position: position,
      draggable: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(0),
      onTap: (){
        _markersController.sink.add(id);
      },
      onDragEnd: (newPosition){
        print("---------------------------------------------------------------------------------------------------------------------🎭 new position $newPosition");
      }
    );
    _markers[markerId] = marker;
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