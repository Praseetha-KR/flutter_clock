import 'dart:io';

import 'package:flutter_clock_helper/customizer.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'facts_clock.dart';

void main() {
    if (!kIsWeb && Platform.isMacOS) {
        // TODO(gspencergoog): Update this when TargetPlatform includes macOS.
        // https://github.com/flutter/flutter/issues/31366
        // See https://github.com/flutter/flutter/wiki/Desktop-shells#target-platform-override.
        debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    }
    runApp(ClockCustomizer((ClockModel model) => FactsClock(model)));
}
