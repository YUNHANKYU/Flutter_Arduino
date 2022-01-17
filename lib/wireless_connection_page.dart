import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class WirelessConnectionPage extends StatefulWidget {
  const WirelessConnectionPage({Key? key}) : super(key: key);

  @override
  State<WirelessConnectionPage> createState() => _WirelessConnectionPageState();
}

class _WirelessConnectionPageState extends State<WirelessConnectionPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  List<BluetoothDevice> _devicesList = [];

  BluetoothConnection? connection;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection!.isConnected;
  bool isDisconnecting = false;

  bool _connected = false;

  BluetoothDevice? _device;

  Map<String, String> a = {
    'smarthome1': '98:D3:61:F9:57:A4', //636AA
    'smarthome2': '98:D3:51:F9:4E:D9', //K742US
  };

  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Get current state
    _bluetooth.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    // 핸드폰 블루투스 켜져있는지 확인하고 아니면 리퀘스트 날리는 함수
    enableBluetooth();

    // 핸드폰 블루투스 연결 체크하는 리스너
    // state 체크해서 제어하기
    _bluetooth.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection!.dispose();
      connection = null;
    }

    super.dispose();
  }

  Future<void> enableBluetooth() async {
    _bluetoothState = await _bluetooth.state;

    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await _bluetooth.requestEnable();
      await getPairedDevices();
    } else {
      await getPairedDevices();
    }
  }

  // 디바이스 리스트 업데이트 하는 함수
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("겟 블루투스 디바이시스 Error");
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _devicesList =
          devices.where((BluetoothDevice e) => e.name!.contains('HC')).toList();
      print(_devicesList[0].address);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        print('언포커스');
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async => await getPairedDevices(),
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () => _openBluetoothSetting(),
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                )),
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05, vertical: size.width * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        DropdownButton(
                          items: _getDeviceItems(),
                          onChanged: (BluetoothDevice? value) =>
                              setState(() => _device = value),
                          value: _devicesList.isNotEmpty ? _device : null,
                        ),
                        ElevatedButton(
                          onPressed: !_bluetoothState.isEnabled
                              ? null
                              : _connected
                                  ? _disconnect
                                  : _connect,
                          child: Text(_connected ? 'Disconnect' : 'Connect'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Expanded(
                            flex: 1, child: Center(child: Text('💡 Light: '))),
                        Expanded(
                            flex: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: _connected
                                      ? () => _sendLightMessageToBluetooth(true)
                                      : null,
                                  child: const Text("ON"),
                                ),
                                ElevatedButton(
                                  onPressed: _connected
                                      ? () =>
                                          _sendLightMessageToBluetooth(false)
                                      : null,
                                  child: const Text("OFF"),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Expanded(
                            flex: 1, child: Center(child: Text('🚪 Door: '))),
                        Expanded(
                            flex: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: _connected
                                      ? () => _sendDoorMessageToBluetooth(true)
                                      : null,
                                  child: const Text("ON"),
                                ),
                                ElevatedButton(
                                  onPressed: _connected
                                      ? () => _sendDoorMessageToBluetooth(false)
                                      : null,
                                  child: const Text("OFF"),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Expanded(
                            flex: 1, child: Center(child: Text('📺 LCD: '))),
                        Expanded(
                          flex: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: size.width * 0.4,
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Message',
                                    hintText: 'Enter message',
                                    labelStyle:
                                        TextStyle(color: Colors.blueAccent),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                  onChanged: (value) {
                                    setState(() {
                                      _controller.text = value;
                                    });
                                    print(_controller.text);
                                  },
                                  focusNode: _focusNode,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _connected
                                    ? () => _sendLCDMessageToBluetooth(
                                        _controller.text)
                                    : null,
                                child: const Text("SEND"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name! + ' - ' + device.address),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() async {
    if (!isConnected) {
      try {
        await BluetoothConnection.toAddress(_device!.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection!.input!.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('디바이스와 연결할 수 없습니다. 디바이스가 켜져 있는지 확인해 주세요.');
          print(error);
        });
      } catch (e) {
        print('에러: $e');
      }
    }
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    await connection!.close();
    if (!connection!.isConnected) {
      setState(() {
        _connected = false;
      });
    }
  }

  void _sendLightMessageToBluetooth(bool onOff) async {
    var msg = '1'; // light off
    if (onOff) msg = '0';
    connection!.output.add(Uint8List.fromList(utf8.encode('5' + '\r\n')));
    connection!.output.add(Uint8List.fromList(utf8.encode(msg + '\r\n')));
  }

  void _sendDoorMessageToBluetooth(bool onOff) async {
    var msg = '3'; // door close
    if (onOff) msg = '2';
    connection!.output.add(Uint8List.fromList(utf8.encode('5' + '\r\n')));
    connection!.output.add(Uint8List.fromList(utf8.encode(msg + '\r\n')));
  }

  void _sendLCDMessageToBluetooth(String message) async {
    connection!.output.add(Uint8List.fromList(utf8.encode('4' + '\r\n')));
    if (message.isEmpty) {
      print('메시지를 입력해주세요.');
    } else {
      print(message);
      connection!.output.add(Uint8List.fromList(utf8.encode(message + '\r\n')));
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendOnMessageToBluetooth() async {
    connection!.output.add(Uint8List.fromList(utf8.encode("1" + "\r\n")));
    await connection!.output.allSent;
  }

  // Method to send message,
  // for turning the Bluetooth device off
  void _sendOffMessageToBluetooth() async {
    connection!.output.add(Uint8List.fromList(utf8.encode("0" + "\r\n")));
    await connection!.output.allSent;
  }

  // 블루투스 모듈이 검색이 안되는 경우 직접 세팅으로 이동할때 사용
  void _openBluetoothSetting() {
    FlutterBluetoothSerial.instance.openSettings();
  }
}
