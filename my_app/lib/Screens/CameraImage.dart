import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class CameraImage extends StatefulWidget {
  static const routeName = '/CameraImage';
  final BluetoothConnection? connection;
  const CameraImage({Key? key, required this.connection,}) : super(key: key);

  @override
  State<CameraImage> createState() => _CameraImageState();
}

class _CameraImageState extends State<CameraImage> {
  List<Color> _imageData = [];
  StreamSubscription<List<int>>? _subscription;
  BluetoothConnection? _localConnection;
  @override
  void initState() {
    super.initState();
    _localConnection = widget.connection;
    _startListening();
  }
  @override
  void dispose() {
    _localConnection?.close();
    super.dispose();
  }

  void _startListening() {
    int totalPixels = 64;
    int pixelsReceived = 0;
    List<double> receivedData = [];

    _localConnection!.input!.listen((value) {
      String data = utf8.decode(value);
      List<String> dataString = data.split(',');
      List<double> parsedData = dataString.map(double.parse).toList();
      receivedData.addAll(parsedData);

      pixelsReceived += parsedData.length;
      if (pixelsReceived >= totalPixels) {
        setState(() {
          _imageData = _parseData(receivedData);
        });
      }
    });
  }
  List<Color> _parseData(List<double> data) {
    List<Color> colors = [];
    for (int i = 0; i < data.length; i += 2) {
      int pixelValue = data[i].toInt() + (data[i + 1].toInt() << 8);
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
      body: Column(
          children: [ ElevatedButton(
            child: Text('Back to the control page'),
            onPressed: () {
              Navigator.pop(context,0);
            },
          ),
            Center(
              child: _imageData.isEmpty
                  ? CircularProgressIndicator()
                  : Image.memory(
                Uint8List.fromList(
                    _imageData.map((value) => value.value).toList()),
                width: 640,
                height: 480,
                fit: BoxFit.cover,
              ),
            )]),
    );
  }
}