// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'dart:io';

class StrengthPage extends StatelessWidget {
  final File image;
  final String imageType; // 'Imported' or 'Captured'

  const StrengthPage({
    Key? key,
    required this.image,
    required this.imageType,
  }) : super(key: key);

  Future<String> _getSignalStrength() async {
    try {
      final WifiInfo wifiInfo = WifiInfo();
      String? signalStrength = await wifiInfo.getWifiBSSID();
      return signalStrength != null ? '$signalStrength dBm' : 'Unknown';
    } catch (e) {
      return 'Failed to get signal strength';
    }
  }

  void _showSignalStrengthDialog(BuildContext context) async {
    String signalStrength = await _getSignalStrength();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('WiFi Signal Strength'),
          content: Text('Signal Strength: $signalStrength'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strength'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _showSignalStrengthDialog(context),
                child: Image.file(image),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
