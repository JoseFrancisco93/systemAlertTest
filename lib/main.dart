import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/isolated_manager.dart';
import 'package:system_alert_window/system_alert_window.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MethodChannel _channel = MethodChannel('video_call_overlay');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Video Call Overlay Plugin'),
        ),
        body: Center(
          child: ElevatedButton(
            child: Text('Version OS'),
            onPressed: () {
              invokeMethod();
            },
          ),
        ),
      ),
    );
  }

  Future<void> invokeMethod() async {
    try {
      final String platformVersion =
          await _channel.invokeMethod('getPlatformVersion');
      print(platformVersion);
    } catch (e) {
      print('Error al invocar el método: $e');
    }
  }
}
