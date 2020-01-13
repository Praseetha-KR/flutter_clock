import 'dart:async';
import 'dart:convert';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:weather_icons/weather_icons.dart';

enum _Element {
  background,
  bg1,
  bg2,
  text,
  textAccent,
  accent,
  textLight,
}

final _lightTheme = {
  _Element.background: Color(0xFFF4F8FB),
  _Element.bg1: Color(0xFFb8c9c9),
  _Element.bg2: Color(0xFF7ac9da),
  _Element.text: Color(0xFF2e353d),
  _Element.textAccent: Color(0xFF636a72),
  _Element.textLight: Color(0xFF85898f),
  _Element.accent: Color(0xFFef823e),
};

final _darkTheme = {
  _Element.background: Color(0xFF13192D),
  _Element.bg1: Color(0xFF373c3d),
  _Element.bg2: Color(0xFF1d1e1e),
  _Element.text: Color(0xFF7ac9da),
  _Element.textAccent: Color(0xFFb8c9c9),
  _Element.textLight: Color(0xFF656c6c),
  _Element.accent: Color(0xFFef823e),
};

var _factsData = {};

Future<String> _loadFactsDataAsset() async {
  return await rootBundle.loadString('assets/data.json');
}

Future loadFactsData() async {
  String _jsonString = await _loadFactsDataAsset();
  Map<String, dynamic> _jsonResponse = jsonDecode(_jsonString);
  return _jsonResponse;
}

class FactsClock extends StatefulWidget {
  const FactsClock(this.model);

  final ClockModel model;

  @override
  _FactsClockState createState() => _FactsClockState();
}

class _FactsClockState extends State<FactsClock>
    with SingleTickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  var _temperature = '';
  var _condition = '';

  Animation<double> _animation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);

    loadFactsData().then((d) {
      _factsData = d;
    }, onError: (e) {
      print(e);
    });

    _updateTime();
    _updateModel();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    _animation = Tween(begin: 0.8, end: 0.4)
        .chain(CurveTween(curve: Curves.bounceInOut))
        .animate(_controller);

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
      setState(() {});
    });

    _controller.forward();
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
    _controller.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _condition = widget.model.weatherString;
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  IconData _getWeatherIcon(condition) {
    final conditionIconMap = {
      'cloudy': WeatherIcons.cloudy,
      'foggy': WeatherIcons.fog,
      'rainy': WeatherIcons.rain,
      'snowy': WeatherIcons.snow,
      'sunny': WeatherIcons.day_sunny,
      'thunderstorm': WeatherIcons.thunderstorm,
      'windy': WeatherIcons.windy,
    };
    return conditionIconMap[condition];
  }

  String _getFactForNow(date, hour, minute) {
    final key = hour + minute;
    var fact = '';

    // Set default if no fact defined for the key
    if (_dateTime.hour < 10) {
      fact = 'Good Morning!';
    } else if (_dateTime.hour < 13) {
      fact = 'Have a nice day!';
    } else if (_dateTime.hour < 15) {
      fact = 'Good Afternoon!';
    } else if (_dateTime.hour < 20) {
      fact = 'Good Evening!';
    } else {
      fact = 'Good Night!';
    }

    final numFacts = _factsData[key];
    if (numFacts != null && numFacts.length > 0) {
      // Rotate index
      final nextIdx = date % numFacts.length;
      fact = numFacts[nextIdx];
    }
    return fact;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    final screenWidth = MediaQuery.of(context).size.width;

    // Get time
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);
    final day = DateFormat('EEE, d MMM').format(_dateTime);

    // Get a random fact for current time
    final fact = _getFactForNow(_dateTime.day, hour, minute);

    final weatherComponent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Spacer(flex: 4),
        Flexible(
            flex: 29,
            child: Container(
              // color: Colors.amber,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 14,
                    child: Container(
                      child: Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: AutoSizeText.rich(
                                TextSpan(
                                  text: day,
                                ),
                                minFontSize: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 200,
                                  color: colors[_Element.textLight],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    child: Container(
                        child: Column(children: [
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Align(
                            alignment: Alignment.center,
                            child:
                                LayoutBuilder(builder: (context, constraint) {
                              return new BoxedIcon(
                                _getWeatherIcon(_condition),
                                size: constraint.biggest.height / 1.7,
                                color: colors[_Element.accent],
                              );
                            })),
                      ))
                    ])),
                  ),
                  Flexible(
                    flex: 9,
                    child: Container(
                      child: Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText.rich(
                                TextSpan(
                                  text: _temperature,
                                ),
                                minFontSize: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 200,
                                  color: colors[_Element.textLight],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
        Spacer(flex: 77),
      ],
    );

    final timeComponent = Container(
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(children: [
            Spacer(flex: 4),
            Flexible(
              flex: 11,
              child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenWidth * 0.006),
                  child: Column(children: [
                    Expanded(
                        child: Align(
                            alignment: Alignment.center,
                            child: FadeTransition(
                                opacity: _animation,
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
                                ))))
                  ])),
            ),
            Spacer(flex: 4),
          ]),
          Expanded(
            child: Container(
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final factComponent = Column(
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
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.1, 0.9],
          colors: [colors[_Element.bg1], colors[_Element.bg2]],
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
                width:
                    MediaQuery.of(context).size.width / 60 * int.parse(second),
                height: 10.0,
                color: colors[_Element.accent],
              ),
            ),
          ),
          Spacer(flex: 6),
          Flexible(
            flex: 6,
            child: Container(
              child: weatherComponent,
            ),
          ),
          Spacer(flex: 2),
          Flexible(flex: 65, child: timeComponent),
          Flexible(
            flex: 13,
            child: Container(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.10),
                  child: factComponent),
            ),
          ),
          Spacer(flex: 12),
        ],
      ),
    );
  }
}
