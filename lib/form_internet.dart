import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkChecker {
  bool _wasDisconnected = false;

  void startMonitoring(BuildContext context) {
    // Connectivity().onConnectivityChanged.listen((
    //   ConnectivityResult result,
    // ) {
    //   // Check if there is no connectivity
    //   if (result == ConnectivityResult.none) {
    //     _wasDisconnected = true;
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('No internet'),
    //         backgroundColor: Colors.red,
    //         duration: Duration(seconds: 3),
    //       ),
    //     );
    //     print('No internet');
    //   } else {
    //     if (_wasDisconnected) {
    //       _wasDisconnected = false;
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           content: Text('Internet is back'),
    //           backgroundColor: Colors.green,
    //           duration: Duration(seconds: 2),
    //         ),
    //       );
    //       print('Internet is back');
    //     }
    //   }
    // });
  }
}
