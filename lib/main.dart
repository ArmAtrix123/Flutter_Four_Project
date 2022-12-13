import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterfour/cubit/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  ThemeMode currentMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: currentMode,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: BlocProvider(
          create: (context) => themCubit(),
          child: BodyWidget(
            changeMode: (currentMode) => setState(() {
              this.currentMode = currentMode;
            }),
          ),
        ),
      ),
    );
  }
}

class BodyWidget extends StatefulWidget {
  BodyWidget({Key? key, required this.changeMode}) : super(key: key);
  void Function(ThemeMode currentMode) changeMode;

  @override
  State<BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  List<String> values = [];
  late Timer _timer;
  SharedPreferences? currentPrefs;
  int currentValue = 0;
  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      currentPrefs = value;
      if (currentPrefs!.containsKey("count")) {
        setState(() {
          currentPrefs = value;
          values = value.getStringList("count")!;
          currentValue = value.getInt("value")!;
        });
      }
      if (currentPrefs!.containsKey('theme')) {
        context
            .read<themCubit>()
            .changeTheme(ThemeMode.values[value.getInt('theme')!]);
      }
    });
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      context.read<themCubit>().calculateTheme(
          Theme.of(context).brightness == Brightness.light
              ? ThemeMode.light
              : ThemeMode.dark,
          false);
    });
    super.initState();
  }

  Timer getTimer() => Timer.periodic(Duration(seconds: 5), (timer) {
        context.read<themCubit>().calculateTheme(
            Theme.of(context).brightness == Brightness.light
                ? ThemeMode.light
                : ThemeMode.dark,
            false);
      });

  @override
  Widget build(BuildContext context) {
    return BlocListener<themCubit, themState>(
      listener: (context, state) {
        if (state is themAdded) {
          setState(() {
            currentValue += state.currentValue;
            values.add("Счет: $currentValue, Тема: ${state.currentTheme.name}");
          });

          currentPrefs?.setStringList("count", values);
          currentPrefs?.setInt("value", currentValue);
        } else if (state is themChanged) {
          widget.changeMode(state.currentTheme);
          currentPrefs?.setInt("theme", state.currentTheme.index);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                    onPressed: () {
                      _timer.cancel();
                      _timer = getTimer();
                      context.read<themCubit>().calculateTheme(
                          Theme.of(context).brightness == Brightness.light
                              ? ThemeMode.light
                              : ThemeMode.dark,
                          false);
                    },
                    child: Icon(Icons.add)),
                FloatingActionButton(
                  onPressed: () {
                    _timer.cancel();
                    _timer = getTimer();
                    context.read<themCubit>().calculateTheme(
                        Theme.of(context).brightness == Brightness.light
                            ? ThemeMode.light
                            : ThemeMode.dark,
                        true);
                  },
                  child: Icon(Icons.remove),
                ),
                Text(currentValue.toString()),
                FloatingActionButton(
                  onPressed: () => context.read<themCubit>().changeTheme(
                      Theme.of(context).brightness == Brightness.light
                          ? ThemeMode.dark
                          : ThemeMode.light),
                  child: Icon(Theme.of(context).brightness == Brightness.light
                      ? Icons.nightlight_round_outlined
                      : Icons.sunny),
                ),
                FloatingActionButton(
                  onPressed: () {
                    currentPrefs!.clear();
                    setState(() {
                      values.clear();
                      currentValue = 0;
                      _timer.cancel();
                      _timer = getTimer();
                    });
                  },
                  child: Icon(Icons.clear),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: values.map((e) => Center(child: Text(e))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
