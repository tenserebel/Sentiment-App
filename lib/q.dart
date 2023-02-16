import 'package:flutter/material.dart';

class sentiment extends StatelessWidget {
  final String questionText;

  sentiment(this.questionText);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Text("Sentiment Analysis",
          style: TextStyle(fontSize: 28, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center),
    );
  }
}
