import 'package:flutter/material.dart';

class MaterialDetailScreen extends StatelessWidget {
  final Color color;

  MaterialDetailScreen({required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Material Details'),
        backgroundColor: color,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              color: color,
            ),
            // Other widgets...
          ],
        ),
      ),
    );
  }
}