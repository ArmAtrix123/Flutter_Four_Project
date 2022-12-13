part of 'theme.dart';

@immutable
abstract class themState {}

class themInitial extends themState {
  themInitial();
}

class themChanged extends themState {
  ThemeMode currentTheme;
  themChanged({
    required this.currentTheme,
  });
}

class themAdded extends themState {
  ThemeMode currentTheme;
  int currentValue;
  themAdded({required this.currentTheme, required this.currentValue});
}
