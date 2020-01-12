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
  bg1,
  bg2,
  text,
  textAccent,
  accent,
}

final _lightTheme = {
  _Element.background: Color(0xFFF4F8FB),
  _Element.bg1: Color(0xFFb8c9c9),
  _Element.bg2: Color(0xFF7ac9da),
  _Element.text: Color(0xFF2e353d),
  _Element.textAccent: Color(0xFF6f7070),
  _Element.accent: Color(0xFFef823e),
};

final _darkTheme = {
  _Element.background: Color(0xFF13192D),
  _Element.bg1: Color(0xFF373c3d),
  _Element.bg2: Color(0xFF1d1e1e),
  _Element.text: Color(0xFF7ac9da),
  _Element.textAccent: Color(0xFFb8c9c9),
  _Element.accent: Color(0xFFef823e),
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


class FactsClock extends StatefulWidget {
  const FactsClock(this.model);

  final ClockModel model;

  @override
  _FactsClockState createState() => _FactsClockState();
}

class _FactsClockState extends State<FactsClock> with SingleTickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  Animation<double> animation;
  AnimationController controller;

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

    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this
    );

    animation = Tween(begin: 0.8, end: 0.4)
      .chain(CurveTween(curve: Curves.bounceInOut))
      .animate(controller);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
      setState(() {});
    });

    controller.forward();
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
    controller.dispose();
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
    final colors = Theme.of(context).brightness == Brightness.light
          ? _lightTheme
          : _darkTheme;
    // final colors = Theme.of(context).brightness == Brightness.light
    //       ? _darkTheme
    //       : _lightTheme;
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

    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.1, 0.9],
          colors: [
            colors[_Element.bg1],
            colors[_Element.bg2]
          ],
        ),
      ),
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
          Spacer(flex: 12),
          Flexible(
            flex: 64,
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: AutoSizeText.rich(
                                TextSpan(
                                  text: hour,
                                ),
                                minFontSize: 50,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Fjalla One',
                                  fontSize: 500,
                                  color: colors[_Element.text],
                                ),
                              )
                            )
                          )
                        ]
                      )
                    )
                  ),
                  Column(
                    children: [
                      Spacer(flex: 4),
                      Flexible(
                        flex: 11,
                        child:Padding(
                          padding: EdgeInsets.only(
                            left: screenWidth * 0.006,
                            right: screenWidth * 0.006
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: AutoSizeText.rich(
                                      TextSpan(
                                        text: ':',
                                      ),
                                      minFontSize: 50,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Fjalla One',
                                        fontSize: 500,
                                        height: 0.9,
                                        color: colors[_Element.accent],
                                      ),
                                    )
                                  )
                                )
                              )
                            ]
                          )
                        ),
                      ),
                      Spacer(flex: 4),
                    ]
                  ),
                  Expanded(
                    child: Container(
                      // color: Colors.orange,
                      child: Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText.rich(
                                TextSpan(
                                  text: minute,
                                ),
                                minFontSize: 50,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Fjalla One',
                                  fontSize: 500,
                                  color: colors[_Element.text],
                                ),
                              )
                            )
                          )
                        ]
                      )
                    )
                  ),
                ],
              ),
            )
          ),
          Flexible(
            flex: 18,
            child: Container(
              // color: Colors.teal,
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.10,
                  right: screenWidth * 0.10
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: AutoSizeText.rich(
                          TextSpan(
                            text: fact,
                            style: TextStyle(
                              fontFamily: 'Open Sans',
                              fontSize: 200,
                              color: colors[_Element.textAccent],
                            ),
                          ),
                          minFontSize: 0,
                          textAlign: TextAlign.center,
                          stepGranularity: 0.1,
                        ),
                      )
                    )
                  ]
                ),
              )
            ),
          ),
          Spacer(flex: 12)
        ]
      ),
    );
  }
}

