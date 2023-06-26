import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("arguments[0]: " + Get.arguments[0].toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Empty Page"),
      ),
      body: const Center(
        child: Text("Empty content"),
      ),
    );
  }
}
