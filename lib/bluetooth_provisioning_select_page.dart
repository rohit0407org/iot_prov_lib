
import 'package:flutter/material.dart';
import 'package:flutter_esp_ble_prov/flutter_esp_ble_prov.dart';
import 'package:iot_prov_new_lib/wifi_connection_page.dart';

class BluetoothProvisioningSelectPage extends StatefulWidget {
  const BluetoothProvisioningSelectPage({super.key});

  @override
  State<BluetoothProvisioningSelectPage> createState() => _BluetoothProvisioningSelectPageState();
}

class _BluetoothProvisioningSelectPageState extends State<BluetoothProvisioningSelectPage> {
  final _flutterEspBleProvPlugin = FlutterEspBleProv();
  final TextEditingController prefixController =
  TextEditingController(text: 'PROV_');
  final FocusNode focusNode = FocusNode();
  List<String> devices = [];
  String selectedDeviceName="";

  @override
  void initState() {
    super.initState();
    // Automatically start scanning for Bluetooth devices on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanning();
    });
  }


  void _onSavePrefix() {
    // Save the new prefix value and restart scanning
    final updatedPrefix = prefixController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Prefix updated to: $updatedPrefix')),
    );

    // Restart scanning with the updated prefix
    _startScanning();

    // Optionally, unfocus the TextField
    focusNode.unfocus();
  }


  void _startScanning() async  {
    // Trigger Bluetooth scan with the current prefix
    final prefix = prefixController.text.trim();
    final scannedDevices = await _flutterEspBleProvPlugin.scanBleDevices(prefix);
    setState(() {
      devices = scannedDevices;
    });



    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scanning for devices with prefix: $prefix...')),
    );
  }


  @override
  void dispose() {
    prefixController.dispose();
    focusNode.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Connect to Device",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  "Prefix: ",
                  style: TextStyle(fontSize: 16),
                ),
                Expanded(
                  child: TextField(
                    controller: prefixController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    onSubmitted: (_) => _onSavePrefix(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onSavePrefix,
                  child: const Text("SAVE"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "To provision your new device, please make sure that your Phone's Bluetooth is turned on and within range of your new device.",
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(itemBuilder: (context, index){
              return GestureDetector(
                onTap: (){
                  selectedDeviceName=devices[index];
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>WifiConnectionPage(deviceName: selectedDeviceName, proofOfPossesion: "abcd1234")));

                },
                child: ListTile(
                  title: Text(devices[index]),
                ),
              );
            }, itemCount: devices.length,)
          ),
        ],
      ),
    );
  }
}
