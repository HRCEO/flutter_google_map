import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_map/request_permission/request_permission_controller.dart';
import 'package:flutter_google_map/routes/routes.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestPermissionPage extends StatefulWidget {
  const RequestPermissionPage({Key? key}) : super(key: key);

  @override
  _RequestPermissionPageState createState() => _RequestPermissionPageState();
}

class _RequestPermissionPageState extends State<RequestPermissionPage> with WidgetsBindingObserver {
  final _controller = RequestPermissionController(Permission.locationWhenInUse);
  late StreamSubscription _subscription;
  bool _fromSettings = false;

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _subscription = _controller.onStatusChanged.listen(
      (status) {
        switch (status) {
          case PermissionStatus.granted:
            _goToHome();
            break;
          case PermissionStatus.denied:
            print("text");
              showDialog(
                context: context,
                builder: (_)=>AlertDialog(
                  title: const Text("INFO"),
                  content: const Text("need set Location permissions"),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          _fromSettings = await openAppSettings();
                        },
                        child: Text("Go to settings"),
                    ),
                    TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                  ),
                ],
              ),
            );
            break;
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("state $state");
    if(state == AppLifecycleState.resumed && _fromSettings){
      final status = await _controller.check();
      if(status == PermissionStatus.granted){
        _goToHome();
      }
    }
    _fromSettings = false;
  }

  @override
  void dispose(){
    WidgetsBinding.instance!.removeObserver(this);
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goToHome(){
    Navigator.pushReplacementNamed(context, Routes.HOME);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: ElevatedButton(
            child: Text("Allow"),
            onPressed: (){
              _controller.request();
            },
          ),
        ),
      ),
    );
  }
}
