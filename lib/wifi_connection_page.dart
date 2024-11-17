import 'package:flutter/material.dart';
import 'package:flutter_esp_ble_prov/flutter_esp_ble_prov.dart';
import 'package:iot_prov_new_lib/next_page.dart';

class WifiConnectionPage extends StatefulWidget {
  final String deviceName;
  final String proofOfPossesion;

  const WifiConnectionPage(
      {super.key, required this.deviceName, required this.proofOfPossesion});

  @override
  State<WifiConnectionPage> createState() => _WifiConnectionPageState();
}

class _WifiConnectionPageState extends State<WifiConnectionPage> {
  final passphraseController = TextEditingController();
  final ssidController = TextEditingController();
  String feedbackMessage = '';

  List<String> networks = [];

  @override
  void initState() {
    super.initState();
    // Automatically start scanning for Bluetooth devices on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scanWifiNetworks();
    });
  }

  Future scanWifiNetworks() async {
    final scannedNetworks = await FlutterEspBleProv().scanWifiNetworks(
      widget.deviceName,
      widget.proofOfPossesion,
    );
    setState(() {
      networks = scannedNetworks;
    });
    pushFeedback('Success: scanned WiFi on ${widget.deviceName}');
  }

  Future provisionWifi() async {
    try {
      await FlutterEspBleProv().provisionWifi(
        widget.deviceName,
        widget.proofOfPossesion,
        ssidController.text.trim(),
        passphraseController.text.trim(),
      );
      pushFeedback(
        'Success: Provisioned Wi-Fi on ${ssidController.text.trim()}',
      );

      // Navigate to the next page if provisioning is successful
      if (feedbackMessage.contains('Success')) {
        // Replace with your next page, for example, "NextPage()"
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const NextPage()),
        );
      }
    } catch (e) {
      pushFeedback('Error: Failed to provision Wi-Fi. $e');
    }
  }

  pushFeedback(String msg) {
    setState(() {
      feedbackMessage = '$feedbackMessage\n$msg';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Wi-Fi Network',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "To Complete setup of your device, PROV_123 please provide your Home Network's credentials",
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              )),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Networks",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Icon(
                  Icons.refresh_outlined,
                  color: Colors.black,
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
              onTap: () {
                _openModal(context, ssidController, passphraseController);
              },
              child: const Text(
                "Join Other Network",
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
              )),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(networks[index]),
                  onTap: () {
                    _openModal(context, ssidController, passphraseController);
                  },
                );
              },
              itemCount: networks.length,
            ),
          )
        ],
      ),
    );
  }

  void _openModal(
    BuildContext context,
    TextEditingController ssidController,
    TextEditingController passphraseController,
  ) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ssidController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Wi-Fi SSID',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passphraseController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Enter Wi-Fi Password',
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    await provisionWifi();
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 22),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                        child: Text(
                      "Provision Device",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                )
              ],
            ),
          );
        });
  }
}

