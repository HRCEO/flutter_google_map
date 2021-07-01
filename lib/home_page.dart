import 'package:flutter/material.dart';
import 'package:flutter_google_map/home_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class GeoLocatorService {
  Future<Position> getLocation() async {
    Position position =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }
}

class HomePage extends StatelessWidget {

  const HomePage({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeController>(
      create:(_)=>HomeController(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('GoogleMap 라온파밍'),
        ),
          body: Consumer<HomeController>(
            builder: (_, controller, __) => GoogleMap(
              markers: controller.markers,
              initialCameraPosition: controller.initialCameraPosition,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              onTap: controller.onTap,
            ),
          )
      ),
    );
  }
}

