//WiredConnectionPage
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';

class WiredConnectionPage extends StatefulWidget {
  @override
  State<WiredConnectionPage> createState() => _WiredConnectionPageState();
}

class _WiredConnectionPageState extends State<WiredConnectionPage> {
  UsbPort? _port;
  String? deviceId = 'deviceId';
  String? deviceName = 'deviceName';
  String? pid = 'pid';
  String? productName = 'productName';
  String? serial = 'serial';

  Future<bool> _connectTo(UsbDevice? device) async {
    if (_port != null) {
      _port!.close();
      _port = null;
    }

    _port = await device!.create();
    deviceName = device.deviceName;
    if (!await _port!.open()) {
      return false;
    }
    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
        9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    return true;
  }

  void _getPorts() async {
    print('겟포트 시작!!');
    List<UsbDevice> devices = await UsbSerial.listDevices();
    print('getPorts: ${devices}');
    var isSuc = await _connectTo(devices.isEmpty ? null : devices[0]);
    setState(() {});
    print('isSuc : $isSuc');
  }

  void sendMsg(String msg) async {
    // 보내는 메시지의 끝자리를 아두이노가 읽음. 자세한 설명은 아두이노 코드에 있음.
    await _port!.write(Uint8List.fromList(msg.codeUnits));
  }

  @override
  void initState() {
    UsbSerial.usbEventStream?.listen((UsbEvent event) {
      print('이벤트: $event');
      _getPorts();
    });
    _getPorts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          IconButton(
              onPressed: () {
                print('아아아ㅏ아');
                _getPorts();
              },
              icon: Icon(Icons.refresh)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$deviceId',
              style: TextStyle(fontSize: 10.0),
            ),
            Text(
              '$deviceName',
              style: TextStyle(fontSize: 10.0),
            ),
            Text(
              '$pid',
              style: TextStyle(fontSize: 10.0),
            ),
            Text(
              '$productName',
              style: TextStyle(fontSize: 10.0),
            ),
            Text(
              '$serial',
              style: TextStyle(fontSize: 10.0),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => sendMsg('start'),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () => sendMsg('stop'),
            tooltip: 'Increment',
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
