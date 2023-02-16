import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './q.dart';

void main() => runApp(myapp());

class myapp extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _myappstate();
  }
}

class sentimentapi {
  final double compound;
  final double negative;
  final double neutral;
  final double positive;
  final String sentiment;

  const sentimentapi({
    required this.compound,
    required this.negative,
    required this.neutral,
    required this.positive,
    required this.sentiment,
  });

  factory sentimentapi.fromJson(Map<String, dynamic> json) {
    return sentimentapi(
      compound: json['compound'],
      negative: json['negative'],
      neutral: json['neutral'],
      positive: json['positive'],
      sentiment: json['sentiment'],
    );
  }
}

class _myappstate extends State<myapp> {
  void sentimentOutput() {
    print("This will be the output of the api!");
  }

  late Future<sentimentapi> futuresent;

  final myController = TextEditingController();
  String shouldDisplay = "";
  bool _validate = false;
  bool visiblity = false;
  bool _showCircle = false;

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Future<sentimentapi> fetchsent(String sentence) async {
    final response = await http
        .get(Uri.parse('https://sentiment-api-jxid.onrender.com/${sentence}'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return sentimentapi.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    futuresent = fetchsent(myController.text);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Sentiment App", textAlign: TextAlign.center),
          backgroundColor: Color.fromARGB(255, 201, 7, 240),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              sentiment(""),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Container(
                  constraints: BoxConstraints(minWidth: 1000),
                  child: IntrinsicWidth(
                    child: TextField(
                      controller: myController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 201, 7, 240),
                              width: 5.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 93, 243, 33),
                              width: 3.0),
                        ),
                        errorText: _validate ? 'Value Can\'t Be Empty' : null,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 100.0),
                        labelText: 'Enter the sentence',
                        labelStyle: TextStyle(),
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                child: const Text("Submit"),
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 201, 7, 240),
                  onPrimary: Colors.white,
                  shadowColor: Colors.blue,
                  elevation: 5,
                ),
                onPressed: () async {
                  visiblity = true;

                  await shouldDisplay;
                  setState(() {
                    myController.text.isEmpty
                        ? _validate = true
                        : _validate = false;
                    _showCircle = !_showCircle;
                    futuresent = fetchsent(myController.text);
                  });
                },
              ),
              FutureBuilder<sentimentapi>(
                future: futuresent,
                builder: (context, snapshot) {
                  if (myController.text.isEmpty) {
                    Container();
                  } else {
                    if (visiblity) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.sentiment.toString() ==
                            "😁 Positive") {
                          return Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Text(
                              "😁 Positive",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          );
                        } else if (snapshot.data!.sentiment.toString() ==
                            "😭 Negative") {
                          return Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Text(
                              "😭 Negative",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Text(
                              "😐 Neutral",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          );
                        }
                      }
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      );
                    }
                  }
                  return Visibility(
                    visible: _showCircle,
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
