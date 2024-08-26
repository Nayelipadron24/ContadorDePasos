import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String broker = '192.168.161.88';
  final int port = 1883;
  final String topicPulse = 'esp32/pulso';
  final String topicTemp = 'esp32/temperatura';

  late MqttServerClient client;
  String bpm = '0';
  String temperature = '0';
  String _stepCountValue = '0';

  @override
  void initState() {
    super.initState();
    requestPermission(); // Solicitar permisos
    connect();
    initPedometer();
  }

  // Solicitar permiso para Activity Recognition
  Future<void> requestPermission() async {
    if (await Permission.activityRecognition.isDenied) {
      await Permission.activityRecognition.request();
    }

    if (await Permission.activityRecognition.isPermanentlyDenied) {
      // Abrir configuración de la app si el permiso se deniega permanentemente
      openAppSettings();
    }
  }

  Future<void> connect() async {
    client = MqttServerClient(broker, '');
    client.port = port;
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .withWillTopic('willtopic')
        .withWillMessage('Connection Closed')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      disconnect();
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Connected to broker');
      subscribeToTopics();
    } else {
      print('Connection failed');
      disconnect();
    }
  }

  void disconnect() {
    client.disconnect();
    onDisconnected();
  }

  void onDisconnected() {
    print('Disconnected from broker');
  }

  void subscribeToTopics() {
    client.subscribe(topicPulse, MqttQos.atLeastOnce);
    client.subscribe(topicTemp, MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      setState(() {
        if (c[0].topic == topicPulse) {
          bpm = message;
        } else if (c[0].topic == topicTemp) {
          temperature = message;
        }
      });

      print('Received message: $message from topic: ${c[0].topic}');
    });
  }

  void initPedometer() {
    Pedometer.stepCountStream.listen(onStepCount).onError(onStepCountError);
  }

  void onStepCount(StepCount event) {
    setState(() {
      _stepCountValue = event.steps.toString();
      print('PasoOOOOOOOOOOOs: $_stepCountValue'); // Mostrar los pasos en la consola
    });
  }

  void onStepCountError(error) {
    print('Error: $error');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // Desactivar la etiqueta DEBUG
      home: Scaffold(
        appBar: AppBar(
          title: Text('MONITOR MQTT'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gráfico de Pulso
              Text(
                'Gráfico de Pulso',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, double.parse(bpm)), // Valor de pulso
                          FlSpot(1, double.parse(bpm)), // Valor de pulso
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Gráfico de Temperatura
              Text(
                'Gráfico de Temperatura',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, double.parse(temperature)), // Valor de temperatura
                          FlSpot(1, double.parse(temperature)), // Valor de temperatura
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Mostrar los pasos
              Card(
                color: Colors.greenAccent,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.directions_walk, color: Colors.white, size: 50),
                      SizedBox(height: 10),
                      Text(
                        'Pasos: $_stepCountValue',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:pedometer/pedometer.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final String broker = '192.168.0.16';
//   final int port = 1883;
//   final String topicPulse = 'esp32/pulso';
//   final String topicTemp = 'esp32/temperatura';

//   late MqttServerClient client;
//   String bpm = '0';
//   String temperature = '0';
//   String _stepCountValue = '0';

//   @override
//   void initState() {
//     super.initState();
//     connect();
//     initPedometer();
//   }

//   Future<void> connect() async {
//     client = MqttServerClient(broker, '');
//     client.port = port;
//     client.keepAlivePeriod = 20;
//     client.onDisconnected = onDisconnected;
//     client.logging(on: true);

//     final connMessage = MqttConnectMessage()
//         .withClientIdentifier('flutter_client')
//         .withWillTopic('willtopic')
//         .withWillMessage('Connection Closed')
//         .startClean()
//         .withWillQos(MqttQos.atLeastOnce);
//     client.connectionMessage = connMessage;

//     try {
//       await client.connect();
//     } catch (e) {
//       print('Exception: $e');
//       disconnect();
//     }

//     if (client.connectionStatus?.state == MqttConnectionState.connected) {
//       print('Connected to broker');
//       subscribeToTopics();
//     } else {
//       print('Connection failed');
//       disconnect();
//     }
//   }

//   void disconnect() {
//     client.disconnect();
//     onDisconnected();
//   }

//   void onDisconnected() {
//     print('Disconnected from broker');
//   }

//   void subscribeToTopics() {
//     client.subscribe(topicPulse, MqttQos.atLeastOnce);
//     client.subscribe(topicTemp, MqttQos.atLeastOnce);

//     client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
//       final recMess = c![0].payload as MqttPublishMessage;
//       final message =
//           MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

//       setState(() {
//         if (c[0].topic == topicPulse) {
//           bpm = message;
//         } else if (c[0].topic == topicTemp) {
//           temperature = message;
//         }
//       });

//       print('Received message: $message from topic: ${c[0].topic}');
//     });
//   }

//   void initPedometer() {
//     Pedometer.stepCountStream.listen(onStepCount).onError(onStepCountError);
//   }

//   void onStepCount(StepCount event) {
//     setState(() {
//       _stepCountValue = event.steps.toString();
//     });
//   }

//   void onStepCountError(error) {
//     print('Error: $error');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('MQTT Client'),
//           backgroundColor: Colors.blueAccent,
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Gráfico de Pulso
//               Text(
//                 'Gráfico de Pulso',
//                 style: TextStyle(fontSize: 24),
//               ),
//               SizedBox(
//                 height: 200,
//                 child: LineChart(
//                   LineChartData(
//                     gridData: FlGridData(show: true),
//                     borderData: FlBorderData(show: true),
//                     lineBarsData: [
//                       LineChartBarData(
//                         spots: [
//                           FlSpot(0, double.parse(bpm)), // Valor de pulso
//                           FlSpot(1, double.parse(bpm)), // Valor de pulso
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               // Gráfico de Temperatura
//               Text(
//                 'Gráfico de Temperatura',
//                 style: TextStyle(fontSize: 24),
//               ),
//               SizedBox(
//                 height: 200,
//                 child: LineChart(
//                   LineChartData(
//                     gridData: FlGridData(show: true),
//                     borderData: FlBorderData(show: true),
//                     lineBarsData: [
//                       LineChartBarData(
//                         spots: [
//                           FlSpot(0, double.parse(temperature)), // Valor de temperatura
//                           FlSpot(1, double.parse(temperature)), // Valor de temperatura
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               // Mostrar los pasos
//               Card(
//                 color: Colors.greenAccent,
//                 elevation: 5,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Icon(Icons.directions_walk, color: Colors.white, size: 50),
//                       SizedBox(height: 10),
//                       Text(
//                         'Pasos: $_stepCountValue',
//                         style: TextStyle(fontSize: 24, color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     disconnect();
//     super.dispose();
//   }
// }

