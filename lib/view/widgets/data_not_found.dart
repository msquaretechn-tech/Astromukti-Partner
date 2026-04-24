
import 'package:flutter/material.dart';

import '../../resources/resources.dart';

class DataNotFound extends StatelessWidget {
  const DataNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return  Center(child: Text("Data not fond",style: Resources.styles.kTextStyle12B(Colors.black),));
  }
}
