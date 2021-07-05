import 'package:flutter/widgets.dart';
import 'package:flutter_google_map/home/home_page.dart';
import 'package:flutter_google_map/request_permission/request_permission_page.dart';
import 'package:flutter_google_map/routes/routes.dart';
import 'package:flutter_google_map/splash/splash_page.dart';

Map<String, Widget Function(BuildContext)>appRoutes(){
  return {
    Routes.SPLASH:(_)=> const SplashPage(),
    Routes.PERMISSION :(_)=> const RequestPermissionPage(),
    Routes.HOME:(_)=>const HomePage(),
  };
}