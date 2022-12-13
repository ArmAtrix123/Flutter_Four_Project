import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'theme_state.dart';

class themCubit extends Cubit<themState> {
  themCubit() : super(themInitial());

  void changeTheme(ThemeMode themeMode) {
    emit(themChanged(currentTheme: themeMode));
  }

  void calculateTheme(ThemeMode currentMode, bool umensh) {
    int currentValue = 0;
    if (currentMode == ThemeMode.light) {
      currentValue = 1;
    } else {
      currentValue = 2;
    }
    if (umensh) {
      currentValue = -currentValue;
    }
    emit(themAdded(currentTheme: currentMode, currentValue: currentValue));
  }
}
