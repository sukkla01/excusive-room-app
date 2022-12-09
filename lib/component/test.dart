import 'package:flutter/material.dart';

// import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  late IO.Socket socket;
  void initState() {
    socket = IO.io(
        'http://localhost:4555',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();
    super.initState();
  }

  void initializeSocket() {
    socket.connect(); //connect the Socket.IO Client to the Server

    //SOCKET EVENTS
    // --> listening for connection
    socket.on('connect', (data) {
      print(socket.connected);
    });

    //listen for incoming messages from the Server.
    socket.emit('message', (data) {
      print(data); //
    });

    //listens when the client is disconnected from the Server
    socket.on('disconnect', (data) {
      print('disconnect');
    });
    print('dsdd');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          initializeSocket();
          socket.emit('message', (data) {
            print(data); //
          });
        },
        child: Container(
          height: 100,
          width: 100,
          color: Colors.red,
        ),
      ),
    );
  }
}
