import 'dart:async';

import 'package:cross_com_api_example/client_service.dart';
import 'package:cross_com_api_example/hardver_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  HardverService? hardverService;
  ClientService? clientService;

  StreamSubscription<String>? clientMsgSub;
  StreamSubscription<String>? hardverMsgSub;

  String? hardverMsg;
  String? clientMsg;

  //EXAMPLE APP:
  //1. Hardver start server and start advertise (ble + nearby)
  //2. Client search the Hardver and connect
  //3. Client detects Hardver and if Client connected successfully Client sends message: /com 'hello'
  //4. Hardver gets the message: /com 'hello' and send back a response message: /com 'world'
  //5. Client gets the message: /com 'world'

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cross com example app'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Turn on your location and bluetooth service!'),
              ),
              _getHardverBody(),
              _getClientBody()
            ],
          ),
        ),
      ),
    );
  }

  Widget _getHardverBody() {
    return hardverService == null && clientService != null
        ? Container()
        : hardverService == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        hardverService = HardverService();
                      });
                      hardverMsgSub = hardverService!.onMsg.listen((event) {
                        hardverMsg = (hardverMsg ?? '') + '\n$event';
                        setState(() {});
                      });
                      hardverService?.startAdvertise();
                    },
                    child: Text('Start Hardver')),
              )
            : Column(
                children: [
                  Text('Hardver service is running....'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Messages: ${hardverMsg ?? '-'}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await hardverService!.close();
                          } catch (e) {}
                          hardverMsgSub?.cancel();
                          hardverMsg = null;
                          setState(() {
                            hardverService = null;
                          });
                        },
                        child: Text('Stop Hardver')),
                  )
                ],
              );
  }

  Widget _getClientBody() {
    return clientService == null && hardverService != null
        ? Container()
        : clientService == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        clientService = ClientService();
                      });
                      clientMsgSub = clientService!.onMsg.listen((event) {
                        clientMsg = (clientMsg ?? '') + '\n$event';
                        setState(() {});
                      });
                      clientService?.startDiscovery(deviceName: HardverService.serverName);
                    },
                    child: Text('Start Client')),
              )
            : Column(
                children: [
                  Text('Client service is running....'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Messages: ${clientMsg ?? '-'}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await clientService!.close();
                          } catch (e) {}
                          clientMsgSub?.cancel();
                          clientMsg = null;
                          setState(() {
                            clientService = null;
                          });
                        },
                        child: Text('Stop Client')),
                  )
                ],
              );
  }
}
