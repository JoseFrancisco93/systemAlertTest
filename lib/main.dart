import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/isolated_manager.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:system_window_overlay/system_window_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class SystemAlertWindowIOS {
  static const MethodChannel _channel = MethodChannel('system_alert_window');

  static Future<String> getPlatformVersion() async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> showSystemWindow(String userName) async {
    await _channel.invokeMethod('showSystemWindow', {'userName': userName});
  }

  static Future<void> closeSystemWindow() async {
    await _channel.invokeMethod('closeSystemWindow');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _pipButton(),
          ],
        ),
      ),
    );
  }
}

bool buttonPressCallback(String tag) {
  SendPort? port = IsolateManager.lookupPortByName();
  if (port != null) {
    try {
      port.send([tag]);
    } catch (exception) {
      print("ERROR IN SENDING $exception"); // NO PROBLEM HERE
    }

    return true;
  }
  return false;
}

class _pipButton extends StatefulWidget {
  const _pipButton({super.key});

  @override
  State<_pipButton> createState() => __pipButtonState();
}

class __pipButtonState extends State<_pipButton> {
  String _platformVersion = 'Unknown';
  bool _isShowingWindow = false;
  bool _isMicOn = true;
  bool _isUpdatedWindow = false;
  SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _initPlatformState();
      _requestPermissions();
      initOverlayView();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initPlatformState() async {
    await SystemAlertWindow.enableLogs(true);
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = (await SystemAlertWindow.platformVersion)!;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  final MethodChannel _channel = MethodChannel('plugin_name');

  Future<void> showAlert(String message) async {
    try {
      await _channel.invokeMethod('showAlert', {'message': message});
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _requestPermissions() async {
    await SystemAlertWindow.requestPermissions(prefMode: prefMode);
  }

  Future<void> initOverlayView() async {
    await SystemAlertWindow.requestPermissions;
    ReceivePort _port = ReceivePort();
    IsolateManager.registerPortWithName(_port.sendPort);
    _port.listen((dynamic callBackData) {
      String tag = callBackData[0];
      if (tag == "micOn") {
        print('mic ✅✅');
      } else if (tag == "micOff") {
        print('mic ❌❌');
      } else if (tag == "expand") {
        print("expand 🚩🚩");
      }
    });

    SystemAlertWindow.registerOnClickListener(buttonPressCallback);
  }

  SystemWindowBody body = SystemWindowBody(
    decoration: SystemWindowDecoration(
      startColor: Colors.black87,
      borderRadius: 8,
    ),
    rows: [
      EachRow(
        columns: [
          EachColumn(
            text: SystemWindowText(
              text: "J",
            ),
          ),
        ],
        gravity: ContentGravity.CENTER,
      ),
    ],
    padding: SystemWindowPadding(left: 4, right: 4, bottom: 4, top: 4),
  );

  Future<void> _showOverlayWindow() async {
    if (!_isShowingWindow) {
      SystemAlertWindow.showSystemWindowVEs(
          userName: 'Jose francisco vasquez',
          height: 82,
          width: 150,
          body: body,
          gravity: SystemWindowGravity.CENTER,
          prefMode: prefMode,
          isDisableClicks: _isMicOn,
          backgroundColor: Colors.transparent,
          margin: SystemWindowMargin(right: 300, left: 0, bottom: 500, top: 0));
      setState(() {
        _isShowingWindow = true;
      });
    } else {
      setState(() {
        _isShowingWindow = false;
      });
      SystemAlertWindow.closeSystemWindow(prefMode: prefMode);
    }
  }

  _micOn() {
    _isMicOn = true;
  }

  _micOff() {
    _isMicOn = false;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text('Running on: $_platformVersion\n'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: MaterialButton(
              onPressed: _showOverlayWindow,
              textColor: Colors.white,
              color: !_isShowingWindow ? Colors.green : Colors.red,
              padding: const EdgeInsets.all(8.0),
              child: !_isShowingWindow ? Text("Show") : Text("Close "),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  SystemAlertWindowIOS.showSystemWindow('Jose');
                },
                icon: const Icon(
                  Icons.add,
                ),
              ),
              IconButton(
                onPressed: () {
                  SystemAlertWindowIOS.closeSystemWindow();
                },
                icon: const Icon(
                  Icons.remove,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
