import 'package:flutter/material.dart';
import 'package:flutter_google_map/home/home_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeController>(
      create:(_) {
        final controller = HomeController();
          controller.onMarkerTap.listen((String id){
            print("---------------------------------------------------------------------------------------------------------------------🎭 got to $id");
          });
          return controller;
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text('GoogleMap 라온파밍'),
            ),
            body:Selector<HomeController,bool>(
              selector: (_, controller)=> controller.loading,
              builder: (context, loading, loadingWidget){
                if(loading){
                  return loadingWidget!;
                }
                return Consumer<HomeController>(
                  builder: (_, controller, gpsMessageWidget) {
                    if(!controller.gpsEnabled){
                     return gpsMessageWidget!;
                    }

                    return GoogleMap(
                      markers: controller.markers,
                      onMapCreated: controller.onMapCreated,
                      initialCameraPosition: controller.initialCameraPosition,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      compassEnabled: true,
                      onTap: controller.onTap,
                    );
                  },
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("To use our app we need the access to your location, \n so you must enable the GPS",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: (){
                              final controller = context.read<HomeController>();
                              controller.turnOnGPS();
                            },
                            child: const Text("Trun on GPS")
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Center(
                child:CircularProgressIndicator(),
              ),
            )
        )
    );
  }
}

