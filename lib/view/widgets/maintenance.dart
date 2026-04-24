

import 'package:flutter/material.dart';

import '../../resources/resources.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error,
              size: 80.0,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
             Text(
              '503',
              textAlign: TextAlign.center,
              style: Resources.styles.kTextStyle16B(Colors.black),
            ),
             Text(
              'Service Unavailable.',
              textAlign: TextAlign.center,
              style: Resources.styles.kTextStyle16B(Colors.black),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              child:  Text(
                'The server is temporarily unable to service your request due to maintenance downtime . Please try again later.',
                textAlign: TextAlign.center,
                style: Resources.styles.kTextStyle14B(Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
