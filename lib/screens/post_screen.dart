import 'package:final_app2/widgets/post_widget.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  const PostScreen(this.snapshot, {super.key});
  final snapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: PostWidget(snapshot)),
    );
  }
}
