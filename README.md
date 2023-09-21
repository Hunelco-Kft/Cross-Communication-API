# Cross Communication API with Flutter

An innovative solution allowing seamless cross-communication between devices using Flutter with Dart. This API supports BLE (Bluetooth Low Energy) and provides a comprehensive communication flow that ensures smooth data interchange between client and server entities.

## Table of Contents

- [Getting Started](#getting-started)
- [Usage](#usage)
- [Classes](#classes)
  - [MyApp](#myapp)
  - [HardverService](#hardverservice)
  - [ClientService](#clientservice)
  - [Endpoints](#endpoints)
- [Contributing](#contributing)
- [License](#license)

## Getting Started

Before diving into this project, ensure that you have a good understanding of Dart and Flutter.

### Project setup:

1. Fetch all the required Flutter packages:

```dart
flutter pub get
```

2. Run the build runner to generate necessary files:

```dart
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Execute the pigeon script:

```dart
./run_pigeon.sh
```

4. Import the required libraries:

```dart
import 'package:cross_com_api/api.dart';
import 'package:cross_com_api/cross_com_api.dart';
import 'package:cross_com_api_example/endpoints.dart';

```

## Usage

### Step-by-Step Guide

1. The Hardver initializes the server and starts advertising itself over BLE (Bluetooth Low Energy) and nearby connections.
1. The Client scans for nearby Hardvers and connects to one.
1. Upon successful connection, the Client sends a message /com 'hello'.
1. Hardver receives the message and responds with /com 'world'.
1. Client receives the response and a simple conversation cycle is established.

## Classes

### MyApp

MyApp class is the main widget that initializes and oversees the entire application lifecycle. It facilitates the communication between the Hardver and the Client through user-triggered actions.

```dart
void main() {
  runApp(const MyApp());
}
```

### HardverService

HardverService class takes care of the server-side functionalities including starting the advertisement of the server, listening to messages from the client, and responding accordingly. It utilizes various methods like startAdvertise(), \_startListenMessage(), sendMessage(), etc. to handle different aspects of the server-client communication.

### ClientService

ClientService class handles the client-side functionalities, such as discovering Hardvers, connecting to a Hardver, and initiating a message stream. It leverages methods such as startDiscovery(), \_connectToDevice(), \_startListenMessage(), etc. to manage the different stages of client-server communication.

### Endpoints

The Endpoints class defines the communication endpoints to streamline the message transfer between the client and the server. Currently, it houses a single endpoint termed as 'com'.

```dart
class Endpoints {
  static const com = "/com";
}
```

## Contributing

This project thrives on community contributions. Whether it's bug reports, feature requests, or code contributions, all are welcome! Fork the project, open pull requests, or drop issues as needed.

## License

Like the example, this Cross Communication API is open-sourced under the MIT License. Embrace the freedom to use, modify, and distribute as per your requirements.
