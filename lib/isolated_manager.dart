// ignore_for_file: constant_identifier_names
import 'dart:isolate';

import 'dart:ui';

class IsolateManager {
  static const FOREGROUND_PORT_NAME = "foreground_port_name";

  static SendPort? lookupPortByName() {
    return IsolateNameServer.lookupPortByName(FOREGROUND_PORT_NAME);
  }

  static bool registerPortWithName(SendPort port) {
    removePortNameMapping(FOREGROUND_PORT_NAME);
    return IsolateNameServer.registerPortWithName(port, FOREGROUND_PORT_NAME);
  }

  static bool removePortNameMapping(String name) {
    return IsolateNameServer.removePortNameMapping(name);
  }
}
