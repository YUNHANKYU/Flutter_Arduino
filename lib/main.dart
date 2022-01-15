// 참고 아티클
// https://m.blog.naver.com/boilmint7/221900933326
// https://blog.codemagic.io/creating-iot-based-flutter-app/

import 'package:flutter/material.dart';

import 'wired_connection_page.dart';
import 'wireless_connection_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Arduino',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Arduino Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(
                      TextStyle(fontSize: 14, color: Colors.white)),
                  backgroundColor: MaterialStateProperty.all(Colors.red)),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => WiredConnectionPage())),
              child: Text('🤝 wired connection'),
            ),
            SizedBox(
              height: 40.0,
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => WirelessConnectionPage())),
              child: Text('🌀 wireless connection'),
            ),
          ],
        ),
      ),
    );
  }
}
