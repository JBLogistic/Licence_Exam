import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:flutter/rendering.dart';

import '../providers/ThermalImagePainter.dart';



class CameraImage extends StatefulWidget {
  static const routeName = '/CameraImage';
  final BluetoothConnection? connection;

  const CameraImage({Key? key, required this.connection}) : super(key: key);

  @override
  State<CameraImage> createState() => _CameraImageState();
}

class _CameraImageState extends State<CameraImage> {
  StreamSubscription<List<int>>? _subscription;
  BluetoothConnection? _localConnection;
  final List<double> _imageData = List<double>.filled(64, 0.0);
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

    _localConnection!.input!.listen(
          (value) {
            String data = utf8.decode(value); // Convert the received bytes to a string
            print(data);
            List<String> dataString = data.split( ','); // Split the string by commas
            // Parse the received data
            List<double> newData = dataString
                .map((stringValue) => double.tryParse(stringValue) ?? 0.0)
                .toList();

            setState(() {
              for (int i = 0; i < newData.length; i++) {
                if (i < _imageData.length) {
                  _imageData[i] = newData[i];
                }
              }
            });
          });
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thermal Camera'),
      ),
      body: Column(
          children: [
            ElevatedButton(
              child: Text('Back to the control page'),
              onPressed: () {
                Navigator.pop(context, 0);
              },
            ),
            SizedBox(height: 16), _imageData.isEmpty
                  ? CircularProgressIndicator()
                  : CustomPaint(
                painter: ThermalImagePainter(_imageData),
              )
          ],
        ),

    );
  }
}
