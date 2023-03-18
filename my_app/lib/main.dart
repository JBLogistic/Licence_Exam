import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thermal Camera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothConnection? _connection;
  List<Color> _imageData = [];

  @override
  void initState() {
    super.initState();
    _scanDevices();
  }

  Future<void> _scanDevices() async {
    try {
      FlutterBluetoothSerial.instance.startDiscovery().listen((device) {
        if (device.device.name == "NET") {
          _connectToDevice(device.device);
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _connection!.input!.listen(_onDataReceived).onDone(() {
        print('Disconnected');
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onDataReceived(Uint8List data) {
    setState(() {
      _imageData = _parseData(data);
    });
  }

  List<Color> _parseData(Uint8List data) {
    List<Color> colors = [];
    for (int i = 0; i < data.length; i += 2) {
      int pixelValue = data[i] + (data[i + 1] << 8);
      Color color = _getColor(pixelValue);
      colors.add(color);
    }
    return colors;
  }

  Color _getColor(int pixelValue) {
    double value = 255 * pixelValue / 0xFFF;
    return Color.fromARGB(0xFF, value.toInt(), value.toInt(), value.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thermal Camera'),
      ),
      body: Center(
        child: _imageData.isEmpty
            ? CircularProgressIndicator()
            : Image.memory(
                Uint8List.fromList(
                    _imageData.map((value) => value.value).toList()),
                width: 640,
                height: 480,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  @override
  void dispose() {
    if (_connection != null) {
      _connection!.dispose();
      _connection = null;
    }
    super.dispose();
  }
}
