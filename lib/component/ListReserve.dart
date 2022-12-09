import 'package:flutter/material.dart';

class ListReserve extends StatefulWidget {
  const ListReserve({Key? key}) : super(key: key);

  @override
  State<ListReserve> createState() => _ListReserveState();
}

class _ListReserveState extends State<ListReserve> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: ListView.builder(
            itemCount: 2,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 100,
                width: 100,
                color: Colors.red,
                child: Text('dd'),
              );
            }),
      ),
    );
  }
}
