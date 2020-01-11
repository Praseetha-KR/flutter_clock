// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

enum _Element {
  background,
  text,
  accent,
}

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.text: Colors.black,
  _Element.accent: Colors.deepPurple,
};

final _darkTheme = {
  _Element.background: Color(0xFF1D1E1E),
  _Element.text: Colors.white,
  _Element.accent: Colors.deepPurple,
};

var factsData = {};

Future<String> _loadFactsDataAsset() async {
  return await rootBundle.loadString('assets/data.json');
}

Future loadFactsData() async {
    String jsonString = await _loadFactsDataAsset();
    Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
    return jsonResponse;
}

/// A basic digital clock.
///
/// You can do better than this!
class FactsClock extends StatefulWidget {
  const FactsClock(this.model);

  final ClockModel model;

  @override
  _FactsClockState createState() => _FactsClockState();
}

class _FactsClockState extends State<FactsClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);

    loadFactsData().then((data) {
        factsData = data;
        print("data: ");
        print(data);
    }, onError: (e){ print(e); });

    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(FactsClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // final colors = Theme.of(context).brightness == Brightness.light
    //     ? _lightTheme
    //     : _darkTheme;
      final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour = DateFormat(
      widget.model.is24HourFormat ? 'HH' : 'hh'
    ).format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);

    final factKey = hour + minute;
    var fact = "";
    if (_dateTime.hour < 12) {
        fact = "Good Morning!";
    } else if (_dateTime.hour < 15) {
        fact = "Good Afternoon!";
    } else if (_dateTime.hour < 20) {
        fact = "Good Evening!";
    } else  {
        fact = "Good Night!";
    }
    if (factsData[factKey]!= null && factsData[factKey].length > 0){
        fact = factsData[factKey][0];
    }

    final fontSize = MediaQuery.of(context).size.width / 20.5;
    final offset = -fontSize / 7;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Roboto',
      fontSize: fontSize,
    );

    return Container(
      color: colors[_Element.background],
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width / 60 * int.parse(second),
                height: 10.0,
                color: colors[_Element.accent],
              ),
            ),
          ),
          Flexible(
            flex: 48,
            child: Padding(
              padding: EdgeInsets.fromLTRB(32.0, 20.0, 32.0, 0.0),
              child: Container(
                child: Container(
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded( // Constrains AutoSizeText to the width of the Row
                          child: AutoSizeText.rich(
                            TextSpan(
                              text: hour,
                              style: TextStyle(fontSize: 190),
                            ),
                            minFontSize: 0,
                            textAlign: TextAlign.end,
                            stepGranularity: 0.1,
                            style: TextStyle(
                                // fontFamily: 'Rajdhani',
                                fontWeight: FontWeight.w600,
                            ),
                          )
                        ),
                        AutoSizeText.rich(
                          TextSpan(
                            text: ':',
                            style: TextStyle(fontSize: 170, color: colors[_Element.accent]),
                          ),
                          minFontSize: 0,
                          stepGranularity: 0.1,
                          style: TextStyle(
                            //   fontFamily: 'Rajdhani',
                              fontWeight: FontWeight.w600,
                            ),
                        ),
                        Expanded( // Constrains AutoSizeText to the width of the Row
                          child: AutoSizeText.rich(
                            TextSpan(
                              text: minute,
                              style: TextStyle(fontSize: 190),
                            ),
                            minFontSize: 0,
                            stepGranularity: 0.1,
                            style: TextStyle(
                                // fontFamily: 'Rajdhani',
                                fontWeight: FontWeight.w600,
                            ),
                          )
                        ),
                      ],
                    ),
                  )
                )
              )
            ),
          ),
          Flexible(
            flex: 25,
            child: Padding(
              padding: EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 38.0),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded( // Constrains AutoSizeText to the width of the Row
                      child: AutoSizeText.rich(
                        TextSpan(
                          text: fact,
                          style: TextStyle(
                              fontSize: 200,
                            //   fontFamily: 'Open Sans',
                            ),
                        ),
                        minFontSize: 0,
                        textAlign: TextAlign.center,
                        stepGranularity: 0.1,
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }


  //   return Container(
  //     color: colors[_Element.background],
  //     width: MediaQuery.of(context).size.width,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         Container(
  //           width: MediaQuery.of(context).size.width / 60 * int.parse(second),
  //           height: 10.0,
  //           color: Colors.deepPurple,
  //         ),
  //         Container(
  //           child: FractionallySizedBox(
  //             // alignment: Alignment.center,
  //             widthFactor: 1,
  //             heightFactor: 0.7,
  //             child: Text(
  //               hour,
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             // child: Row(
  //             //   crossAxisAlignment: CrossAxisAlignment.center,
  //             //   children: <Widget>[
  //             //     Text(
  //             //       hour,
  //             //       style: TextStyle(color: Colors.white),
  //             //     ),
  //             //     Text(
  //             //       ":",
  //             //       style: TextStyle(color: Colors.deepPurple),
  //             //     ),
  //             //     Text(
  //             //       minute,
  //             //       style: TextStyle(color: Colors.white),
  //             //     ),
  //             //   ],
  //             // )
  //           ),
  //         ),


  //         // Center(
  //         //   child: DefaultTextStyle(
  //         //     style: defaultStyle,
  //         //     child: new Container(
  //         //       width: MediaQuery.of(context).size.width,
  //         //       color: Colors.red,
  //         //       margin: const EdgeInsets.all(0.0),
  //         //       child: new Column(
  //         //         mainAxisAlignment: MainAxisAlignment.center,
  //         //         children: <Widget>[
  //         //           new Align(
  //         //             alignment: Alignment.bottomCenter,
  //         //             child: new ButtonBar(
  //         //               alignment: MainAxisAlignment.center,
  //         //               children: <Widget>[
  //         //                 new Text(
  //         //                   hour,
  //         //                   style: new TextStyle(color: Colors.white),
  //         //                 ),
  //         //                 new Text(
  //         //                   minute,
  //         //                   style: new TextStyle(color: Colors.white),
  //         //                 ),
  //         //                 // new Text(
  //         //                 //   second,
  //         //                 //   style: new TextStyle(color: Colors.white),
  //         //                 // )
  //         //               ],
  //         //             ),
  //         //           ),
  //         //         ],
  //         //       ),
  //         //       //   Positioned(left: offset, top: 0, child: Text(hour)),
  //         //       //   Positioned(right: offset, top: 0, child: Text(minute)),
  //         //       //   Positioned(left: offset, top: -10 * offset, child: Text(second)),
  //         //       //   Positioned(left: offset, bottom: 0, child: Text(fact)),
  //         //       // ],
  //         //     ),
  //         //   ),
  //         // ),
  //         Center(
  //           child: Text(
  //             fact,
  //             style: defaultStyle,
  //             textAlign: TextAlign.center,
  //           ),
  //         ),
  //         // Stack(
  //         //   children: <Widget>[
  //         //     Positioned(bottom: 0, child: Text(fact)),
  //         //   ],
  //         // )
  //       ],
  //     )
  //   );
  // }
}

