import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'package:my_app/Screens/CameraImage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HC-05 Connection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothHomePage(),
    );
  }
}

class BluetoothHomePage extends StatefulWidget {
  @override
  _BluetoothHomePageState createState() => _BluetoothHomePageState();
}

class _BluetoothHomePageState extends State<BluetoothHomePage> {
  BluetoothDevice? _device;
  BluetoothConnection? _connection;
  bool _value = false;
  late int _cam;
  int request = 0;
  Uint8List _dataList= Uint8List.fromList([0,0,0,0]);
  TextEditingController _textFieldController = TextEditingController();

  Future<void> _checkBluetoothStatus() async {
    bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
    if (!isEnabled!) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Bluetooth is disabled'),
            content: Text('Please enable Bluetooth to continue.'),
            actions: [
              ElevatedButton(
                child: Text('Enable Bluetooth'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await FlutterBluetoothSerial.instance.requestEnable();
                },
              ),
            ],
          );
        },
      );
    }
  }
  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
  }
  Future<void> _discoverDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      print(e);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a device'),
          content: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(devices[index].name.toString()),
                subtitle: Text(devices[index].address),
                onTap: () {
                  Navigator.pop(context, devices[index]);
                },
              );
            },
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _device = value;
        });
      }
    });
  }

  Future<void> _connectToDevice() async {
    if (_device == null) {
      return;
    }

    try {
      _connection = await BluetoothConnection.toAddress(_device?.address);
      print('Connected to device');
      // Perform any further operations with the connection
    } catch (e) {
      print(e);
    }
  }
  void _sendData() async {

    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(_dataList);
      _connection!.output.allSent.then((_) {
        print('Sent: $_dataList');
      });
    }
  }
  List<double> convert(List<String> data){
    List<double> matrix = List<double>.generate(64, (index) => 0.0, growable: false);
    int i =0;
    while(i< matrix.length){
      matrix[i] = double.parse(data.elementAt(i));
      i++;
    }
    return matrix;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            ElevatedButton(
              child: Text('Discover Devices'),
              onPressed: _discoverDevices,
            ),
            Text(
              _device.toString(),
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Connect to Device'),
              onPressed:  _connectToDevice,
            ),
            SizedBox(height: 20),
            Switch(
              value: _value,
              onChanged: (bool value) {
                setState(() {
                  _value = value;
                  _dataList[0] = value ? 0 : 1; // Update the value at index 1
                  _sendData();
                });
              },
            ),

          if (_connection != null ) ...[
          SizedBox(height:20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(200, 50),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('See what the robot sees'),
            onPressed: () async => {
              _dataList[1] = 1,
              _sendData(),
              _cam = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraImage(connection: _connection),
                ),
              ),
              _dataList[1] = _cam ?? 0,
            },
          ),
            SizedBox(height: 20),
            if (_value) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(100, 50),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text("^"),
                onPressed: () => {_dataList[2] = 0,
                  _dataList[3] = 0,
                  _sendData()
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 50),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text("<-"),
                    onPressed: () => {_dataList[2] = 1,
                      _dataList[3] = 0,
                      _sendData()},
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 50),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text("->"),
                    onPressed: () => {_dataList[2] = 0, _dataList[3] = 1,_sendData()},
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(100, 50),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text("v"),
                onPressed: () => {_dataList[2] = 1,_dataList[3] = 1,_sendData()},
              ),

            ]
          ],],
        ),
      ),
    );
  }
}